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

static NSString *configName = @"AppConfig";
static NSString *path;

@interface AGAppConfig()
{
}

@end

@implementation AGAppConfig

@synthesize once;
@synthesize appAccount;
@synthesize appVersion;
@synthesize signinUuid;

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
        if ([appConfig.appVersion isEqualToString:AGApplicationVersion] == NO) {
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
        signinUuid = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
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
    [self save];
}

- (void) resetAppAccount
{
    self.appAccount = nil;
    [self save];
}

- (BOOL) needSignin
{
    return [AGManagerUtils managerUtils].accountManager.account == nil;
}

- (BOOL) accountUpdated:(AGAccount*)account
{
    return NO;
}

- (NSMutableDictionary*) siginParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    if (appAccount) {
        [params setObject:appAccount.password forKey:AGLogicAccountPasswordKey];
        if (appAccount.email.length > 0) {
            [params setObject:appAccount.email forKey:AGLogicAccountEmailKey];
        }
        else{
            [params setObject:appAccount.screenName forKey:AGLogicAccountScreenNameKey];
        }
    }
    
    return params;
}

- (AGAccount*) obtainAccount
{
    if (appAccount) {
        return [[AGControllerUtils controllerUtils].accountController findAccount:appAccount.accountId];
    }
    return nil;
}

- (void) signin
{
    [[AGManagerUtils managerUtils].accountManager autoSignin];
}

- (void) signout
{
    [[AGManagerUtils managerUtils].accountManager signout];
    [self resetAppAccount];
}

@end
