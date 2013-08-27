//
//  AGNotificationCenter.m
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGNotificationCenter.h"

NSString *AGNotificationCollected = @"notification.collected";
NSString *AGNotificationReceive= @"notification.receive";
NSString *AGNotificationGetCollected= @"notification.getreceived";

NSString *AGNotificationObtained = @"notification.obtained";
NSString *AGNotificationObtain = @"notification.obtain";
NSString *AGNotificationGetObtained = @"notification.getobtained";


@implementation AGNotificationCenter

+ (AGNotificationCenter*) notificationCenter
{
    static AGNotificationCenter *notificationCenter;
    if (notificationCenter == nil) {
        notificationCenter = [[AGNotificationCenter alloc] init];
    }
    return notificationCenter;
}

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        //collect
        [notificationCenter addObserver:self selector:@selector(receive:) name:AGNotificationReceive object:nil];
        [notificationCenter addObserver:self selector:@selector(collected) name:AGNotificationGetCollected object:nil];
        //obtain planes
        [notificationCenter addObserver:self selector:@selector(obtain:) name:AGNotificationObtain object:nil];
        [notificationCenter addObserver:self selector:@selector(obtained) name:AGNotificationGetObtained object:nil];
    }
    return self;
}

/*- (void) receive:(NSNotification*) notification
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
            NSArray *planes = [result objectForKey:@"planes"];
            if (planes.count) {
                [self collectedPlanes];
            }
            
        }
    }];
}

- (void) collected
{
    NSArray *planes = [[AGControllerUtils controllerUtils].planeController getAllPlanesForCollect];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:planes, @"planes", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollectedPlanes object:self userInfo:dict];
    
}

- (void) obtain:(NSNotification*) notification
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
            else{
                NSDictionary *dict = [NSDictionary dictionary];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AGNotificationObtainMessages object:self userInfo:dict];
            }
            NSArray *array = [result objectForKey:@"planes"];
            
            if (array.count) {
                [self obtainedPlanes];
            }
            
            
        }
    }];
}

- (void) obtained
{
    NSArray *planes = [[AGControllerUtils controllerUtils].planeController getAllPlanesForChat];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:planes, @"planes", @"reset", @"action", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
    
}*/

@end
