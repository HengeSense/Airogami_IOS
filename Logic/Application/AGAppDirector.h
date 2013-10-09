//
//  AGAppController.h
//  Airogami
//
//  Created by Tianhu Yang on 10/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGAppConfig.h"

typedef enum{
    AGAppStatusSign,
    AGAppStatusMiddle,
    AGAppStatusMain
}AGAppStatusEnum;

@interface AGAppDirector : NSObject

@property(nonatomic, strong) AGAccount *account;
@property(nonatomic, readonly) int badgeNumber;
@property(nonatomic, assign) AGAppStatusEnum appStatus;
@property(nonatomic, strong) AGAppConfig *appConfig;
@property(strong, nonatomic) NSData *deviceToken;

+(AGAppDirector*) appDirector;
- (BOOL) needSignin;
- (BOOL) gotoSign;
- (void) gotoMiddle;
- (void) gotoMain;
- (void) signout;
- (void) kickoff;
- (void) refresh;

@end
