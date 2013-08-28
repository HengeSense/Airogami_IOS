//
//  AGNotificationCenter.m
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGNotificationCenter.h"
#import "AGControllerUtils.h"
#import "AGUtils.h"

NSString *AGNotificationCollected = @"notification.collected";
NSString *AGNotificationReceive= @"notification.receive";
NSString *AGNotificationGetCollected= @"notification.getcollected";

NSString *AGNotificationObtained = @"notification.obtained";
NSString *AGNotificationObtain = @"notification.obtain";
NSString *AGNotificationGetObtained = @"notification.getobtained";

@interface AGNotificationCenter()
{
    NSArray *planes;
    NSArray *chains;
}

@end

@implementation AGNotificationCenter

+ (AGNotificationCenter*) notificationCenter
{
    static AGNotificationCenter *notificationCenter;
    if (notificationCenter == nil) {
        notificationCenter = [[AGNotificationCenter alloc] init];
        //maybe redundent
        [AGPlaneNotification planeNotification];
        [AGChainNotification chainNotification];
    }
    return notificationCenter;
}

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        //collect
        //[notificationCenter addObserver:self selector:@selector(receive:) name:AGNotificationReceive object:nil];
        [notificationCenter addObserver:self selector:@selector(getCollected:) name:AGNotificationGetCollected object:nil];
        //obtain planes
        //[notificationCenter addObserver:self selector:@selector(obtain:) name:AGNotificationObtain object:nil];
        [notificationCenter addObserver:self selector:@selector(getObtained) name:AGNotificationGetObtained object:nil];
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
}*/

- (void) getCollected:(NSNotification*)notification
{
    NSString *havePlanes = [notification.userInfo objectForKey:@"planes"];
    NSString *haveChains = [notification.userInfo objectForKey:@"chains"];
    if (havePlanes) {
        planes = [[AGControllerUtils controllerUtils].planeController getAllPlanesForCollect];
    }
    if (haveChains) {
        chains = [[AGControllerUtils controllerUtils].chainController getAllChainsForCollect];
    }
    NSArray *collects = [AGUtils mergeSortedArray:planes second:chains usingBlock:^int(id obj1, id obj2) {
        AGPlane *plane = obj1;
        AGChain *chain = obj2;
        return [plane.updatedTime compare:chain.updatedTime];
    }];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:collects, @"collects", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollected object:self userInfo:dict];
    
}

- (void) startTimer:(BOOL)start {
    static NSTimer *timer;
    if (start) {
        if (timer == nil) {
            timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                     target:self
                                                   selector:@selector(tick:)
                                                   userInfo:nil
                                                    repeats:YES];
        }
    }
    else{
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    }
    
    
}

- (void) tick:(NSTimer *) timer {
    //do something here..
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainPlanes object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationReceivePlanes object:nil userInfo:nil];
}


@end
