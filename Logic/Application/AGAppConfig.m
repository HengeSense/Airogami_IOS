//
//  AGAppConfig.m
//  Airogami
//
//  Created by Tianhu Yang on 8/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAppConfig.h"
#import "AGFileManager.h"
#import "AGAccountStat.h"
#import "AGAuthenticate.h"
#import "AGProfile.h"
#import "AGAppDelegate.h"
#import "AGControllerUtils.h"
#import "AGManagerUtils.h"
#import "AGUtils.h"
#import "AGNotificationCenter.h"
#import "AGRootViewController.h"

static NSString *configName = @"AppConfig";
static NSString *path;

@interface AGAppConfig()
{
    BOOL inMain;
}

@end

@implementation AGAppConfig

@synthesize once;
@synthesize appAccount;
@synthesize appVersion;
@synthesize guid;
@synthesize badgeNumber;

+ (AGAppConfig*)appConfig
{
    NSURL *url = [[AGFileManager fileManager] urlForConfig];
    url = [url URLByAppendingPathComponent:configName];
    path = url.path;
    AGAppConfig *appConfig = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (appConfig == nil) {
        appConfig = [[AGAppConfig alloc] init];
        [NSKeyedArchiver archiveRootObject:appConfig toFile:path];
    }
    else{
        if (appConfig.appVersion != AGApplicationVersion) {
            appConfig.once = YES;
            appConfig.appVersion = AGApplicationVersion;
            [NSKeyedArchiver archiveRootObject:appConfig toFile:path];
        }
    }
    return appConfig;
}

- (id)init
{
    if (self = [super init]) {
        once = YES;
        appVersion = AGApplicationVersion;
        guid = [AGUtils obtainUuid];
        appAccount = [[AGAppAccount alloc] init];
    }
    return self;
}

- (NSArray*) codingProperties
{
    static NSArray *keys;
    if (keys == nil) {
        keys = [self propertyKeys];
    }
    return keys;
}

- (void) save
{
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

- (void) updateAccountId:(NSNumber*)accountId
{
    appAccount.accountId = accountId;
}

- (void) updateAppAccount:(AGAccount*)account password:(NSString *)password
{
    appAccount.accountId = account.accountId;
    appAccount.email = account.authenticate.email;
    appAccount.screenName = account.profile.screenName;
    appAccount.password = password;
    appAccount.signinCount = account.accountStat.signinCount;
    [self save];
}

- (void) updatePassword:(NSString*)password
{
    appAccount.password = password;
    [self save];
}

- (void) resetAppAccount
{
    appAccount.password = nil;
    [self save];
}

- (BOOL) needSignin
{
    return appAccount.password == nil;
}

-(int) badgeNumber
{
    if (inMain) {
        return [[AGControllerUtils controllerUtils].accountController getUnreadMessagesCount];
    }
    return 0;
}


- (NSMutableDictionary*) autoSigninParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    if (appAccount.password.length > 0) {
        if (appAccount.email.length > 0) {
            [params setObject:appAccount.email forKey:AGLogicAccountEmailKey];
        }
        else if(appAccount.screenName.length > 0){
            [params setObject:appAccount.screenName forKey:AGLogicAccountScreenNameKey];
        }
    }
    
    if (params.count) {
        [params setObject:appAccount.password forKey:AGLogicAccountPasswordKey];
        [params setObject:appAccount.accountId forKey:@"accountId"];
        [params setObject:appAccount.signinCount forKey:@"signinCount"];
    }
    
    return params;
}

- (void) refresh
{
    if (inMain) {
        [[AGNotificationCenter notificationCenter] obtainPlanesAndChains];
    }
}

- (void) kickoff
{
    if (inMain) {
        [[AGManagerUtils managerUtils].accountManager autoSignin:nil block:^(NSError *error, id context) {
            if (error == nil) {
                [[AGNotificationCenter notificationCenter] obtainPlanesAndChains];
                [[AGNotificationCenter notificationCenter] resendMessages];
            }
        }];
    }

}

//appAccount != nil
- (void) gotoMain
{
    if (inMain == NO) {
        inMain = YES;
        [self kickoff];
    }
}

//appAccount != nil
- (void) gotoSign
{
    if (inMain) {
        inMain = NO;
        [self resetAppAccount];
        [[AGRootViewController rootViewController] switchToSign];
    }
    
}

- (void) signout
{
    [[AGManagerUtils managerUtils].accountManager signout:nil block:^(NSError *error, id context) {
        if (error == nil) {
            inMain = NO;
            [self resetAppAccount];
            [[AGNotificationCenter notificationCenter] reset];
            [[AGRootViewController rootViewController] switchToSign];
        }
    }];
    
}


@end
