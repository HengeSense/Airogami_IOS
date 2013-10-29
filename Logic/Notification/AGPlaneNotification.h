//
//  AGNotificationManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *AGNotificationGetNeoPlanes;
extern NSString *AGNotificationPlaneRefreshed;
extern NSString *AGNotificationPlaneRemoved;

extern NSString *AGNotificationCollectedPlanes;
extern NSString *AGNotificationGetCollectedPlanes;

extern NSString *AGNotificationObtainedPlanes;
extern NSString *AGNotificationGetObtainedPlanes;

extern NSString *AGNotificationObtainedMessagesForPlane;
extern NSString *AGNotificationObtainMessages;
extern NSString *AGNotificationGetObtainedMessages;

extern NSString *AGNotificationGetMessagesForPlane;
extern NSString *AGNotificationGotMessagesForPlane;
extern NSString *AGNotificationReadMessagesForPlane;

extern NSString *AGNotificationUnreadMessagesChangedForPlane;
extern NSString *AGNotificationViewingMessagesForPlane;

@class AGPlane;

@interface AGPlaneNotification: NSObject

+(AGPlaneNotification*) planeNotification;

- (void) obtainedPlanesReorder:(AGPlane*)plane;
- (void) obtainedPlane:(AGPlane*)plane;
- (void) obtainedPlanes;
- (void) collectedPlanes;
- (void) reset;
- (void) deletePlane:(AGPlane*)plane;
- (BOOL) clearPlane:(AGPlane*)plane clearMsgId:(NSNumber*)clearMsgId;
- (void) appendMessages:(NSArray*)messages forPlane:(AGPlane*)plane;

@end
