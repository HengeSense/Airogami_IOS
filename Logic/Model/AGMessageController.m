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

static int MessageLimit = 100;

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

- (NSArray*) getMessagesForPlane:(NSNumber *)planeId startId:(NSNumber *)startId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:messageEntityDescription];
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plane.planeId = %@ and (%@ = nil or messageId < %@)", planeId, startId, startId];
    [fetchRequest setPredicate:predicate];
    //
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO];
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


@end
