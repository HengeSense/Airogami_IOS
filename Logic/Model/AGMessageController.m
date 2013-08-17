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

@interface AGMessageController()
{
     AGCoreData *coreData;
}

@end

@implementation AGMessageController

-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
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


@end
