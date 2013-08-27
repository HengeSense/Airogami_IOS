//
//  AGChainMessageController.m
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChainMessageController.h"
#import "AGCoreData.h"

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

- (AGChainMessage*) saveChainMessage:(NSDictionary*)jsonDictionary
{
    AGChainMessage *chainMessage = (AGChainMessage *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGChainMessage"];
    [coreData save];
    return chainMessage;
}

@end
