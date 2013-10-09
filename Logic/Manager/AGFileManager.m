//
//  AGFileManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGFileManager.h"
#import "AGManagerUtils.h"
#import "AGAppDirector.h"

static NSURL *DataUrl;
static NSURL *DatabaseUrl;
static NSURL *ConfigUrl;
static NSURL *rootUrl;

@implementation AGFileManager


-(id) init
{
    if (self = [super init]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        rootUrl = [urls objectAtIndex:0];
        DataUrl = [rootUrl URLByAppendingPathComponent:@"Data"];
        DatabaseUrl = [rootUrl URLByAppendingPathComponent:@"Data/DB"];
        ConfigUrl = [rootUrl URLByAppendingPathComponent:@"Config"];
        if (![fileManager fileExistsAtPath:DataUrl.path]) {
            [fileManager createDirectoryAtURL:DataUrl withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileManager fileExistsAtPath:DatabaseUrl.path]) {
            [fileManager createDirectoryAtURL:DatabaseUrl withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileManager fileExistsAtPath:ConfigUrl.path]) {
            NSError *error;
            [fileManager createDirectoryAtURL:ConfigUrl withIntermediateDirectories:YES attributes:nil error:&error];
#ifdef IS_DEBUG
            if (error) {
                NSLog(@"AGFileManager init: %@", error.localizedDescription);
            }
            
#endif
        }
    }
    return self;
}

- (NSURL*) urlForData
{
    return DataUrl;
}

- (NSURL*) urlForDatabase
{
    NSNumber *accountId = [AGAppDirector appDirector].appConfig.appAccount.accountId;
    NSString *str = accountId.stringValue;
    NSURL *url = nil;
    if (str) {
        url = [DatabaseUrl URLByAppendingPathComponent:str];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:url.path]) {
            [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return url;
}

- (NSURL*) urlForConfig
{
    return ConfigUrl;
}

+ (AGFileManager*)fileManager
{
    static AGFileManager *fileManager;
    if (fileManager == nil) {
        fileManager = [[AGFileManager alloc] init];
    }
    return fileManager;
}

@end
