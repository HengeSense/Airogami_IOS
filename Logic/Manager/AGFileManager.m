//
//  AGFileManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGFileManager.h"

static NSURL *DataUrl;
static NSURL *DatabaseUrl;
static NSURL *ConfigUrl;
static NSURL *rootUrl;

@implementation AGFileManager

-(id) init
{
    if (self = [super init]) {
        NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        rootUrl = [urls objectAtIndex:0];
        DataUrl = [NSURL URLWithString:@"Data" relativeToURL:rootUrl];
        DatabaseUrl = [NSURL URLWithString:@"Data/DB" relativeToURL:rootUrl];
        ConfigUrl = [NSURL URLWithString:@"Config" relativeToURL:rootUrl];
    }
    return self;
}

- (NSURL*) urlForData
{
    return DataUrl;
}

- (NSURL*) urlForDatabase
{
    return DatabaseUrl;
}

- (NSURL*) urlForConfig
{
    return ConfigUrl;
}

@end
