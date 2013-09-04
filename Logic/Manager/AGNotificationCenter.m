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
        [notificationCenter addObserver:self selector:@selector(collectedPlanes:) name:AGNotificationCollectedPlanes object:nil];
        [notificationCenter addObserver:self selector:@selector(collectedChains:) name:AGNotificationCollectedChains object:nil];
        [notificationCenter addObserver:self selector:@selector(getCollected:) name:AGNotificationGetCollected object:nil];
        //obtain planes
        [notificationCenter addObserver:self selector:@selector(obtainedPlanes:) name:AGNotificationObtainedPlanes object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainedChains:) name:AGNotificationObtainedChains object:nil];
        [notificationCenter addObserver:self selector:@selector(getObtained:) name:AGNotificationGetObtained object:nil];
    }
    return self;
}

- (void) collectedPlanes:(NSNotification*) notification
{
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqual:@"one"]) {
        [self collected:notification.userInfo];
    }
    else{
        [self collectedContainPlanes:YES containChains:NO];
    }
}

- (void) collectedChains:(NSNotification*) notification
{
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqual:@"one"]) {
        [self collected:notification.userInfo];
    }
    else{
        [self collectedContainPlanes:NO containChains:YES];
    }
    
}

- (void) getCollected:(NSNotification*)notification
{
    NSString *containPlanes = [notification.userInfo objectForKey:@"planes"];
    NSString *containChains = [notification.userInfo objectForKey:@"chains"];
    
    [self collectedContainPlanes:containPlanes != nil containChains:containChains != nil];
}

- (void) collected:(NSDictionary*)dict
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollected object:self userInfo:dict];
}

- (void) collectedContainPlanes:(BOOL) containPlanes containChains:(BOOL)containChains
{
    if (containPlanes) {
        planes = [[AGControllerUtils controllerUtils].planeController getAllPlanesForCollect];
    }
    if (containChains) {
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


- (void) obtainedPlanes:(NSNotification*) notification
{
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqual:@"one"]) {
        [self obtained:notification.userInfo];
    }
    else{
        [self obtainedContainPlanes:YES containChains:NO];
    }
    
}

- (void) obtainedChains:(NSNotification*) notification
{
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqual:@"one"]) {
        [self obtained:notification.userInfo];
    }
    else{
        [self obtainedContainPlanes:NO containChains:YES];
    }
    
}

- (void) getObtained:(NSNotification*)notification
{
    NSString *containPlanes = [notification.userInfo objectForKey:@"planes"];
    NSString *containChains = [notification.userInfo objectForKey:@"chains"];
    
    [self obtainedContainPlanes:containPlanes != nil containChains:containChains != nil];
}

- (void) obtained:(NSDictionary*)dict
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtained object:self userInfo:dict];
}

- (void) obtainedContainPlanes:(BOOL) containPlanes containChains:(BOOL)containChains
{
    if (containPlanes) {
        planes = [[AGControllerUtils controllerUtils].planeController getAllPlanesForChat];
    }
    if (containChains) {
        chains = [[AGControllerUtils controllerUtils].chainController getAllChainsForChat];
    }
    NSArray *chats = [AGUtils mergeSortedArray:planes second:chains usingBlock:^int(id obj1, id obj2) {
        AGPlane *plane = obj1;
        AGChain *chain = obj2;
        return [plane.updatedTime compare:chain.updatedTime];
    }];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:chats, @"chats", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtained object:self userInfo:dict];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainChains object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationReceiveChains object:nil userInfo:nil];
}

//should run once open the program
- (void) obtainMessages
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainMessages object:self userInfo:dict];
    [notificationCenter postNotificationName:AGNotificationObtainChainMessages object:self userInfo:dict];
}

//should run once the program is active
- (void) resendMessages
{
    
}


@end
