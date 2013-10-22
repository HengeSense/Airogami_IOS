//
//  AGPlaneController.m
//  Airogami
//
//  Created by Tianhu Yang on 8/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPlaneController.h"
#import "AGPlane.h"
#import "AGMessage.h"
#import "AGManagerUtils.h"
#import "AGAccount.h"
#import "AGAccountStat.h"
#import "AGControllerUtils.h"
#import "AGAccountStat.h"
#import "AGAppDirector.h"

static const int MaxNeoPlanes = 50;

@interface AGPlaneController ()
{
    AGCoreData *coreData;
    NSEntityDescription *planeEntityDescription;
    NSEntityDescription *messageEntityDescription;
    NSEntityDescription *neoPlaneEntityDescription;
}

@end

@implementation AGPlaneController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        planeEntityDescription = [NSEntityDescription entityForName:@"AGPlane" inManagedObjectContext:coreData. managedObjectContext];
        messageEntityDescription = [NSEntityDescription entityForName:@"AGMessage" inManagedObjectContext:coreData. managedObjectContext];
        neoPlaneEntityDescription = [NSEntityDescription entityForName:@"AGNeoPlane" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}


- (void) markDeleted:(AGPlane*)plane
{
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    if ([plane.accountByOwnerId.accountId isEqualToNumber:accountId]) {
        plane.deletedByO = [NSNumber numberWithBool:YES];
    }
    else{
        plane.deletedByT = [NSNumber numberWithBool:YES];
    }
    [coreData save];
}

- (void) resetForSync
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSSet *planes = account.planesForOwnerId;
    [planes makeObjectsPerformSelector:@selector(setDeleted:) withObject:[NSNumber numberWithBool:YES]];
    planes = account.planesForTargetId;
    [planes makeObjectsPerformSelector:@selector(setDeleted:) withObject:[NSNumber numberWithBool:YES]];
    [coreData save];
}

- (void) deleteForSync
{
    AGAccount *account = [AGAppDirector appDirector].account;
    AGAccountStat *accountStat = account.accountStat;
    int unreadMessagesCount = 0;
    //
    NSSet *planes = account.planesForOwnerId;
    NSMutableArray *deletedArray = [NSMutableArray arrayWithCapacity:planes.count];
    for (AGPlane *plane in planes) {
        if (plane.deleted.boolValue == YES) {
            [deletedArray addObject:plane];
            //[[AGControllerUtils controllerUtils].messageController viewedMessagesForPlane:plane];
        }
        else{
            unreadMessagesCount += [[AGControllerUtils controllerUtils].messageController updateMessagesCountForPlane:plane];
        }
    }
    [coreData removeAll:deletedArray];

    //
    planes = account.planesForTargetId;
    [deletedArray removeAllObjects];
    for (AGPlane *plane in planes) {
        if (plane.deleted.boolValue == YES) {
            [deletedArray addObject:plane];
        }else{
            unreadMessagesCount += [[AGControllerUtils controllerUtils].messageController updateMessagesCountForPlane:plane];
        }
    }
    accountStat.unreadMessagesCount = [NSNumber numberWithInt:unreadMessagesCount];
    [coreData removeAll:deletedArray];
}

-(void) initPlane:(AGPlane*)plane
{
    if (plane) {
        NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
        if ([accountId isEqualToNumber:plane.accountByOwnerId.accountId]) {
            if (plane.neoMsgId.longLongValue == 0) {
                plane.neoMsgId = plane.lastMsgIdOfO;
            }
            if (plane.viewedMsgId.longLongValue == 0) {
                plane.viewedMsgId = plane.lastMsgIdOfO;
            }
            
            if (plane.lastMsgId.longLongValue == 0) {
                plane.lastMsgId = plane.lastMsgIdOfT;
            }
            
        }
        else{
            if (plane.neoMsgId.longLongValue == 0) {
                plane.neoMsgId = plane.lastMsgIdOfT;
            }
            if (plane.viewedMsgId.longLongValue == 0) {
                plane.viewedMsgId = plane.lastMsgIdOfT;
            }
            
            if (plane.lastMsgId.longLongValue == 0) {
                plane.lastMsgId = plane.lastMsgIdOfO;
            }
        }
        AGNeoPlane *neoPlane = (AGNeoPlane *)[coreData findById:plane.planeId withEntityName:@"AGNeoPlane"];
        if (neoPlane != nil && neoPlane.plane == nil) {
            neoPlane.plane = plane;
        }
    }
    
}

