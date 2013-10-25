//
//  AGAccountNotification.h
//  Airogami
//
//  Created by Tianhu Yang on 9/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *AGNotificationObtainAccounts;
extern NSString *AGNotificationObtainProfiles;
extern NSString *AGNotificationObtainHots;
extern NSString *AGNotificationProfileChanged;
extern NSString *AGNotificationHotChanged;
extern NSString *AGNotificationGetPoints;
extern NSString *AGNotificationGotPoints;

@interface AGAccountNotification : NSObject

+(AGAccountNotification*) accountNotification;

-(void) reset;
- (void) obtainAccountsForAccounts:(NSArray*)accounts;
- (void) obtainHotForMe;
-(void) increaseLikesCount:(int) count;

@end
