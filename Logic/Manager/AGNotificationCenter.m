//
//  AGNotificationManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGNotificationCenter.h"
#import "AGManagerUtils.h"
#import "AGControllerUtils.h"
#import "AGNumber.h"

NSString *AGNotificationCollectedPlanes = @"notification.collectedplanes";
NSString *AGNotificationReceivePlanes = @"notification.receiveplanes";
NSString *AGNotificationGetCollectedPlanes = @"notification.getreceivedplanes";

NSString *AGNotificationObtainedPlanes = @"notification.obtainedplanes";
NSString *AGNotificationObtainPlanes = @"notification.obtainplanes";
NSString *AGNotificationGetObtainedPlanes = @"notification.getobtainedplanes";

NSString *AGNotificationObtainedMessagesForPlane = @"notification.obtainedmessagesforplane";
NSString *AGNotificationObtainMessages = @"notification.obtainmessages";
NSString *AGNotificationGetObtainedMessages = @"notification.getobtainedmessages";

NSString *AGNotificationGetMessagesForPlane = @"notification.getmessagesforplane";
NSString *AGNotificationGotMessagesForPlane = @"notification.gotmessagesforplane";


@interface AGNotificationCenter()

@end

@implementation AGNotificationCenter

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        //collect
        [notificationCenter addObserver:self selector:@selector(receivePlanes:) name:AGNotificationReceivePlanes object:nil];
        [notificationCenter addObserver:self selector:@selector(collectedPlanes) name:AGNotificationGetCollectedPlanes object:nil];
        //obtain planes
        [notificationCenter addObserver:self selector:@selector(obtainPlanes:) name:AGNotificationObtainPlanes object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainedPlanes) name:AGNotificationGetObtainedPlanes object:nil];
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(obtainMessages:) name:AGNotificationObtainMessages object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainedMessages:) name:AGNotificationGetObtainedMessages object:nil];
        //get messages for plane
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(getMessagesForPlane:) name:AGNotificationGetMessagesForPlane object:nil];
    }
    return self;
}

+(AGNotificationCenter*) notificationCenter
{
    static AGNotificationCenter *notificationCenter;
    if (notificationCenter == nil) {
        notificationCenter = [[AGNotificationCenter alloc] init];
    }
    return notificationCenter;
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
             NSArray *planes = [result objectForKey:@"planes"];
            if (planes.count) {
                [self collectedPlanes];
            }
        
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
            NSArray *array = [result objectForKey:@"planes"];
            
            if (array.count) {
                [self obtainedPlanes];
            }
            
            
        }
    }];
}

- (void) obtainedPlanes
{
    NSArray *planes = [[AGControllerUtils controllerUtils].planeController getAllPlanesForChat];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:planes, @"planes", @"reset", @"action", nil];
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
        
        AGPlaneManager *planeManager = [AGManagerUtils managerUtils].planeManager;
        [planeManager obtainMessages:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
            if (error == nil) {
                NSArray *messages = [[AGControllerUtils controllerUtils].messageController saveMessages:[result objectForKey:@"messages"] plane:plane];
                
                NSNumber *more = [result objectForKey:@"more"];
                if (more.boolValue) {
                    
                }
                else{
                    [array removeObjectAtIndex:0];
                    plane.isNew = [NSNumber numberWithBool:NO];
                    [[AGCoreData coreData] save];
                }
                [self obtainMessagesForPlanes:array];
                if (messages.count) {
                    [self obtainedMessages:messages forPlane:plane.planeId];
                    NSNumber *lastMsgId = ((AGMessage*)[messages lastObject]).messageId;
                    NSDictionary *params = [planeManager paramsForViewedMessages:plane lastMsgId:lastMsgId];
                    [planeManager viewedMessages:params context:nil block:^(NSError *error, id context) {
                        
                    }];
                }
            
            }
        }];
    }
    
}

- (void) obtainedMessages:(NSArray*)messages forPlane:(NSNumber*)planeId
{
    //
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:messages, @"messages", planeId, @"planeId",@"append",@"action", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationGotMessagesForPlane object:self userInfo:dict];
    //
    dict = [NSDictionary dictionaryWithObjectsAndKeys:planeId, @"planeId", @"one", @"action", nil];
    [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
    
}

- (void) getMessagesForPlane:(NSNotification*)notification
{
    NSNumber *planeId = [notification.userInfo objectForKey:@"planeId"];
    NSNumber *startId = [notification.userInfo objectForKey:@"startId"];
    NSAssert(planeId != nil, @"nil planeId");
    [self gotMessagesForPlane:planeId startId:startId];
}

- (void) gotMessagesForPlane:(NSNumber*)planeId startId:(NSNumber*)startId
{
    AGMessageController *messageController = [AGControllerUtils controllerUtils].messageController;
    NSDictionary *dict = [messageController getMessagesForPlane:planeId startId:startId];;
    NSArray *doneMessages = [dict objectForKey:@"messages"];
    NSNumber *more = [dict objectForKey:@"more"];
    NSArray *unsentMessages = nil;
    if (startId == nil) {
        unsentMessages = [messageController getUnsentMessagesForPlane:planeId];
    }
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:doneMessages.count + unsentMessages.count];
    int lower = more.boolValue ? 0 : - 1;
    for (int i = doneMessages.count - 1; i > lower; --i) {
        [messages addObject:[doneMessages objectAtIndex:i]];
    }
    if (startId == nil) {
        
        [messages addObjectsFromArray:unsentMessages];
    }
    
    NSString *action = @"reset";
    if (startId) {
        action = @"prepend";
    }
    dict = [NSDictionary dictionaryWithObjectsAndKeys:messages, @"messages", planeId, @"planeId", action, @"action", more, @"more", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationGotMessagesForPlane object:self userInfo:dict];
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
