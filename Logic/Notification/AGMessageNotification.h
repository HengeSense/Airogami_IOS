//
//  AGMessageNotification.h
//  Airogami
//
//  Created by Tianhu Yang on 10/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AGMessage;

extern NSString *AGNotificationSendMessages;
extern NSString *AGNotificationSendMessageData;
extern NSString *AGNotificationSentMessage;

extern NSString *AGNotificationViewMessages;
extern NSString *AGNotificationViewedMessagesForPlane;

@interface AGMessageNotification : NSObject

+(AGMessageNotification*) messageNotification;
-(void)reset;
-(void) resendMessage:(AGMessage*) message;

@end
