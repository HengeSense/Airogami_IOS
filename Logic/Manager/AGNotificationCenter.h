//
//  AGNotificationManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *AGNotificationCollectedPlanes;
extern NSString *AGNotificationReceivePlanes;
extern NSString *AGNotificationGetCollectedPlanes;

extern NSString *AGNotificationObtainedPlanes;
extern NSString *AGNotificationObtainPlanes;
extern NSString *AGNotificationGetObtainedPlanes;

extern NSString *AGNotificationObtainedMessagesForPlane;
extern NSString *AGNotificationObtainMessages;
extern NSString *AGNotificationGetObtainedMessages;

extern NSString *AGNotificationGetMessagesForPlane;
extern NSString *AGNotificationGotMessagesForPlane;

@interface AGNotificationCenter: NSObject

+(AGNotificationCenter*) notificationCenter;

- (void) startTimer;
- (void) obtainedPlanes;

@end