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
    [coreData save];
    return plane;
}


- (NSMutableArray*) savePlanes:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGPlane"];
    for (AGPlane *plane in array) {
        //for receive planes -9223372036854775785 9223372036854775808
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

- (NSNumber*)recentPlaneUpdateIncForCollect
{
    return [self recentPlaneUpdateInc:YES];
}

- (NSArray*) getAllPlanesForCollect
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d and accountByTargetId.accountId = %@", AGPlaneStatusNew, account.accountId];
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

- (void) increaseUpdateIncForChat:(AGPlane*)plane
{
    NSNumber *maxUpdateInc = [self recentPlaneUpdateIncForChat];
    if (maxUpdateInc == nil) {
        maxUpdateInc = [NSNumber numberWithLongLong:LONG_LONG_MIN];
    }
    plane.updateInc = [NSNumber numberWithLongLong:maxUpdateInc.longLongValue + 1];
    [coreData save];
}


- (AGMessage*) recentMessageForPlane:(NSNumber*)planeId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:messageEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane.planeId = %@", planeId];
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

- (NSNumber*)recentPlaneUpdateInc:(BOOL)forCollect
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate;
    if (forCollect) {
        predicate = [NSPredicate predicateWithFormat:@"status = %d and accountByTargetId.accountId = %@", AGPlaneStatusNew, account.accountId];
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"status = %d and ((accountByOwnerId.accountId = %@ and deletedByOwner = 0) or (accountByTargetId.accountId = %@ and deletedByTarget = 0))", AGPlaneStatusReplied, account.accountId, account.accountId];
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
            predicate = [NSPredicate predicateWithFormat:@"status = %d and ((accountByOwnerId.accountId = %@ and deletedByOwner = 0) or (accountByTargetId.accountId = %@ and deletedByTarget = 0)) and updateInc = 0", AGPlaneStatusReplied, account.accountId, account.accountId];
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
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
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
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    for (AGPlane *plane in planes) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        //[dict setObject:plane forKey:@"plane"];
        [dict setObject:account.accountId forKey:@"accountId"];
        [dict setObject:plane.planeId forKey:@"planeId"];
        [dict setObject:plane.updateInc forKey:@"updateInc"];
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

- (NSArray*) getAllPlanesForChat
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"status = %d and ((accountByOwnerId.accountId = %@ and deletedByOwner = 0) or (accountByTargetId.accountId = %@ and deletedByTarget = 0))", AGPlaneStatusReplied, account.accountId, account.accountId];
    
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


@end
