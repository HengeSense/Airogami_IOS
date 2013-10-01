//
//  AGChainMessageController.m
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChainMessageController.h"
#import "AGCoreData.h"
#import "AGManagerUtils.h"
#import "AGAccountStat.h"
#import "AGControllerUtils.h"

static const int ChainMessageLimit = 10;

@interface AGChainMessageController()
{
    AGCoreData *coreData;
    NSEntityDescription *chainMessageEntityDescription;
}

@end

@implementation AGChainMessageController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        chainMessageEntityDescription = [NSEntityDescription entityForName:@"AGChainMessage" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}

- (AGChainMessage*) saveChainMessage:(NSDictionary*)jsonDictionary forChain:(AGChain*)chain
{
    AGChainMessage *chainMessage = (AGChainMessage *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGChainMessage"];
    if (chainMessage) {
        chainMessage.chain = chain;
    }
    [coreData save];
    return chainMessage;
}

- (AGChainMessage*) updateChainMessage:(NSDictionary*)jsonDictionary forChain:(AGChain*)chain
{
    AGChainMessage *chainMessage = (AGChainMessage *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGChainMessage"];
    if (chainMessage) {
        chainMessage.chain = chain;
        chain.collected = [NSNumber numberWithBool:chainMessage.status.intValue == AGChainMessageStatusNew];
    }
    [coreData save];
    return chainMessage;
}

- (AGChainMessage*) saveChainMessage:(NSDictionary*)jsonDictionary
{
    AGChainMessage *chainMessage = (AGChainMessage *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGChainMessage"];
    [coreData save];
    return chainMessage;
}

- (NSMutableArray*) saveChainMessages:(NSArray*)jsonArray chain:(AGChain*) chain
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGChainMessage"];
    for (AGChainMessage *chainMessage in array) {
        chainMessage.chain = chain;
    }
    [coreData save];
    return array;
}

//descending; for chat
- (NSDictionary*) getChainMessagesForChain:(NSNumber *)chainId startTime:(NSDate *)startTime
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainMessageEntityDescription];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain.chainId = %@ and (%@ = nil or createdTime < %@)", chainId, startTime, startTime];
    [fetchRequest setPredicate:predicate];
    //
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    //
    [fetchRequest setFetchLimit:ChainMessageLimit + 1];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!array) {
        array = [NSArray array];
    }
    NSNumber *more = [NSNumber numberWithBool:array.count > ChainMessageLimit];
    return [NSDictionary dictionaryWithObjectsAndKeys:array, @"chainMessages", more, @"more", nil];
}

//descending; for collect
- (NSArray*) getChainMessagesForChain:(NSNumber *)chainId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainMessageEntityDescription];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain.chainId = %@ and status = %d", chainId, AGChainMessageStatusReplied];
    [fetchRequest setPredicate:predicate];
    //
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!array) {
        array = [NSArray array];
    }
    return array;
}

- (AGChainMessage*) getChainMessageForChain:(NSNumber *)chainId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:chainMessageEntityDescription];
    //
    NSNumber *accountId = [AGManagerUtils managerUtils].accountManager.account.accountId;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain.chainId = %@ and account.accountId = %@", chainId, accountId];
    [fetchRequest setPredicate:predicate];
    //
    AGChainMessage *chainMessage = nil;
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array.count) {
        chainMessage = array.lastObject;
    }
    return chainMessage;
}

// this is for chat
- (int) getUnreadChainMessageCountForChain:(NSNumber *)chainId
{
    AGChainMessage *chainMessage = [self getChainMessageForChain:chainId];
    int count = 0;
    if (chainMessage) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:chainMessageEntityDescription];
        [fetchRequest setResultType:NSDictionaryResultType];
        //
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chain.chainId = %@ and createdTime > %@ and status >= %d", chainId, chainMessage.lastViewedTime, AGChainMessageStatusReplied];
        [fetchRequest setPredicate:predicate];
        //expression
        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"status"];
        NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        [expressionDescription setName:@"count"];
        [expressionDescription setExpression:countExpression];
        [expressionDescription setExpressionResultType:NSInteger64AttributeType];
        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
        //
        
        NSError *error;
        NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (array.count) {
            NSNumber *number = [[array objectAtIndex:0] objectForKey:@"count"];
            count = number.intValue;
        }
    }
    
    return count;
}

//for chat
-(void) viewedChainMessagesForChain:(AGChain *)chain
{
    AGChainMessage *chainMessage = [self getChainMessageForChain:chain.chainId];
    if (chainMessage) {
        AGAccountStat *accountStat = chainMessage.account.accountStat;
        AGChainMessage *cm = [[AGControllerUtils controllerUtils].chainController recentChainMessage:chain.chainId];
        if (cm) {
            chainMessage.lastViewedTime = cm.createdTime;
        }
        [coreData save];
        int newCount = [self getUnreadChainMessageCountForChain:chain.chainId];
        int count = accountStat.unreadChainMessagesCount.intValue + newCount - chainMessage.unreadChainMessagesCount.intValue;
        if(count < 0){
            count = 0;
        }
        accountStat.unreadChainMessagesCount = [NSNumber numberWithInt:count];
        chainMessage.unreadChainMessagesCount = [NSNumber numberWithInt:newCount];
        [coreData save];
    }
}

@end
