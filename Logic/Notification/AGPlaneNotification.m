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
#import "AGAppDirector.h"

NSString *AGNotificationGetNeoPlanes = @"notification.getneoplanes";
NSString *AGNotificationGetPlanes = @"notification.getplanes";
NSString *AGNotificationPlaneRefreshed = @"notification.planerefreshed";
NSString *AGNotificationPlaneRemoved = @"notification.planeremoved";

NSString *AGNotificationCollectedPlanes = @"notification.collectedplanes";
NSString *AGNotificationGetCollectedPlanes = @"notification.getcollectedplanes";

NSString *AGNotificationObtainedPlanes = @"notification.obtainedplanes";
NSString *AGNotificationGetObtainedPlanes = @"notification.getobtainedplanes";

NSString *AGNotificationObtainedMessagesForPlane = @"notification.obtainedmessagesforplane";
NSString *AGNotificationObtainMessages = @"notification.obtainmessages";
NSString *AGNotificationGetObtainedMessages = @"notification.getobtainedmessages";

NSString *AGNotificationGetMessagesForPlane = @"notification.getmessagesforplane";
NSString *AGNotificationGotMessagesForPlane = @"notification.gotmessagesforplane";
NSString *AGNotificationReadMessagesForPlane = @"notification.readmessagesforplane";

NSString *AGNotificationSendMessages = @"notification.sendmessages";
NSString *AGNotificationSentMessage = @"notification.sentmessage";

NSString *AGNotificationViewMessages = @"notification.viewmessages";
NSString *AGNotificationViewedMessagesForPlane = @"notification.viewedMessagesForPlane";
NSString *AGNotificationUnreadMessagesChangedForPlane = @"notification.unreadMessagesChangedForPlane";
NSString *AGNotificationViewingMessagesForPlane = @"notification.viewingMessagesForPlane";


@interface AGPlaneNotification()
{
    //messages
    BOOL moreMessages;
    NSNumber *messageMutex;
    BOOL obtainingMessages;
    //get new plane
    BOOL moreGetNeoPlanes;
    NSNumber *getNeoPlaneMutex;
    BOOL gettingNeoPlanes;
    //get plane
    BOOL moreGetPlanes;
    NSNumber *getPlanesMutex;
    BOOL gettingPlanes;
    //send messages
    BOOL moreSendMessages;
    NSNumber *sendMessageMutex;
    BOOL sendingMessages;
    //view messages
    BOOL moreViewMessages;
    NSNumber *viewMessageMutex;
    BOOL viewingMessages;
    //
    NSNumber *viewingPlaneId;
}
@end

@implementation AGPlaneNotification

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(getNeoPlanes:) name:AGNotificationGetNeoPlanes object:nil];
         [notificationCenter addObserver:self selector:@selector(getPlanes:) name:AGNotificationGetPlanes object:nil];
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(obtainMessages:) name:AGNotificationObtainMessages object:nil];
        //[notificationCenter addObserver:self selector:@selector(obtainedMessages:) name:AGNotificationGetObtainedMessages object:nil];
        //get messages for plane
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(getMessagesForPlane:) name:AGNotificationGetMessagesForPlane object:nil];
        // send messages
        [notificationCenter addObserver:self selector:@selector(sendMessages:) name:AGNotificationSendMessages object:nil];
        //viewed messages
        [notificationCenter addObserver:self selector:@selector(viewMessages:) name:AGNotificationViewMessages object:nil];
        [notificationCenter addObserver:self selector:@selector(viewedMessagesForPlane:) name:AGNotificationViewedMessagesForPlane object:nil];
        [notificationCenter addObserver:self selector:@selector(viewingMessagesForPlane:) name:AGNotificationViewingMessagesForPlane object:nil];
        
        //
        messageMutex = [NSNumber numberWithBool:YES];
        getNeoPlaneMutex = [NSNumber numberWithBool:YES];
        getPlanesMutex = [NSNumber numberWithBool:YES];
        sendMessageMutex = [NSNumber numberWithBool:YES];
        viewMessageMutex = [NSNumber numberWithBool:YES];
    }
    return self;
}

-(void)reset
{
    //messages
    moreMessages = NO;
    obtainingMessages = NO;
    //get new plane
    moreGetNeoPlanes = NO;
    gettingNeoPlanes = NO;
    //get plane
    moreGetPlanes = NO;
    gettingPlanes = NO;
    //send messages
    moreSendMessages = NO;
    sendingMessages = NO;
    //
    viewingPlaneId = nil;
}

+(AGPlaneNotification*) planeNotification
{
    static AGPlaneNotification *notificationCenter;
    if (notificationCenter == nil) {
        notificationCenter = [[AGPlaneNotification alloc] init];
    }
    return notificationCenter;
}

#pragma mark - get neo planes

