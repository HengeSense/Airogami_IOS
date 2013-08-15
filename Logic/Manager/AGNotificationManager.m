//
//  AGNotificationManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGNotificationManager.h"
#import "AGManagerUtils.h"
#import "AGControllerUtils.h"

NSString *AGNotificationCollectedPlanes = @"notification.collectedplanes";
NSString *AGNotificationReceivePlanes = @"notification.receiveplanes";

@interface AGNotificationManager()

@end

@implementation AGNotificationManager

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(receivePlanes:) name:AGNotificationReceivePlanes object:nil];
    }
    return self;
}

- (void) receivePlanes:(NSNotification*) notification
{
    NSNumber * start = [[AGControllerUtils controllerUtils].planeController recentPlaneUpdateIncForCollect];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:4];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    [[AGManagerUtils managerUtils].planeManager receivePlanes:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error == nil) {
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self receivePlanes:notification];
            }
        }
    }];
}

- (void) receiveChains
{
    
}

@end
