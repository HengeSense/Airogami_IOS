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

@interface AGChainController()
{
    AGCoreData *coreData;
    NSEntityDescription *chainEntityDescription;
    NSEntityDescription *chainMessageEntityDescription;
}

@end

@implementation AGChainController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        chainEntityDescription = [NSEntityDescription entityForName:@"AGChain" inManagedObjectContext:coreData. managedObjectContext];
        chainMessageEntityDescription = [NSEntityDescription entityForName:@"AGChainMessage" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}

- (NSMutableArray*) saveChains:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGChain"];
    for (AGChain *chain in array) {
        if (chain.isNew == nil) {
            chain.isNew = [NSNumber numberWithBool:YES];
        }
    }
    [coreData save];
    return array;
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

- (NSArray*) getAllNewChainsForChat
{
    return [self getAllChains:3];
}

//1 = collect; 2 = chat; 3 = new chat
- (NSArray*) getAllChains:(int)type
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(chainMessages, $chainMessage, $chainMessage.account.accountId = %@ && $chainMessage.status = %d).@count != 0 && (account.accountId != %@ || passCount > 0) and (%d != 3 or isNew = YES)", account.accountId, type == 1 ? AGChainMessageStatusNew : AGChainMessageStatusReplied, account.accountId, type];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending: type == 3];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        array = [NSArray array];
    }
    return array;
}


- (NSNumber*)recentChainUpdateIncForChat
{
    return [self recentChainUpdateInc:NO];
}

- (NSNumber*)recentChainUpdateInc:(BOOL)forCollect
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(chainMessages, $chainMessage, $chainMessage.account.accountId = %@ && $chainMessage.status = %d).@count != 0 && (account.accountId != %@ || passCount > 0)", account.accountId, forCollect ? AGChainMessageStatusNew : AGChainMessageStatusReplied, account.accountId];
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
        predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(chainMessages, $chainMessage, $chainMessage.account.accountId = %@ && $chainMessage.status = %d).@count != 0 && (account.accountId != %@ || passCount > 0) and updateInc = 0", account.accountId, forCollect ? AGChainMessageStatusNew : AGChainMessageStatusReplied, account.accountId];
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

- (AGChainMessage*) recentChainMessageForChat:(NSNumber*)chainId
{
    return [self recentChainMessage:NO chainId:chainId];
}

- (AGChainMessage*) recentChainMessageForCollect:(NSNumber*)chainId
{
    return [self recentChainMessage:YES chainId:chainId];
}

- (AGChainMessage*) recentChainMessage:(BOOL) forCollect chainId:(NSNumber*)chainId
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainMessageEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain.chainId = %@ and (%d = 0 || account.accountId != %@)", chainId, forCollect, account.accountId];
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
    [coreData save];
}

@end
