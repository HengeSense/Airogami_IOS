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

static const int MaxNewPlaneIds = 50;

@interface AGPlaneController ()
{
    AGCoreData *coreData;
    NSEntityDescription *planeEntityDescription;
    NSEntityDescription *messageEntityDescription;
    NSEntityDescription *newPlaneEntityDescription;
}

@end

@implementation AGPlaneController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        planeEntityDescription = [NSEntityDescription entityForName:@"AGPlane" inManagedObjectContext:coreData. managedObjectContext];
        messageEntityDescription = [NSEntityDescription entityForName:@"AGMessage" inManagedObjectContext:coreData. managedObjectContext];
        newPlaneEntityDescription = [NSEntityDescription entityForName:@"AGNewPlane" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}

- (AGPlane*) savePlane:(NSDictionary*)planeJson
{
    AGPlane *plane = (AGPlane*)[coreData saveOrUpdate:planeJson withEntityName:@"AGPlane"];
    if (plane.ownerViewedMsgId.longLongValue == 0) {
        plane.ownerViewedMsgId = plane.lastMsgIdOfO;
    }
    if (plane.targetViewedMsgId.longLongValue == 0) {
        plane.targetViewedMsgId = plane.lastMsgIdOfT;
    }
    [coreData save];
    return plane;
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


- (NSMutableArray*) savePlanes:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGPlane"];
    for (AGPlane *plane in array) {
        if (plane.ownerViewedMsgId.longLongValue == 0) {
            plane.ownerViewedMsgId = plane.lastMsgIdOfO;
        }
        if (plane.targetViewedMsgId.longLongValue == 0) {
            plane.targetViewedMsgId = plane.lastMsgIdOfT;
        }
        //for pickup planes -9223372036854775785 9223372036854775808
        for (AGMessage *message in plane.messages) {
            message.plane = plane;
            if (message.account == nil) {
                 message.account = plane.accountByOwnerId;
            }
        }
        AGNewPlane *newPlane = (AGNewPlane *)[coreData findById:plane.planeId withEntityName:@"AGNewPlane"];
        if (newPlane != nil && newPlane.plane == nil) {
            newPlane.plane = plane;
        }
    }
    [coreData save];
    return array;
}

- (NSMutableArray*) saveNewPlanes:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGNewPlane"];
    long long max = LONG_LONG_MIN;
    for (AGNewPlane *newPlane in array) {
        if (newPlane.updateInc.longLongValue > max) {
            max = newPlane.updateInc.longLongValue;
        }
        if (newPlane.plane == nil) {
            AGPlane *plane = (AGPlane *)[coreData findById:newPlane.planeId withEntityName:@"AGPlane"];
            if (plane != nil) {
                newPlane.plane = plane;
            }
        }
    }
    
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    if (accountStat.planeUpdateInc == nil || max > accountStat.planeUpdateInc.longLongValue) {
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
    for (AGPlane *plane in array) {
        plane.ownerViewedMsgId = plane.lastMsgIdOfO;
        plane.targetViewedMsgId = plane.lastMsgIdOfT;
    }
    [coreData save];
    return array;
}

- (NSNumber*)recentPlaneUpdateIncForCollect
{
    return [self recentPlaneUpdateInc:YES];
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

- (NSNumber*)recentPlaneUpdateIncForChat
{
 return [self recentPlaneUpdateInc:NO];
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

- (void) increaseUpdateIncForChat:(AGPlane*)plane
{
    NSNumber *maxUpdateInc = [self recentPlaneUpdateIncForChat];
    if (maxUpdateInc == nil) {
        maxUpdateInc = [NSNumber numberWithLongLong:LONG_LONG_MIN];
    }
    //plane.updateInc = [NSNumber numberWithLongLong:maxUpdateInc.longLongValue + 1];
    [coreData save];
}

- (void) updateMessage:(AGPlane*)plane
{
    AGMessage *message = [self recentMessageForPlane:plane.planeId];
    plane.message = message;
    plane.updatedTime = message.createdTime;
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

- (NSNumber*)recentUpdateInc:(BOOL)forNewPlane
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = forNewPlane ? newPlaneEntityDescription : planeEntityDescription;
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    
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
    if (array.count) {
        updateInc = [[array objectAtIndex:0] objectForKey:@"maxUpdateInc"];
    }
    //check whether empty
    if (updateInc.longLongValue == 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"updateInc = 0"];
        
        fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:planeEntityDescription];
        fetchRequest.predicate = predicate;
        array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!array.count) {
            updateInc = nil;
        }
    }
    return updateInc;
}


