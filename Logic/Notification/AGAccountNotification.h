//
//  AGAccountNotification.h
//  Airogami
//
//  Created by Tianhu Yang on 9/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *AGNotificationObtainAccounts;
extern NSString *AGNotificationObtainAccount;
extern NSString *AGNotificationProfileChanged;

@interface AGAccountNotification : NSObject

+(AGAccountNotification*) accountNotification;

-(void) reset;

@end
