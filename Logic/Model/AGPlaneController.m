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
    NSEntityDescription *entityDescription;
}

@end

@implementation AGPlaneController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        entityDescription = [NSEntityDescription entityForName:@"AGPlane" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}


- (NSMutableArray*) savePlanes:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGPlane"];
    for (AGPlane  *plane in array) {
        plane.accountByTargetId = [AGManagerUtils managerUtils].accountManager.account;
        //for receive planes
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
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d and accountByTargetId.accountId = %@", AGPlaneStatusNew, account.accountId];
    [fetchRequest setPredicate:predicate];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"updateInc"];
    NSExpression *maxUpdatedTimeExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxUpdateInc"];
    [expressionDescription setExpression:maxUpdatedTimeExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    //[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSNumber *updateInc = nil;
    if (error == nil && array.count) {
        updateInc = [[array objectAtIndex:0] objectForKey:@"maxUpdateInc"];
    }
    return updateInc;
}

- (NSArray*) getAllPlanesForCollect
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
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
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d and (accountByOwnerId.accountId = %@ or accountByTargetId.accountId = %@)", AGPlaneStatusReplied, account.accountId, account.accountId];
    [fetchRequest setPredicate:predicate];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"updateInc"];
    NSExpression *maxUpdatedTimeExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxUpdateInc"];
    [expressionDescription setExpression:maxUpdatedTimeExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    //[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSNumber *updateInc = nil;
    if (error == nil && array.count) {
        updateInc = [[array objectAtIndex:0] objectForKey:@"maxUpdateInc"];
    }
    return updateInc;
}

- (NSArray*) getAllPlanesForChat
{
    AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
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


@end