- (void) getNeoPlanes:(NSNotification*) notification
{
    NSNumber *number = [notification.userInfo objectForKey:@"updateInc"];
    NSNumber * maxUpdateInc = [[AGControllerUtils controllerUtils].planeController recentUpdateInc];
    if (number && number.longLongValue <= maxUpdateInc.longLongValue) {//notified
        return;
    }
    BOOL shouldGet = NO;
    @synchronized(getNeoPlaneMutex){
        if (gettingNeoPlanes) {
            moreGetNeoPlanes = YES;
        }
        else{
            gettingNeoPlanes = YES;
            shouldGet = YES;
        }
    }
    
    if (shouldGet) {
        [self getNeoPlanes];
    }
    
    
}

- (void) getNeoPlanes
{
    NSNumber * start = [[AGControllerUtils controllerUtils].planeController recentUpdateInc];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    [[AGManagerUtils managerUtils].planeManager getNeoPlanes:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *neoPlanes) {
        if (error == nil) {
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self getNeoPlanes];
            }
            else{
                //whether has more
                BOOL shouldGet= NO;
                @synchronized(getNeoPlaneMutex){
                    if (moreGetNeoPlanes) {
                        moreGetNeoPlanes = NO;
                        shouldGet = YES;
                    }
                    else{
                        gettingNeoPlanes = NO;
                    }
                }
                if (shouldGet) {
                    [self getNeoPlanes];
                }
                else{
                    [self refreshed];
                }
            }
            //deal with clear and read
            if (neoPlanes.count) {
                for (AGNeoPlane *neoPlane in neoPlanes) {
                    AGPlane *plane = neoPlane.plane;
                    //clear
                    if (plane && neoPlane.clearMsgId.longLongValue > plane.clearMsgId.longLongValue) {
                        [self clearPlane:plane clearMsgId:neoPlane.clearMsgId];
                    }
                    //read
                    if (plane && neoPlane.lastMsgId.longLongValue > plane.lastMsgId.longLongValue) {
                        plane.lastMsgId = neoPlane.lastMsgId;
                        [[AGCoreData coreData] save];
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:plane.planeId, @"planeId", nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationReadMessagesForPlane object:nil userInfo:dict];
                    }
                }
            }
            //
            [self gotNeoPlanes];
            
        }
        else{
            //should deal with server error
            @synchronized(getNeoPlaneMutex){
                moreGetNeoPlanes = NO;
                gettingNeoPlanes = NO;
            }
            [self refreshed];
        }
    }];
}

- (void)refreshed
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"plane" forKey:@"source"];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationPlaneRefreshed object:self userInfo:dict];
}

- (void) gotNeoPlanes
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationGetPlanes object:self userInfo:dict];
}

#pragma mark - get planes

- (void) getPlanes:(NSNotification*) notification
{
    BOOL shouldGet = NO;
    @synchronized(getPlanesMutex){
        if (gettingPlanes) {
            moreGetPlanes = YES;
        }
        else{
            gettingPlanes = YES;
            shouldGet = YES;
        }
    }
    
    if (shouldGet) {
        [self getPlanes];
    }
    
}

- (void) getPlanes
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSArray *neoPlanes = [controllerUtils.planeController getNeoPlanesForUpdate];
    if (neoPlanes.count) {
        [self getPlanesForNeoPlaneIds:neoPlanes];
    }
    else{
        @synchronized(getPlanesMutex){
            moreGetPlanes = NO;
            gettingPlanes = NO;
        }
        //
        NSDictionary *dict = [NSDictionary dictionary];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:AGNotificationObtainMessages object:self userInfo:dict];
    }
}

- (void) getPlanesForNeoPlaneIds:(NSArray*)neoPlanes
{
    AGPlaneManager *planeManager = [AGManagerUtils managerUtils].planeManager;
    NSMutableArray *neoPlaneIds = [NSMutableArray arrayWithCapacity:neoPlanes.count];
    for (AGNeoPlane *neoPlane in neoPlanes) {
        [neoPlaneIds addObject:neoPlane.planeId];
    }
    NSDictionary *params = [planeManager paramsForGetPlanes:neoPlaneIds];
    [planeManager getPlanes:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *planes) {
        if (error == nil) {
            BOOL obtained = NO;
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
            for (AGPlane *plane in planes) {
                if (plane.status.intValue == AGPlaneStatusReplied) {
                    obtained = YES;
                }
                if (plane.deletedByO.boolValue || plane.deletedByT.boolValue) {
                    obtained = YES;
                    [self deletePlane:plane];
                    [dict setObject:plane forKey:@"plane"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationPlaneRemoved object:self userInfo:dict];
                }
            }
            
            if (obtained) {
                [self obtainedPlanes];
            }
            //
            [[AGControllerUtils controllerUtils].planeController removeNeoPlanes:neoPlanes];
            [self getPlanes];
        }
        else{
            //should deal with server error
            @synchronized(getNeoPlaneMutex){
                moreGetNeoPlanes = NO;
                gettingNeoPlanes = NO;
            }
        }
    }];
}

