//
//  AGNotificationManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPlaneNotification.h"
#import "AGManagerUtils.h"
#import "AGControllerUtils.h"
#import "AGNumber.h"
#import "AGAccountStat.h"

NSString *AGNotificationCollectedPlanes = @"notification.collectedplanes";
NSString *AGNotificationReceivePlanes = @"notification.receiveplanes";
NSString *AGNotificationGetCollectedPlanes = @"notification.getcollectedplanes";

NSString *AGNotificationObtainedPlanes = @"notification.obtainedplanes";
NSString *AGNotificationObtainPlanes = @"notification.obtainplanes";
NSString *AGNotificationGetObtainedPlanes = @"notification.getobtainedplanes";

NSString *AGNotificationObtainedMessagesForPlane = @"notification.obtainedmessagesforplane";
NSString *AGNotificationObtainMessages = @"notification.obtainmessages";
NSString *AGNotificationGetObtainedMessages = @"notification.getobtainedmessages";

NSString *AGNotificationGetMessagesForPlane = @"notification.getmessagesforplane";
NSString *AGNotificationGotMessagesForPlane = @"notification.gotmessagesforplane";

NSString *AGNotificationSendMessages = @"notification.sendmessages";
NSString *AGNotificationSentMessage = @"notification.sentmessage";

NSString *AGNotificationViewedMessagesForPlane = @"notification.viewedMessagesForPlane";
NSString *AGNotificationUnreadMessagesChangedForPlane = @"notification.unreadMessagesChangedForPlane";


@interface AGPlaneNotification()
{
    //messages
    BOOL moreMessages;
    NSNumber *messageMutex;
    BOOL obtainingMessages;
    //receive plane
    BOOL moreReceivePlanes;
    NSNumber *receivePlaneMutex;
    BOOL receivingPlanes;
    //obtain plane
    BOOL moreObtainPlanes;
    NSNumber *obtainPlaneMutex;
    BOOL obtainingPlanes;
    //send messages
    BOOL moreSendMessages;
    NSNumber *sendMessageMutex;
    BOOL sendingMessages;
}
@end

@implementation AGPlaneNotification

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        //collect
        [notificationCenter addObserver:self selector:@selector(receivePlanes:) name:AGNotificationReceivePlanes object:nil];
        //[notificationCenter addObserver:self selector:@selector(collectedPlanes) name:AGNotificationGetCollectedPlanes object:nil];
        //obtain planes
        [notificationCenter addObserver:self selector:@selector(obtainPlanes:) name:AGNotificationObtainPlanes object:nil];
        //[notificationCenter addObserver:self selector:@selector(obtainedPlanes) name:AGNotificationGetObtainedPlanes object:nil];
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(obtainMessages:) name:AGNotificationObtainMessages object:nil];
        //[notificationCenter addObserver:self selector:@selector(obtainedMessages:) name:AGNotificationGetObtainedMessages object:nil];
        //get messages for plane
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(getMessagesForPlane:) name:AGNotificationGetMessagesForPlane object:nil];
        // send messages
        [notificationCenter addObserver:self selector:@selector(sendMessages:) name:AGNotificationSendMessages object:nil];
        //viewed messages 
        [notificationCenter addObserver:self selector:@selector(viewedMessagesForPlane:) name:AGNotificationViewedMessagesForPlane object:nil];
    }
    return self;
}

+(AGPlaneNotification*) planeNotification
{
    static AGPlaneNotification *notificationCenter;
    if (notificationCenter == nil) {
        notificationCenter = [[AGPlaneNotification alloc] init];
    }
    return notificationCenter;
}

- (void) receivePlanes:(NSNotification*) notification
{
    NSNumber *number = [notification.userInfo objectForKey:@"updateInc"];
    NSNumber * maxUpdateInc = [[AGControllerUtils controllerUtils].planeController recentPlaneUpdateIncForCollect];
    if (number && number.longLongValue <= maxUpdateInc.longLongValue) {//notified
        return;
    }
    BOOL shouldReceive = NO;
    @synchronized(receivePlaneMutex){
        if (receivingPlanes) {
            moreReceivePlanes = YES;
        }
        else{
            receivingPlanes = YES;
            shouldReceive = YES;
        }
    }
    
    if (shouldReceive) {
        [self receivePlanes];
    }
    
    
}

- (void) receivePlanes
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
                [self receivePlanes];
            }
            else{
                //whether has more
                BOOL shouldReceive= NO;
                @synchronized(receivePlaneMutex){
                    if (moreReceivePlanes) {
                        moreReceivePlanes = NO;
                        shouldReceive = YES;
                    }
                    else{
                        receivingPlanes = NO;
                    }
                }
                if (shouldReceive) {
                    [self receivePlanes];
                }
            }
            NSArray *planes = [result objectForKey:@"planes"];
            if (planes.count) {
                [self collectedPlanes];
            }
            
        }
        else{
            //should deal with server error
            @synchronized(receivePlaneMutex){
                moreReceivePlanes = NO;
                receivingPlanes = NO;
            }
        }
    }];
}

- (void) collectedPlanes
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollectedPlanes object:self userInfo:dict];
    
}

- (void) obtainPlanes:(NSNotification*) notification
{
    NSNumber *number = [notification.userInfo objectForKey:@"updateInc"];
    NSNumber * maxUpdateInc = [[AGControllerUtils controllerUtils].planeController recentPlaneUpdateIncForChat];
    if (number && number.longLongValue <= maxUpdateInc.longLongValue) {//notified
        return;
    }
    BOOL shouldObtain = NO;
    @synchronized(obtainPlaneMutex){
        if (obtainingPlanes) {
            moreObtainPlanes = YES;
        }
        else{
            obtainingPlanes = YES;
            shouldObtain = YES;
        }
    }
    
    if (shouldObtain) {
        [self obtainPlanes];
    }
    
}

