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

extern NSString *AGNotificationCollected;
extern NSString *AGNotificationReceive;
extern NSString *AGNotificationGetCollected;

extern NSString *AGNotificationObtained;
extern NSString *AGNotificationObtain;
extern NSString *AGNotificationGetObtained;

@interface AGNotificationCenter : NSObject

+ (AGNotificationCenter*) notificationCenter;
- (void) startTimer:(BOOL)start;

@end