//for change status error
- (AGPlane*) savePlane:(NSDictionary*)planeJson
{
    AGPlane *plane = (AGPlane*)[coreData saveOrUpdate:planeJson withEntityName:@"AGPlane"];
    [self initPlane:plane];
    [coreData save];
    return plane;
}

- (NSMutableArray*) savePlanes:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGPlane"];
    for (AGPlane *plane in array) {
        [self initPlane:plane];
        //for pickup planes
        for (AGMessage *message in plane.messages) {
            message.plane = plane;
            if (message.account == nil) {
                 message.account = plane.accountByOwnerId;
            }
        }
        
    }
    [coreData save];
    return array;
}

- (NSMutableArray*) saveNeoPlanes:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGNeoPlane"];
    long long max = LONG_LONG_MIN;
    for (AGNeoPlane *neoPlane in array) {
        if (neoPlane.updateInc.longLongValue > max) {
            max = neoPlane.updateInc.longLongValue;
        }
        if (neoPlane.plane == nil) {
            AGPlane *plane = (AGPlane *)[coreData findById:neoPlane.planeId withEntityName:@"AGPlane"];
            if (plane != nil) {
                neoPlane.plane = plane;
            }
        }
    }
    
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    if (max > accountStat.planeUpdateInc.longLongValue) {
        accountStat.planeUpdateInc = [NSNumber numberWithLongLong:max];
    }
    [coreData save];
    return array;
}

- (NSMutableArray*) saveOldPlanes:(NSArray*)jsonArray
{
    for(NSMutableDictionary *oldPlaneJson in jsonArray){
        [oldPlaneJson setObject:[NSNumber numberWithBool:NO] forKey:@"deleted"];
    }
    NSMutableArray *array = [coreData updateArray:jsonArray withEntityName:@"AGPlane"];
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    for (AGPlane *plane in array) {
        if ([accountId isEqualToNumber:plane.accountByOwnerId.accountId]) {
            plane.viewedMsgId = plane.lastMsgIdOfO;
        }
        else{
            plane.viewedMsgId = plane.lastMsgIdOfT;
        }
    }
    [coreData save];
    return array;
}

- (NSArray*) getAllPlanesForCollect
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messages.@count > 0 and status = %d and accountByTargetId.accountId = %@", AGPlaneStatusNew, account.accountId];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedTime" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
     NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        array = [NSArray array];
    }
    return array;
}


-(void) increaseUpdateInc
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSNumber *updateInc = account.accountStat.planeUpdateInc;
    if (updateInc == nil) {
        updateInc = [NSNumber numberWithLongLong:LONG_LONG_MIN];
    }
    updateInc = [NSNumber numberWithLongLong:updateInc.longLongValue + 1];
    account.accountStat.planeUpdateInc = updateInc;
    [coreData save];
}

- (void) updateMessage:(AGPlane*)plane
{
    AGMessage *message = [self recentMessageForPlane:plane.planeId];
    plane.message = message;
    plane.updatedTime = message.createdTime;
    [coreData save];
}

- (void) updateLike:(AGPlane*)plane createdTime:(NSDate *)createdTime
{
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    plane.updatedTime = createdTime;
    if ([accountId isEqualToNumber:plane.accountByOwnerId.accountId]) {
        plane.likedByO = [NSNumber numberWithBool:YES];
    }
    else{
        plane.likedByT = [NSNumber numberWithBool:YES];
    }
    [coreData save];
}

