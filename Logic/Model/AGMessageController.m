//
//  AGMessageController.m
//  Airogami
//
//  Created by Tianhu Yang on 8/16/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGMessageController.h"
#import "AGCoreData.h"
#import "AGManagerUtils.h"
#import "AGAccountStat.h"
#import "AGPlane.h"
#import "AGControllerUtils.h"
#import "AGAppDirector.h"

static int MessageLimit = 10;
static int DeleteLimit = 1;

@interface AGMessageController()
{
     AGCoreData *coreData;
    NSEntityDescription *messageEntityDescription;
}

@end

@implementation AGMessageController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        messageEntityDescription = [NSEntityDescription entityForName:@"AGMessage" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}

//for the opposite messages
- (NSMutableArray*) saveMessages:(NSArray*)jsonArray plane:(AGPlane*) plane
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGMessage"];
    for (AGMessage *message in array) {
        message.plane = plane;
    }
    //update neoMsgId
    AGMessage *message = array.lastObject;
    if (message) {
        plane.neoMsgId = message.messageId;
    }
    [coreData save];
    return array;
}
//for my message
- (AGMessage*) saveMessage:(NSDictionary*)jsonDictionary
{
    AGMessage *message = (AGMessage *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGMessage"];
    [coreData save];
    return message;
}

- (void) updateMessagesCount:(AGPlane*)plane
{
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    int count = [self getUnreadMessageCountForPlane:plane.planeId];
    accountStat.unreadMessagesCount = [NSNumber numberWithInt:accountStat.unreadMessagesCount.intValue + count - plane.unreadMessagesCount.intValue];
    plane.unreadMessagesCount = [NSNumber numberWithInt:count];
    [[AGCoreData coreData] save];
}

- (int) updateMessagesCountForPlane:(AGPlane*)plane
{
    int count = 0;
    if (plane.status.shortValue == AGPlaneStatusReplied) {
        count = [self getUnreadMessageCountForPlane:plane.planeId];
    }
    plane.unreadMessagesCount = [NSNumber numberWithInt:count];
    return count;
}

//descending

- (NSDictionary*) getMessagesForPlane:(NSNumber *)planeId startId:(NSNumber *)startId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:messageEntityDescription];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane.planeId = %@ and messageId > 0 and (%@ = nil or messageId < %@)", planeId, startId, startId];
    [fetchRequest setPredicate:predicate];
    //
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    //
    [fetchRequest setFetchLimit:MessageLimit + 1];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!array) {
        array = [NSArray array];
    }
    NSNumber *more = [NSNumber numberWithBool:array.count > MessageLimit];
    return [NSDictionary dictionaryWithObjectsAndKeys:array, @"messages", more, @"more", nil];
}

- (int) getUnreadMessageCountForPlane:(NSNumber *)planeId
{
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:messageEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane.planeId = %@ and account.accountId != %@ and messageId > plane.viewedMsgId", planeId, accountId, accountId, accountId];
    [fetchRequest setPredicate:predicate];
    //expression
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"messageId"];
    NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"count"];
    [expressionDescription setExpression:countExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    //
    int count = 0;
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array.count) {
        NSNumber *number = [[array objectAtIndex:0] objectForKey:@"count"];
        count = number.intValue;
    }
    return count;
}

-(NSNumber*) viewedMessagesForPlane:(AGPlane*)plane
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSNumber *lastMsgId = nil;
    //old
    AGMessage *message = [[AGControllerUtils controllerUtils].planeController recentMessageForPlane:plane.planeId];
    if (message) {
        if ([account.accountId isEqual:plane.accountByOwnerId.accountId]) {
            plane.viewedMsgId = message.messageId;
            if (message.messageId.longLongValue > plane.lastMsgIdOfO.longLongValue) {
                lastMsgId = message.messageId;
            }
        }
        else{
            plane.viewedMsgId = message.messageId;
            if (message.messageId.longLongValue > plane.lastMsgIdOfT.longLongValue) {
                lastMsgId = message.messageId;
            }
        }
    }
    [coreData save];
    //new
    [self updateMessagesCount:plane];
    return lastMsgId;
}

//return updated
-(BOOL) viewedMessagesForPlane:(AGPlane*)plane lastMsgId:(NSNumber*)lastMsgId
{
    BOOL updated = NO;
    if (plane.viewedMsgId.longLongValue < lastMsgId.longLongValue) {
        plane.viewedMsgId = lastMsgId;
        updated = YES;
    }
    if (updated) {
        [coreData save];
        [self updateMessagesCount:plane];
    }
    return updated;
}

//ascending
- (NSArray*) getUnsentMessagesForPlane:(NSNumber *)planeId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:messageEntityDescription];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane.planeId = %@ and messageId = -1", planeId];
    [fetchRequest setPredicate:predicate];
    //
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    //
    [fetchRequest setFetchLimit:MessageLimit];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!array) {
        array = [NSArray array];
    }
    return array;
}

- (AGMessage*) getNextUnsentMessage
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:messageEntityDescription];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = -1"];
    [fetchRequest setPredicate:predicate];
    //
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    //
    [fetchRequest setFetchLimit:1];
    //
    AGMessage* message = nil;
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array.count) {
        message = array.lastObject;
    }
    return message;
}

-(BOOL) clearPlane:(AGPlane*)plane clearMsgId:(NSNumber*)clearMsgId
{
    [self viewedMessagesForPlane:plane lastMsgId:clearMsgId];
    //
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:messageEntityDescription];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId <= %@ && messageId > 0 && plane.planeId == %@", clearMsgId, plane.planeId];
    [fetchRequest setPredicate:predicate];
    //
    [fetchRequest setFetchLimit:DeleteLimit];
    //
    BOOL updated = NO;
    while (true) {
        NSError *error;
        NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (array.count) {
            [coreData removeAll:array];
            updated = YES;
        }
        else{
            break;
        }
    }
    plane.clearMsgId = clearMsgId;
    [coreData save];
    
    //
    return updated;
}

@end
