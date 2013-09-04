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

static int MessageLimit = 10;

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

- (NSMutableArray*) saveMessages:(NSArray*)jsonArray plane:(AGPlane*) plane
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGMessage"];
    for (AGMessage *message in array) {
        message.plane = plane;
    }
    [coreData save];
    return array;
}

- (AGMessage*) saveMessage:(NSDictionary*)jsonDictionary
{
    AGMessage *message = (AGMessage *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGMessage"];
    [coreData save];
    return message;
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


@end
