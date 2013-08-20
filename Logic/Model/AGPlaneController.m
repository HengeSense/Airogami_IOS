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
}

@end

@implementation AGPlaneController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        planeEntityDescription = [NSEntityDescription entityForName:@"AGPlane" inManagedObjectContext:coreData. managedObjectContext];
        messageEntityDescription = [NSEntityDescription entityForName:@"AGMessage" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}


- (NSMutableArray*) savePlanes:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGPlane"];
    for (AGPlane *plane in array) {
        if (plane.isNew == nil) {
            plane.isNew = [NSNumber numberWithBool:YES];
        }
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
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d and accountByTargetId.accountId = %@", AGPlaneStatusNew, account.accountId];
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
        predicate = [NSPredicate predicateWithFormat:@"status = %d and accountByTargetId.accountId = %@ and updateInc = 0", AGPlaneStatusNew, account.accountId];
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

- (NSArray*) getAllPlanesForCollect
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d and accountByTargetId.accountId = %@", AGPlaneStatusNew, account.accountId];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending:NO];
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
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d and (accountByOwnerId.accountId = %@ or accountByTargetId.accountId = %@)", AGPlaneStatusReplied, account.accountId, account.accountId];
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
        predicate = [NSPredicate predicateWithFormat:@"status = %d and (accountByOwnerId.accountId = %@ or accountByTargetId.accountId = %@) and updateInc = 0", AGPlaneStatusReplied, account.accountId, account.accountId];
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

- (NSArray*) getAllPlanesForChat
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d and (accountByOwnerId.accountId = %@ or accountByTargetId.accountId = %@)", AGPlaneStatusReplied, account.accountId, account.accountId];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        array = [NSArray array];
    }
    return array;
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

- (NSArray*) getAllNewPlanesForChat
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:planeEntityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d and (accountByOwnerId.accountId = %@ or accountByTargetId.accountId = %@) and isNew = YES", AGPlaneStatusReplied, account.accountId, account.accountId];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateInc" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        array = [NSArray array];
    }
    return array;
}


@end
