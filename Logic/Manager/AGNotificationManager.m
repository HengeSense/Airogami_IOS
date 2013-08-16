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
NSString *AGNotificationGetCollectedPlanes = @"notification.getreceivedplanes";

NSString *AGNotificationObtainedPlanes = @"notification.obtainedplanes";
NSString *AGNotificationObtainPlanes = @"notification.obtainplanes";
NSString *AGNotificationGetObtainedPlanes = @"notification.getobtainedplanes";

@interface AGNotificationManager()

@end

@implementation AGNotificationManager

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        //collect
        [notificationCenter addObserver:self selector:@selector(receivePlanes:) name:AGNotificationReceivePlanes object:nil];
        [notificationCenter addObserver:self selector:@selector(collectedPlanes:) name:AGNotificationGetCollectedPlanes object:nil];
        //obtain
        [notificationCenter addObserver:self selector:@selector(obtainPlanes:) name:AGNotificationObtainPlanes object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainedPlanes:) name:AGNotificationGetObtainedPlanes object:nil];
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
            [self collectedPlanes];
        }
    }];
}

- (void) collectedPlanes
{
    NSArray *planes = [[AGControllerUtils controllerUtils].planeController getAllPlanesForCollect];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:planes, @"planes", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollectedPlanes object:self userInfo:dict];
    
}

- (void) obtainPlanes:(NSNotification*) notification
{
    NSNumber * start = [[AGControllerUtils controllerUtils].planeController recentPlaneUpdateIncForChat];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:4];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    [[AGManagerUtils managerUtils].planeManager obtainPlanes:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error == nil) {
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self obtainPlanes:notification];
            }
            [self obtainedPlanes];
        }
    }];
}

- (void) obtainedPlanes
{
    NSArray *planes = [[AGControllerUtils controllerUtils].planeController getAllPlanesForChat];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:planes, @"planes", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollectedPlanes object:self userInfo:dict];
    
}


@end
