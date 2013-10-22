//
//  AGChainController.m
//  Airogami
//
//  Created by Tianhu Yang on 8/21/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChainController.h"
#import "AGCoreData.h"
#import "AGChainMessageId.h"
#import "AGManagerUtils.h"
#import "AGAccountStat.h"
#import "AGControllerUtils.h"
#import "AGAppDirector.h"
#import "AGUtils.h"

static const int MaxNeoChainIds = 50;

@interface AGChainController()
{
    AGCoreData *coreData;
    NSEntityDescription *chainEntityDescription;
    NSEntityDescription *chainMessageEntityDescription;
    NSEntityDescription *neoChainEntityDescription;
}

@end

@implementation AGChainController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        chainEntityDescription = [NSEntityDescription entityForName:@"AGChain" inManagedObjectContext:coreData. managedObjectContext];
        chainMessageEntityDescription = [NSEntityDescription entityForName:@"AGChainMessage" inManagedObjectContext:coreData. managedObjectContext];
        neoChainEntityDescription = [NSEntityDescription entityForName:@"AGNeoChain" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}

- (NSMutableArray*) saveNeoChains:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGNeoChain"];
    long long max = LONG_LONG_MIN;
    for (AGNeoChain *neoChain in array) {
        if (neoChain.updateInc.longLongValue > max) {
            max = neoChain.updateInc.longLongValue;
        }
        if (neoChain.chain == nil) {
            AGChain *chain = (AGChain *)[coreData findById:neoChain.chainId withEntityName:@"AGChain"];
            if (chain != nil) {
                neoChain.chain = chain;
            }
        }
    }
    
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    if (max > accountStat.chainUpdateInc.longLongValue) {
        accountStat.chainUpdateInc = [NSNumber numberWithLongLong:max];
    }
    [coreData save];
    return array;
}

- (NSMutableArray*) saveOldChains:(NSArray*)jsonArray
{
    AGChainMessageController *chainMessageController = [AGControllerUtils controllerUtils].chainMessageController;
    for (NSMutableDictionary *oldChainJson in jsonArray) {
        NSNumber *chainId = [oldChainJson objectForKey:@"chainId"];
        AGChainMessage *chainMessage = [chainMessageController getChainMessageForChain:chainId];
        chainMessage.status = [oldChainJson objectForKey:@"status"];
        NSString *lastViewedTimeJson = [oldChainJson objectForKey:@"lastViewedTime"];
        if (lastViewedTimeJson) {
            chainMessage.lastViewedTime = [AGUtils stringToDate:lastViewedTimeJson];
            chainMessage.mineLastTime = chainMessage.lastViewedTime;
        }
        [oldChainJson removeObjectForKey:@"status"];
        [oldChainJson removeObjectForKey:@"lastViewedTime"];
        [oldChainJson setObject:[NSNumber numberWithBool:NO] forKey:@"deleted"];
    }
    NSMutableArray *array = [coreData updateArray:jsonArray withEntityName:@"AGChain"];
    [coreData save];
    return array;
}

- (NSMutableArray*) saveChains:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGChain"];
    for (AGChain *chain in array) {
        AGNeoChain *neoChain = (AGNeoChain *)[coreData findById:chain.chainId withEntityName:@"AGNeoChain"];
        if (neoChain != nil && neoChain.chain == nil) {
            neoChain.chain = chain;
        }
    }
    [coreData save];
    return array;
}

- (NSMutableArray*) saveChainsForCollect:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGChain"];
    [coreData save];
    return array;
}

- (AGChain*) saveChain:(NSDictionary*)chainJson
{
    AGChain *chain = (AGChain*)[coreData saveOrUpdate:chainJson withEntityName:@"AGChain"];
    [coreData save];
    return chain;
}

- (NSNumber*)recentUpdateInc
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSNumber *updateInc = account.accountStat.chainUpdateInc;
    if (updateInc == nil) {
        updateInc = [NSNumber numberWithLongLong:LONG_LONG_MIN];
    }
    return updateInc;
}

- (NSArray*) getAllChainsForCollect
{
    return [self getAllChains:1];
}

- (NSArray*) getAllChainsForChat
{
    return [self getAllChains:2];
}

//1 = collect; 2 = chat;
- (NSArray*) getAllChains:(int)type
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(chainMessages, $chainMessage, $chainMessage.account.accountId = %@ && $chainMessage.status = %d).@count > 0 && (account.accountId != %@ || passCount > 0)", account.accountId, type == 1 ? AGChainMessageStatusNew : AGChainMessageStatusReplied, account.accountId];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedTime" ascending: type == 3];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        array = [NSArray array];
    }
    return array;
}

