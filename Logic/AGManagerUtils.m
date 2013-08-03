//
//  AGManagerUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 8/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGManagerUtils.h"

@implementation AGManagerUtils

@synthesize accountManager;
@synthesize profileManager;

-(id) init
{
    if (self = [super init]) {
        accountManager = [[AGAccountManager alloc] init];
        profileManager = [[AGProfileManager alloc] init];
    }
    return self;
}

+ (AGManagerUtils*) managerUtils
{
    static dispatch_once_t  onceToken;
    static AGManagerUtils * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[AGManagerUtils alloc] init];
    });
    return sSharedInstance;
}

@end