- (AGMessage*) recentMessageForPlane:(NSNumber*)planeId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:messageEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane.planeId = %@ and messageId != -1", planeId];
    [fetchRequest setPredicate:predicate];
    //
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"messageId"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxMessageId"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGMessage *message = nil;
    if (array.count) {
        NSNumber *maxMessageId = [[array objectAtIndex:0] objectForKey:@"maxMessageId"];
        fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:messageEntityDescription];
        //
        predicate = [NSPredicate predicateWithFormat:@"messageId = %@", maxMessageId];
        [fetchRequest setPredicate:predicate];
        array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (array.count) {
            message = [array objectAtIndex:0];
        }
    }
    return message;
}

- (NSNumber*)recentUpdateInc
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSNumber *updateInc = account.accountStat.planeUpdateInc;
    if (updateInc == nil) {
        updateInc = [NSNumber numberWithLongLong:LONG_LONG_MIN];
    }
    return updateInc;
}


- (AGNeoPlane*) getNextNeoPlaneForChat
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:neoPlaneEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountId = %@", account.accountId];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNeoPlane *neoPlane = nil;
    if (array.count) {
        neoPlane = [array lastObject];
    }
    return neoPlane;
}

- (void) removeNeoPlane:(AGNeoPlane *)neoPlane
{
    AGPlane *plane = neoPlane.plane;
    //
    if (plane != nil && neoPlane.updateCount.intValue <= plane.updateCount.intValue && neoPlane.neoMsgId.longLongValue <= plane.neoMsgId.longLongValue) {
        [coreData remove:neoPlane];
    }
}

- (void) removeNeoPlanes:(NSArray *)neoPlanes
{
    for (AGNeoPlane *neoPlane in neoPlanes) {
        [self removeNeoPlane:neoPlane];
    }
}

- (NSArray*) getAllPlanesForChat
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"status = %d and ((accountByOwnerId.accountId = %@ and deletedByO = 0) or (accountByTargetId.accountId = %@ and deletedByT = 0))", AGPlaneStatusReplied, account.accountId, account.accountId];
    
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedTime" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        array = [NSArray array];
    }
    return array;
}

- (NSArray*) getNeoPlanesForUpdate
{

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:neoPlaneEntityDescription];
    //[fetchRequest setResultType:NSDictionaryResultType];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane == nil || updateCount > plane.updateCount"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"planeId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:MaxNeoPlanes];
    //
    //[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"planeId"]];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return array;
}

- (AGNeoPlane*) getNextNeoPlaneForMessages
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:neoPlaneEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane != nil && updateCount <= plane.updateCount && neoMsgId > plane.neoMsgId"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNeoPlane *neoPlane = nil;
    neoPlane = array.lastObject;
    return neoPlane;
}

- (AGPlane*) getNextUnviewedPlane
{
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((accountByOwnerId.accountId = %@ && deletedByO = 0 && viewedMsgId > lastMsgIdOfO) || (accountByTargetId.accountId = %@ && deletedByT = 0  && viewedMsgId > lastMsgIdOfT)) && status = %d", accountId, accountId, AGPlaneStatusReplied];
    [fetchRequest setPredicate:predicate];
    //
    [fetchRequest setFetchLimit:1];
    //
    AGPlane* plane = nil;
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array.count) {
        plane = array.lastObject;
    }
    return plane;
}

- (void) updateLastMsgId:(NSNumber*)lastMsgId plane:(AGPlane*) plane
{
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    if ([plane.accountByOwnerId.accountId isEqualToNumber:accountId]) {
        plane.lastMsgIdOfO = lastMsgId;
    }
    else{
        plane.lastMsgIdOfT = lastMsgId;
    }
    [coreData save];
}


@end
