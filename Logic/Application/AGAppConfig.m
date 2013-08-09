//
//  AGAppConfig.m
//  Airogami
//
//  Created by Tianhu Yang on 8/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAppConfig.h"
#import "AGManagerUtils.h"

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

+ (AGAppConfig*)appConfig
{
    NSURL *url = [[AGManagerUtils managerUtils].fileManager urlForConfig];
    url = [url URLByAppendingPathComponent:configName];
    path = url.path;
    AGAppConfig *appConfig = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (appConfig == nil) {
        appConfig = [[AGAppConfig alloc] init];
        BOOL succeed = [NSKeyedArchiver archiveRootObject:appConfig toFile:path];
        NSLog(@"%@", [NSNumber numberWithBool:succeed]);
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
    }
    return self;
}

@end