- (NSNumber*)recentPlaneUpdateInc:(BOOL)forCollect
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate;
    if (forCollect) {
        predicate = [NSPredicate predicateWithFormat:@"status = %d and accountByTargetId.accountId = %@", AGPlaneStatusNew, account.accountId];
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"status >= %d and ((accountByOwnerId.accountId = %@ and deletedByO = 0) or (accountByTargetId.accountId = %@ and deletedByT = 0))", AGPlaneStatusReplied, account.accountId, account.accountId];
    }
    
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
        if (forCollect) {
            predicate = [NSPredicate predicateWithFormat:@"status = %d and accountByTargetId.accountId = %@ and updateInc = 0", AGPlaneStatusNew, account.accountId];
        }
        else{
            predicate = [NSPredicate predicateWithFormat:@"status = %d and ((accountByOwnerId.accountId = %@ and deletedByO = 0) or (accountByTargetId.accountId = %@ and deletedByT = 0)) and updateInc = 0", AGPlaneStatusReplied, account.accountId, account.accountId];
        }
        
        fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:planeEntityDescription];
        fetchRequest.predicate = predicate;
        array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!array.count) {
            updateInc = nil;
        }
    }
    return updateInc;
}

- (AGNewPlane*) getNextNewPlaneForChat
{
    AGAccount *account = [AGAppDirector appDirector].account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:newPlaneEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountId = %@", account.accountId];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNewPlane *newPlane = nil;
    if (array.count) {
        newPlane = [array lastObject];
    }
    return newPlane;
}

- (void) addNewPlanesForChat:(NSArray *)planes
{
    AGAccount *account = [AGAppDirector appDirector].account;
    for (AGPlane *plane in planes) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        //[dict setObject:plane forKey:@"plane"];
        [dict setObject:account.accountId forKey:@"accountId"];
        [dict setObject:plane.planeId forKey:@"planeId"];
        //[dict setObject:plane.updateInc forKey:@"updateInc"];
        AGNewPlane *newPlane = (AGNewPlane *)[coreData saveOrUpdate:dict withEntityName:@"AGNewPlane"];
        newPlane.plane = plane;
    }
    [coreData save];
}

- (void) removeNewPlaneForChat:(AGNewPlane *)newPlane oldUpdateInc:(NSNumber*)updateInc
{
    if (newPlane.updateInc.longLongValue == updateInc.longLongValue) {
        [coreData remove:newPlane];
    }

}

- (void) removeNewPlane:(AGNewPlane *)newPlane oldUpdateInc:(NSNumber*)updateInc
{
    if ([newPlane.updateInc isEqualToNumber:updateInc] && newPlane.plane != nil && newPlane.updateCount.intValue <= newPlane.plane.updateCount.intValue) {
        [coreData remove:newPlane];
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

- (NSArray*) getNewPlaneIdsForUpdate
{

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:newPlaneEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane == nil || updateCount > plane.updateCount"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"planeId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:MaxNewPlaneIds];
    //
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"planeId"]];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *planeIds = nil;
    if (array) {
        planeIds = [NSMutableArray arrayWithCapacity:array.count];
        for (NSDictionary *dict in array) {
            [planeIds addObject:[dict objectForKey:@"planeId"]];
        }
    }
    return planeIds;
}

- (AGNewPlane*) getNextNewPlaneForMessages
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:newPlaneEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane != nil && updateCount <= plane.updateCount"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNewPlane *newPlane = nil;
    if (array.count) {
        newPlane = [array lastObject];
    }
    return newPlane;
}

- (AGPlane*) getNextUnviewedPlane
{
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((accountByOwnerId.accountId = %@ && deletedByO = 0 && ownerViewedMsgId > lastMsgIdOfO) || (accountByTargetId.accountId = %@ && deletedByT = 0  && targetViewedMsgId > lastMsgIdOfT)) && status = %d", accountId, accountId, AGPlaneStatusReplied];
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