#pragma mark - obtain messages

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
    AGNeoPlane *neoPlane = [controllerUtils.planeController getNextNeoPlaneForMessages];
    if (neoPlane) {
        [self obtainMessagesForPlane:neoPlane];
    }
    else{
        @synchronized(messageMutex){
            moreMessages = NO;
            obtainingMessages = NO;
        }
    }
}

- (void) obtainMessagesForPlane:(AGNeoPlane*)neoPlane
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
    AGPlane *plane = neoPlane.plane;
    NSNumber *lastMsgId = plane.neoMsgId;
    if (lastMsgId) {
        [params setObject:lastMsgId forKey:@"startId"];
    }
    [params setObject:plane.planeId forKey:@"planeId"];
    
    AGPlaneManager *planeManager = [AGManagerUtils managerUtils].planeManager;
    [planeManager obtainMessages:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error == nil) {
            NSArray *messages = [controllerUtils.messageController saveMessages:[result objectForKey:@"messages"] plane:plane];
            
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self obtainMessagesForPlane:neoPlane];
            }
            else{
                // why crash
                [controllerUtils.planeController removeNeoPlane:neoPlane];
                [self obtainMessages];
            }
            if (messages.count) {
                [controllerUtils.planeController updateMessage:plane];
                //
                [self obtainedMessages:messages forPlane:plane];
            
                //#warning this may be set after plane change status
                /*NSNumber *lastMsgId = ((AGMessage*)[messages lastObject]).messageId;
                if (plane.status.intValue == AGPlaneStatusNew) {
                    plane.viewedMsgId = lastMsgId;
                    [[AGCoreData coreData] save];
                }*/
                
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

- (void) obtainedMessages:(NSArray*)messages forPlane:(AGPlane*)plane
{
    //
    NSDictionary *dict = nil;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (plane.status.intValue == AGPlaneStatusNew) {
        [self collectedPlanes];
    }
    else if(plane.status.intValue == AGPlaneStatusReplied){
        dict = [NSDictionary dictionaryWithObjectsAndKeys:messages, @"messages", plane.planeId, @"planeId",@"append",@"action", nil];
        [notificationCenter postNotificationName:AGNotificationGotMessagesForPlane object:self userInfo:dict];
        //
        if ([plane.planeId isEqual:viewingPlaneId] == NO) {
            //
            [[AGControllerUtils controllerUtils].messageController updateMessagesCount:plane];
            //
            dict = [NSDictionary dictionaryWithObjectsAndKeys:plane.planeId, @"planeId", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadMessagesChangedForPlane object:nil userInfo:dict];
            //
            [[AGManagerUtils managerUtils].audioManager playReceivedMessage];
        }
        else{
            dict = [NSDictionary dictionaryWithObjectsAndKeys:plane, @"plane", nil];
            [notificationCenter postNotificationName:AGNotificationViewedMessagesForPlane object:self userInfo:dict];
            //
            dict = [NSDictionary dictionaryWithObjectsAndKeys:plane, @"plane", @"one", @"action", nil];
            [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
            //
            [[AGManagerUtils managerUtils].audioManager playReceivedMessageWhenViewing];
        }
    }
    
}

#pragma mark - get messages

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
    [managerUtils.planeManager replyPlane:message context:nil block:^(NSError *error, id context, AGMessage *remoteMessage, BOOL removed) {
        if (error == nil) {
            
            if (remoteMessage) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                [dict setObject:plane forKey:@"plane"];
                [dict setObject:remoteMessage forKey:@"remoteMessage"];
                [dict setObject:message forKey:@"message"];
                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSentMessage object:nil userInfo:dict];
            }
            
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

- (void) viewingMessagesForPlane:(NSNotification*)notification
{
    AGPlane *plane = [notification.userInfo objectForKey:@"plane"];
    viewingPlaneId = plane.planeId;
}

#pragma mark - others

- (void) deletePlane:(AGPlane*)plane
{
    [[AGControllerUtils controllerUtils].planeController markDeleted:plane];
    //viewedMessagesForPlane
    NSDictionary *dict = [NSDictionary dictionaryWithObject:plane forKey:@"plane"];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewedMessagesForPlane object:nil userInfo:dict];
    //
    [[AGCoreData coreData] remove:plane];
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationPlaneRemoved object:nil userInfo:dict];
}

- (void) clearPlane:(AGPlane*)plane clearMsgId:(NSNumber*)clearMsgId
{
    if ([[AGControllerUtils controllerUtils].messageController clearPlane:plane clearMsgId:clearMsgId]) {
        [self gotMessagesForPlane:plane.planeId startId:nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:plane.planeId, @"planeId", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadMessagesChangedForPlane object:nil userInfo:dict];
    }
}

- (void) collectedPlanes
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollectedPlanes object:self userInfo:dict];
    
}

- (void) obtainedPlanesReorderForPlane:(AGPlane*)plane
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"reorder", @"action", plane, @"plane", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
}

- (void) obtainedPlanes
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
}

- (void) obtainedPlane:(AGPlane*)plane
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"one", @"action", plane.planeId, @"planeId", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
}

@end
