//
//  AGAppController.m
//  Airogami
//
//  Created by Tianhu Yang on 10/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAppDirector.h"
#import "AGControllerUtils.h"
#import "AGNotificationCenter.h"
#import "AGManagerUtils.h"
#import "AGRootViewController.h"

@implementation AGAppDirector

@synthesize account;
@synthesize badgeNumber;
@synthesize appStatus;
@synthesize appConfig;
@synthesize deviceToken;;

+(AGAppDirector*) appDirector
{
    static AGAppDirector *appDirector = nil;
    if (appDirector == nil) {
        appDirector = [[AGAppDirector alloc] init];
    }
    return appDirector;
}

-(id)init
{
    if (self = [super init]) {
        appConfig = [AGAppConfig appConfig];
    }
    return self;
}

- (BOOL) needSignin
{
    return appConfig.appAccount.password == nil;
}

-(int) badgeNumber
{
    if (appStatus == AGAppStatusMain) {
        return [[AGControllerUtils controllerUtils].accountController getUnreadMessagesCount];
    }
    return 0;
}

- (void) refresh
{
    if (appStatus == AGAppStatusMain) {
        AGNotificationCenter *notificationCenter = [AGNotificationCenter notificationCenter];;
        [notificationCenter obtainPlanesAndChains];
        //[notificationCenter obtainMessages];
        //[notificationCenter resendMessages];
    }
}

- (void) kickoff
{
    if (appStatus == AGAppStatusMain) {
        [[AGManagerUtils managerUtils].accountManager autoSignin:nil block:^(NSError *error, id context) {
            if (error == nil) {
                [[AGNotificationCenter notificationCenter] obtainPlanesAndChains];
                [[AGNotificationCenter notificationCenter] resendMessages];
            }
        }];
    }
    
}

//appAccount != nil
- (void) gotoMiddle
{
    if (appStatus == AGAppStatusSign) {
        appStatus = AGAppStatusMiddle;
        [[AGRootViewController rootViewController] switchToMain];
    }
}

- (void) gotoMain
{
    if (appStatus == AGAppStatusMiddle) {
        appStatus = AGAppStatusMain;
        [self kickoff];
    }
}

- (AGAccount*)account
{
    if (account == nil && appStatus > AGAppStatusSign) {
        account = [[AGControllerUtils controllerUtils].accountController findAccount:appConfig.appAccount.accountId];
    }
    return account;
}

//appAccount != nil
- (BOOL) gotoSign
{
    if (appStatus != AGAppStatusSign) {
        appStatus = AGAppStatusSign;
        account = nil;
        [self.appConfig resetAppAccount];
        [[AGManagerUtils managerUtils].networkManager cancelAllURLConnections];
        [[AGNotificationCenter notificationCenter] reset];
        [[AGRootViewController rootViewController] switchToSign];
        return YES;
    }
    return NO;
    
}

- (void) signout
{
    [[AGManagerUtils managerUtils].accountManager signout:nil block:^(NSError *error, id context) {
        if (error == nil) {
            [self gotoSign];
        }
    }];
    
}

@end
