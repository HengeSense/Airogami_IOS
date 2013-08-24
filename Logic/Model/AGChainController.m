//
//  AGChainController.m
//  Airogami
//
//  Created by Tianhu Yang on 8/21/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChainController.h"
#import "AGCoreData.h"
#import "AGChainMessageId.h"

@interface AGChainController()
{
    AGCoreData *coreData;
    NSEntityDescription *chainEntityDescription;
    NSEntityDescription *chainMessageEntityDescription;
}

@end

@implementation AGChainController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        chainEntityDescription = [NSEntityDescription entityForName:@"AGChain" inManagedObjectContext:coreData. managedObjectContext];
        chainMessageEntityDescription = [NSEntityDescription entityForName:@"AGChainMessage" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}

- (NSMutableArray*) saveChains:(NSArray*)jsonArray
{
    NSMutableArray *array = [coreData saveOrUpdateArray:jsonArray withEntityName:@"AGChain"];
    for (AGChain *chain in array) {
        if (chain.isNew == nil) {
            chain.isNew = [NSNumber numberWithBool:YES];
        }
    }
    [coreData save];
    return array;
}

@end
