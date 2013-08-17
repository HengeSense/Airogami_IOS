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
#import "AGNumber.h"

NSString *AGNotificationCollectedPlanes = @"notification.collectedplanes";
NSString *AGNotificationReceivePlanes = @"notification.receiveplanes";
NSString *AGNotificationGetCollectedPlanes = @"notification.getreceivedplanes";

NSString *AGNotificationObtainedPlanes = @"notification.obtainedplanes";
NSString *AGNotificationObtainPlanes = @"notification.obtainplanes";
NSString *AGNotificationGetObtainedPlanes = @"notification.getobtainedplanes";

NSString *AGNotificationObtainedMessages = @"notification.obtainedmessages";
NSString *AGNotificationObtainMessages = @"notification.obtainmessages";
NSString *AGNotificationGetObtainedMessages = @"notification.getobtainedmessages";

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
        //obtain planes
        [notificationCenter addObserver:self selector:@selector(obtainPlanes:) name:AGNotificationObtainPlanes object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainedPlanes:) name:AGNotificationGetObtainedPlanes object:nil];
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(obtainMessages:) name:AGNotificationObtainMessages object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainedMessages:) name:AGNotificationGetObtainedMessages object:nil];
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
            else{
                NSDictionary *dict = [NSDictionary dictionary];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AGNotificationObtainMessages object:self userInfo:dict];
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
    [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
    
}

- (void) obtainMessages:(NSNotification*) notification
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSArray *planes = [controllerUtils.planeController getAllNewPlanesForChat];
    [self obtainMessagesForPlanes:[planes mutableCopy]];
    
}

- (void) obtainMessagesForPlanes:(NSMutableArray *)array
{
    if (array.count) {
        AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
        AGPlane *plane = [array objectAtIndex:0];
        NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
        NSNumber *lastMsgId = [controllerUtils.planeController recentMessageForPlane:plane.planeId].messageId;
        if (lastMsgId) {
            [params setObject:lastMsgId forKey:@"startId"];
        }
        [params setObject:plane.planeId forKey:@"planeId"];
        
        [[AGManagerUtils managerUtils].planeManager obtainMessages:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
            if (error == nil) {
                [[AGControllerUtils controllerUtils].messageController saveMessages:[result objectForKey:@"messages"] plane:plane];
                
                NSNumber *more = [result objectForKey:@"more"];
                if (more.boolValue) {
                    
                }
                else{
                    [array removeObjectAtIndex:0];
                    plane.isNew = [NSNumber numberWithBool:NO];
                }
                [self obtainMessagesForPlanes:array];
                [self obtainedMessages];
            }
        }];
    }
    
}

- (void) obtainedMessages
{
    NSArray *planes = [[AGControllerUtils controllerUtils].planeController getAllPlanesForChat];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:planes, @"planes", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
    
}


@end
