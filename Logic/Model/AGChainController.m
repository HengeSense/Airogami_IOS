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

static const int MaxNewChainIds = 50;

@interface AGChainController()
{
    AGCoreData *coreData;
    NSEntityDescription *chainEntityDescription;
    NSEntityDescription *chainMessageEntityDescription;
    NSEntityDescription *newChainEntityDescription;
}

@end

@implementation AGChainController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        chainEntityDescription = [NSEntityDescription entityForName:@"AGChain" inManagedObjectContext:coreData. managedObjectContext];
        chainMessageEntityDescription = [NSEntityDescription entityForName:@"AGChainMessage" inManagedObjectContext:coreData. managedObjectContext];
        newChainEntityDescription = [NSEntityDescription entityForName:@"AGNewChain" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}

- (NSMutableArray*) saveNewChains:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGNewChain"];
    long long max = LONG_LONG_MIN;
    for (AGNewChain *newChain in array) {
        if (newChain.updateInc.longLongValue > max) {
            max = newChain.updateInc.longLongValue;
        }
        if (newChain.chain == nil) {
            AGChain *chain = (AGChain *)[coreData findById:newChain.chainId withEntityName:@"AGChain"];
            if (chain != nil) {
                newChain.chain = chain;
            }
        }
    }
    
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    if (accountStat.chainUpdateInc == nil || max > accountStat.chainUpdateInc.longLongValue) {
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
        [oldChainJson removeObjectForKey:@"status"];
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
        AGNewChain *newChain = (AGNewChain *)[coreData findById:chain.chainId withEntityName:@"AGNewChain"];
        if (newChain != nil && newChain.chain == nil) {
            newChain.chain = chain;
        }
    }
    [coreData save];
    return array;
}

- (NSMutableArray*) saveChains:(NSArray*)jsonArray forCollect:(BOOL)collected
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGChain"];
    for (AGChain *chain in array) {
        chain.collected = [NSNumber numberWithChar:collected];
    }
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

- (NSNumber*)recentChainUpdateIncForCollect
{
    return [self recentChainUpdateInc:YES];
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


- (NSNumber*)recentChainUpdateIncForChat
{
    return [self recentChainUpdateInc:NO];
}

- (NSNumber*)recentChainUpdateInc:(BOOL)forCollect
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    //SUBQUERY(chainMessages, $chainMessage, $chainMessage.account.accountId = %@ && $chainMessage.status = %d).@count != 0
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"collected = %d && (account.accountId != %@ || passCount > 0)", forCollect, account.accountId];
    [fetchRequest setPredicate:predicate];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"updateInc"];
    NSExpression *maxUpdateIncExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxUpdateInc"];
    [expressionDescription setExpression:maxUpdateIncExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSNumber *updateInc = nil;
    if (error == nil && array.count) {
        updateInc = [[array objectAtIndex:0] objectForKey:@"maxUpdateInc"];
    }
    //check whether empty
    if (updateInc.longLongValue == 0) {
        predicate = [NSPredicate predicateWithFormat:@"collected = %d && (account.accountId != %@ || passCount > 0) && updateInc = 0", forCollect, account.accountId];
        fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:chainEntityDescription];
        fetchRequest.predicate = predicate;
        array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!array.count) {
            updateInc = nil;
        }
    }
    return updateInc;
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

- (void) increaseUpdateIncForChat:(AGChain*)chain
{
    NSNumber *maxUpdateInc = [self recentChainUpdateIncForChat];
    if (maxUpdateInc == nil) {
        maxUpdateInc = [NSNumber numberWithLongLong:LONG_LONG_MIN];
    }
    chain.updateInc = [NSNumber numberWithLongLong:maxUpdateInc.longLongValue + 1];
    NSLog(@"%@",  chain.updateInc);
    [coreData save];
}

- (void) updateLastViewedTime:(NSDate *)lastViewedTime chain:(AGChain*)chain
{
    chain.chainMessage.lastViewedTime = lastViewedTime;
    [coreData save];
}

- (NSArray*) getNewChainIdsForUpdate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:newChainEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain == nil || updateCount > chain.updateCount"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"chainId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:MaxNewChainIds];
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

- (AGNewChain*) getNextNewChainForChainMessage
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:newChainEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain != nil && updateCount <= chain.updateCount"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNewChain *newChain = nil;
    if (array.count) {
        newChain = [array lastObject];
    }
    return newChain;
}

- (void) addNewChains:(NSArray *)chains
{
    AGAccount *account = [AGAppDirector appDirector].account;
    for (AGChain *chain in chains) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        //[dict setObject:chain forKey:@"chain"];
        [dict setObject:account.accountId forKey:@"accountId"];
        [dict setObject:chain.chainId forKey:@"chainId"];
        [dict setObject:chain.updateInc forKey:@"updateInc"];
        AGNewChain *newChain = (AGNewChain *)[coreData saveOrUpdate:dict withEntityName:@"AGNewChain"];
        newChain.chain = chain;
    }
    [coreData save];
}

- (void) removeNewChain:(AGNewChain *)newChain oldUpdateInc:(NSNumber*)updateInc
{
    if ([newChain.updateInc isEqualToNumber:updateInc] && newChain.chain != nil && newChain.updateCount.intValue <= newChain.chain.updateCount.intValue) {
        [coreData remove:newChain];
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainEntityDescription];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *deletedArray = [NSMutableArray arrayWithCapacity:array.count];
    for (AGChain *chain in array) {
        if (chain.deleted.boolValue == YES) {
            [deletedArray addObject:chain];
            [[AGControllerUtils controllerUtils].chainMessageController viewedChainMessagesForChain:chain];
        }
    }
    [coreData removeAll:deletedArray];
}


@end
