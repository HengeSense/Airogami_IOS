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

- (void) updateAppAccount:(AGAccount*)account password:(NSString *)password
{
    if (appAccount == nil) {
        appAccount = [[AGAppAccount alloc] init];
    }
    appAccount.accountId = account.accountId;
    appAccount.email = account.authenticate.email;
    appAccount.screenName = account.profile.screenName;
    appAccount.password = password;
    appAccount.signinCount = account.accountStat.signinCount;
    [self save];
}

- (void) updatePassword:(NSString*)password
{
    if (appAccount) {
        appAccount.password = password;
    }
    [self save];
}

- (void) resetAppAccount
{
    self.appAccount = nil;
    [self save];
}

- (BOOL) needSignin
{
    return appAccount == nil;
}


- (NSMutableDictionary*) autoSigninParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    if (appAccount) {
        
        if (appAccount.email.length > 0) {
            [params setObject:appAccount.email forKey:AGLogicAccountEmailKey];
        }
        else if(appAccount.screenName.length > 0){
            [params setObject:appAccount.screenName forKey:AGLogicAccountScreenNameKey];
        }
        if (params.count) {
            [params setObject:appAccount.password forKey:AGLogicAccountPasswordKey];
            [params setObject:appAccount.accountId forKey:@"accountId"];
            [params setObject:appAccount.signinCount forKey:@"signinCount"];
        }
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
    [[AGManagerUtils managerUtils].accountManager autoSignin:nil block:^(NSError *error, id context) {
        if (error == nil) {
            [[AGNotificationCenter notificationCenter] obtainPlanesAndChains];
            [[AGNotificationCenter notificationCenter] resendMessages];
        }
    }];
}

//appAccount != nil
- (void) gotoMain
{
    [AGFileManager fileManager].accountId = appAccount.accountId;
    AGAccountManager *accountManager = [AGManagerUtils managerUtils].accountManager;
    if (accountManager.account == nil) {
        accountManager.account = [[AGControllerUtils controllerUtils].accountController findAccount:appAccount.accountId];
    }
    inMain = YES;
    [self refresh];
}

- (void) gotoSign
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
