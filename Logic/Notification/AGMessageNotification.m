//
//  AGMessageNotification.m
//  Airogami
//
//  Created by Tianhu Yang on 10/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGMessageNotification.h"
#import "AGPlane.h"
#import "AGControllerUtils.h"
#import "AGManagerUtils.h"
#import "AGPlaneNotification.h"

NSString *AGNotificationSendMessages = @"notification.sendmessages";
NSString *AGNotificationSendMessageData = @"notification.sendmessagedata";
NSString *AGNotificationSentMessage = @"notification.sentmessage";

NSString *AGNotificationViewMessages = @"notification.viewmessages";
NSString *AGNotificationViewedMessagesForPlane = @"notification.viewedMessagesForPlane";

@interface AGMessageNotification()
{
    //send messages
    BOOL moreSendMessages;
    NSNumber *sendMessageMutex;
    BOOL sendingMessages;
    //send message data
    BOOL moreSendDataMessage;
    NSNumber *sendDataMessageMutex;
    BOOL sendingDataMessage;
    //view messages
    BOOL moreViewMessages;
    NSNumber *viewMessageMutex;
    BOOL viewingMessages;
}
@end

@implementation AGMessageNotification

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        // send messages
        [notificationCenter addObserver:self selector:@selector(sendMessages:) name:AGNotificationSendMessages object:nil];
        [notificationCenter addObserver:self selector:@selector(sendMessageDatum:) name:AGNotificationSendMessageData object:nil];
        //viewed messages
        [notificationCenter addObserver:self selector:@selector(viewMessages:) name:AGNotificationViewMessages object:nil];
        [notificationCenter addObserver:self selector:@selector(viewedMessagesForPlane:) name:AGNotificationViewedMessagesForPlane object:nil];
        //
        sendMessageMutex = [NSNumber numberWithBool:YES];
        viewMessageMutex = [NSNumber numberWithBool:YES];
        sendDataMessageMutex = [NSNumber numberWithBool:YES];
    }
    return self;
}

+(AGMessageNotification*) messageNotification
{
    static AGMessageNotification *messageNotification;
    if (messageNotification == nil) {
        messageNotification = [[AGMessageNotification alloc] init];
    }
    return messageNotification;
}

-(void)reset
{
    //send messages
    moreSendMessages = NO;
    sendingMessages = NO;
    //send message data
    moreSendDataMessage = NO;
    sendingDataMessage = NO;
    //view messages
    moreViewMessages = NO;
    viewingMessages = NO;
}

#pragma mark - send messages

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
    [managerUtils.planeManager replyPlane:message context:nil block:^(NSError *error, id context, AGMessage *remoteMessage) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        [dict setObject:plane forKey:@"plane"];
        [dict setObject:message forKey:@"message"];
        if (error == nil) {
            //succeed
            [dict setObject:remoteMessage forKey:@"remoteMessage"];
            
            [self sendMessages];
        }
        else{
            //should deal with server error
            @synchronized(sendMessageMutex){
                moreSendMessages = NO;
                sendingMessages = NO;
            }
        }
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSentMessage object:nil userInfo:dict];
    }];
}

- (void) resendMessage:(AGMessage*) message
{
    message.state = [NSNumber numberWithShort:AGSendStateSending];
    [[AGCoreData coreData] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSendMessages object:nil userInfo:nil];
}

#pragma mark - send message data

- (void) sendDataMessages:(NSNotification*) notification
{
    BOOL shouldSend = NO;
    @synchronized(sendDataMessageMutex){
        if (sendingDataMessage) {
            moreSendDataMessage = YES;
        }
        else{
            sendingDataMessage = YES;
            shouldSend = YES;
        }
    }
    
    if (shouldSend) {
        [self sendDataMessages];
    }
    
}

- (void) sendDataMessages
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGMessage *message = [controllerUtils.messageController getNextUnsentDataMessage];
    if (message) {
        [self sendDataMessage:message];
    }
    else{
        @synchronized(sendDataMessageMutex){
            moreSendDataMessage = NO;
            sendingDataMessage = NO;
        }
    }
}

-(void) messageDataToken:(AGMessage*)message
{
    
}

-(void) uploadMessageData:(AGMessage*)message
{
    
}

- (void) sendDataMessage:(AGMessage*)message
{
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    AGPlane *plane = message.plane;
    [managerUtils.planeManager replyPlane:message context:nil block:^(NSError *error, id context, AGMessage *remoteMessage) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        [dict setObject:plane forKey:@"plane"];
        [dict setObject:message forKey:@"message"];
        if (error == nil) {
            //succeed
            [dict setObject:remoteMessage forKey:@"remoteMessage"];
            
            [self sendMessages];
        }
        else{
            //should deal with server error
            @synchronized(sendDataMessageMutex){
                moreSendDataMessage = NO;
                sendingDataMessage = NO;
            }
        }
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSentMessage object:nil userInfo:dict];
    }];
}

- (void) resendDataMessage:(AGMessage*) message
{
    message.state = [NSNumber numberWithShort:AGSendStateSending];
    [[AGCoreData coreData] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSendMessageData object:nil userInfo:nil];
}

#pragma mark - view messages

- (void) viewMessages:(NSNotification*) notification
{
    BOOL shouldView = NO;
    @synchronized(viewMessageMutex){
        if (viewingMessages) {
            moreViewMessages = YES;
        }
        else{
            viewingMessages = YES;
            shouldView = YES;
        }
    }
    
    if (shouldView) {
        [self viewMessages];
    }
}

- (void) viewMessages
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGPlane *plane = [controllerUtils.planeController getNextUnviewedPlane];
    if (plane) {
        [self viewMessage:plane];
    }
    else{
        @synchronized(viewMessageMutex){
            moreViewMessages = NO;
            viewingMessages = NO;
        }
    }
}

- (void) viewMessage:(AGPlane*)plane
{
    AGPlaneManager *planeManager = [AGManagerUtils managerUtils].planeManager;
    NSNumber *lastMsgId = plane.viewedMsgId;
    NSDictionary *params = [planeManager paramsForViewedMessages:plane lastMsgId:lastMsgId];
    [planeManager viewedMessages:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            //should deal with server error
            @synchronized(viewMessageMutex){
                moreViewMessages = NO;
                viewingMessages = NO;
            }
        }
        else{
            NSNumber *newLastMsgId = [result objectForKey:@"lastMsgId"];
            if (newLastMsgId == nil) {
                newLastMsgId = lastMsgId;
            }
            [[AGControllerUtils controllerUtils].planeController updateLastMsgId:newLastMsgId plane:plane];
            [self viewMessages];
        }
    }];
    
}

- (void)viewedMessagesForPlane:(NSNotification*)notification
{
    AGPlane *plane = [notification.userInfo objectForKey:@"plane"];
    NSNumber *lastMsgId = [[AGControllerUtils controllerUtils].messageController viewedMessagesForPlane:plane];
    //
    if (lastMsgId) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:plane.planeId, @"planeId", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadMessagesChangedForPlane object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewMessages object:nil userInfo:dict];
    }
}

@end
