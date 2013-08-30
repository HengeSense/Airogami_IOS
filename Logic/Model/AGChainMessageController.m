//
//  AGChainMessageController.m
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChainMessageController.h"
#import "AGCoreData.h"

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

@end