- (void) obtainPlanes
{
    NSNumber * start = [[AGControllerUtils controllerUtils].planeController recentPlaneUpdateIncForChat];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:4];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    [[AGManagerUtils managerUtils].planeManager obtainPlanes:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *planes) {
        if (error == nil) {
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self obtainPlanes];
            }
            else{
                 //whether has more
                BOOL shouldObtain = NO;
                @synchronized(obtainPlaneMutex){
                    if (moreObtainPlanes) {
                        moreObtainPlanes = NO;
                        shouldObtain = YES;
                    }
                    else{
                        obtainingPlanes = NO;
                    }
                }
                if (shouldObtain) {
                    [self obtainPlanes];
                }
            }
            
            if (planes.count) {
                [[AGControllerUtils controllerUtils].planeController addNewPlanesForChat:planes];
                [self obtainedPlanes];
                NSDictionary *dict = [NSDictionary dictionary];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AGNotificationObtainMessages object:self userInfo:dict];
                
            }
            
        }
        else{
            //should deal with server error
            @synchronized(obtainPlaneMutex){
                moreObtainPlanes = NO;
                obtainingPlanes = NO;
            }
        }
    }];
}

- (void) obtainedPlanes
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
    
}

- (void) obtainMessages:(NSNotification*) notification
{
    BOOL shouldObtain = NO;
    @synchronized(messageMutex){
        if (obtainingMessages) {
            moreMessages = YES;
        }
        else{
            obtainingMessages = YES;
            shouldObtain = YES;
        }
    }
    
    if (shouldObtain) {
        [self obtainMessages];
    }
    
}

- (void) obtainMessages
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGNewPlane *newPlane = [controllerUtils.planeController getNextNewPlaneForChat];
    if (newPlane) {
        [self obtainMessagesForPlane:newPlane];
    }
    else{
        @synchronized(messageMutex){
            moreMessages = NO;
            obtainingMessages = NO;
        }
    }
}

- (void) obtainMessagesForPlane:(AGNewPlane*)newPlane
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
    AGPlane *plane = newPlane.plane;
    NSNumber *oldUpdateInc = newPlane.updateInc;
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
                [self obtainMessagesForPlane:newPlane];
            }
            else{
                [controllerUtils.planeController removeNewPlaneForChat:newPlane oldUpdateInc:oldUpdateInc];
                [self obtainMessages];
            }
            if (messages.count) {
                AGAccountStat *accountStat = [AGManagerUtils managerUtils].accountManager.account.accountStat;
                accountStat.unreadMessagesCount = [NSNumber numberWithInt:accountStat.unreadMessagesCount.intValue + messages.count];
                [[AGCoreData coreData] save];
                //
                [self obtainedMessages:messages forPlane:plane.planeId];
                //
                //NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:plane, @"plane", nil];
                //[[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadMessagesChangedForPlane object:nil userInfo:dict];
                //
                NSNumber *lastMsgId = ((AGMessage*)[messages lastObject]).messageId;
                NSDictionary *params = [planeManager paramsForViewedMessages:plane lastMsgId:lastMsgId];
                [planeManager viewedMessages:params context:nil block:^(NSError *error, id context) {
                    
                }];
                
            }
            
        }
        else{
            //should deal with server error
            @synchronized(messageMutex){
                moreMessages = NO;
                obtainingMessages = NO;
            }
        }
    }];
    
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
    int start = more.boolValue ? doneMessages.count - 2 : doneMessages.count - 1;
    for (int i = start; i > -1; --i) {
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

- (void) sendMessages:(NSNotification*) notification
{
    BOOL shouldSend = NO;
    @synchronized(sendMessageMutex){
        if (sendingMessages) {
            moreSendMessages = YES;
        }
        else{
            sendingMessages = YES;
            shouldSend = YES;
        }
    }
    
    if (shouldSend) {
        [self sendMessages];
    }
    
}

- (void) sendMessages
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGMessage *message = [controllerUtils.messageController getNextUnsentMessage];
    if (message) {
        [self sendMessage:message];
    }
    else{
        @synchronized(sendMessageMutex){
            moreSendMessages = NO;
            sendingMessages = NO;
        }
    }
}

- (void) sendMessage:(AGMessage*)message
{
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    AGPlane *plane = message.plane;
    [managerUtils.planeManager replyPlane:message context:nil block:^(NSError *error, id context, AGMessage *remoteMessage, BOOL refresh) {
        
        if (error == nil) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            if (remoteMessage) {
                [dict setObject:remoteMessage forKey:@"remoteMessage"];
                [dict setObject:message forKey:@"message"];
                [dict setObject:plane forKey:@"plane"];
            }
            if (refresh) {
                [dict setObject:@"refresh" forKey:@"refresh"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSentMessage object:nil userInfo:dict];
            [self sendMessages];
            
        }
        else{
            //should deal with server error
            @synchronized(sendMessageMutex){
                moreSendMessages = NO;
                sendingMessages = NO;
            }
        }
        
    }];
    
}

- (void)viewedMessagesForPlane:(NSNotification*)notification
{
    AGPlane *plane = [notification.userInfo objectForKey:@"plane"];
    [[AGControllerUtils controllerUtils].messageController viewedMessagesForPlane:plane];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:plane, @"plane", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadMessagesChangedForPlane object:nil userInfo:dict];
}


@end
