//
//  AGNotificationCenter.h
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AGPlaneNotification.h"
#import "AGChainNotification.h"
#import "AGAccountNotification.h"

extern NSString *AGNotificationRefreshed;
extern NSString *AGNotificationRefresh;

extern NSString *AGNotificationCollected;
extern NSString *AGNotificationReceive;
extern NSString *AGNotificationGetCollected;

extern NSString *AGNotificationObtained;
extern NSString *AGNotificationObtain;
extern NSString *AGNotificationGetObtained;
extern NSString *AGNotificationGetUnreadMessagesCount;
extern NSString *AGNotificationGotUnreadMessagesCount;

@interface AGNotificationCenter : NSObject

+(void) initialize;
+ (AGNotificationCenter*) notificationCenter;
//should run after open the program
- (void) resendMessages;
- (void) obtainPlanesAndChains;
- (void) reset;

@end
