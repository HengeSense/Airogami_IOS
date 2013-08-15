//
//  AGPlaneController.m
//  Airogami
//
//  Created by Tianhu Yang on 8/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPlaneController.h"

@interface AGPlaneController ()
{
    AGCoreData *coreData;
}

@end

@implementation AGPlaneController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
    }
    return self;
}


- (NSMutableArray*) savePlanes:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGPlane"];
    [coreData save];
    return array;
}

- (NSNumber*)recentPlaneUpdateIncForCollect
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"AGPlane" inManagedObjectContext:coreData. managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %d", AGPlaneStatusNew];
    [fetchRequest setPredicate:predicate];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"updateInc"];
    NSExpression *maxUpdatedTimeExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxUpdateInc"];
    [expressionDescription setExpression:maxUpdatedTimeExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSNumber *updateInc = nil;
    if (error == nil && array.count) {
        updateInc = [[array objectAtIndex:0] objectForKey:@"maxUpdateInc"];
    }
    return updateInc;
}


@end