//-1 = unknown; 0 = colleted; 1 = obtained; 2 = deleted
- (int) chainStatus:(NSNumber*)chainId
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainMessageEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain.chainId = %@ and account.accountId = %@", chainId, account.accountId];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!array.count) {
        return -1;
    }
    else{
        AGChainMessage *chainMessage = array.lastObject;
        return chainMessage.status.intValue;//status code should start with 0
    }
}

- (void) updateChainMessage:(AGChain*)chain
{
    AGChainMessage *chainMessage = [self recentChainMessage:chain.chainId];
    chain.chainMessage = chainMessage;
    chain.updatedTime = chainMessage.createdTime;
    [coreData save];
}

//not include unreplied chainMessage
- (AGChainMessage*) recentChainMessage:(NSNumber*)chainId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainMessageEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain.chainId = %@ and status >= %d", chainId, AGChainMessageStatusReplied];
    [fetchRequest setPredicate:predicate];
    //
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"createdTime"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxCreatedTime"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSDateAttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGChainMessage *chainMessage = nil;
    if (array.count) {
        NSDate *maxCreatedTime = [[array objectAtIndex:0] objectForKey:@"maxCreatedTime"];
        fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:chainMessageEntityDescription];
        //
        predicate = [NSPredicate predicateWithFormat:@"createdTime = %@", maxCreatedTime];
        [fetchRequest setPredicate:predicate];
        array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (array.count) {
            chainMessage = [array objectAtIndex:0];
        }
    }
    return chainMessage;
}

- (void) increaseUpdateInc
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSNumber *updateInc = account.accountStat.chainUpdateInc;
    if (updateInc == nil) {
        updateInc = [NSNumber numberWithLongLong:LONG_LONG_MIN];
    }
    account.accountStat.chainUpdateInc = [NSNumber numberWithLongLong:updateInc.longLongValue + 1];
    [coreData save];
}

- (void) updateLastViewedTime:(NSDate *)lastViewedTime chain:(AGChain*)chain
{
    chain.chainMessage.lastViewedTime = lastViewedTime;
    [coreData save];
}

- (NSArray*) getNeoChainIdsForUpdate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:neoChainEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain == nil || updateCount > chain.updateCount"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"chainId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:MaxNeoChainIds];
    //
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"chainId"]];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *chainIds = nil;
    if (array) {
        chainIds = [NSMutableArray arrayWithCapacity:array.count];
        for (NSDictionary *dict in array) {
            [chainIds addObject:[dict objectForKey:@"chainId"]];
        }
    }
    return chainIds;
}

- (AGNeoChain*) getNextNeoChainForChainMessage
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:neoChainEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain != nil && updateCount <= chain.updateCount"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNeoChain *neoChain = nil;
    if (array.count) {
        neoChain = [array lastObject];
    }
    return neoChain;
}
//for pickup
- (void) addNeoChains:(NSArray *)chains
{
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    long long count = accountStat.chainUpdateInc.longLongValue;
    for (AGChain *chain in chains) {
        ++count;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        [dict setObject:chain.chainId forKey:@"chainId"];
        [dict setObject:chain.updateCount forKey:@"updateCount"];
        [dict setObject:[NSNumber numberWithLongLong:count] forKey:@"updateInc"];
        AGNeoChain *neoChain = (AGNeoChain *)[coreData saveOrUpdate:dict withEntityName:@"AGNeoChain"];
        neoChain.chain = chain;
    }
    accountStat.chainUpdateInc = [NSNumber numberWithLongLong:count];
    [coreData save];
}

- (void) removeNeoChain:(AGNeoChain *)neoChain oldUpdateInc:(NSNumber*)updateInc
{
    if ([neoChain.updateInc isEqualToNumber:updateInc] && neoChain.chain != nil && neoChain.updateCount.intValue <= neoChain.chain.updateCount.intValue) {
        [coreData remove:neoChain];
    }
    
}

- (void) resetForSync
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainEntityDescription];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [array makeObjectsPerformSelector:@selector(setDeleted:) withObject:[NSNumber numberWithBool:YES]];
}

- (void) deleteForSync
{
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    int unreadChainMessagesCount = 0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainEntityDescription];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *deletedArray = [NSMutableArray arrayWithCapacity:array.count];
    for (AGChain *chain in array) {
        if (chain.deleted.boolValue == YES) {
            [deletedArray addObject:chain];
            //[[AGControllerUtils controllerUtils].chainMessageController viewedChainMessagesForChain:chain];
        }
        else{
            unreadChainMessagesCount += [[AGControllerUtils controllerUtils].chainMessageController updateChainMessagesCountForChain:chain];
            
        }
    }
    accountStat.unreadChainMessagesCount = [NSNumber numberWithInt:unreadChainMessagesCount];
    [coreData removeAll:deletedArray];
}


@end
