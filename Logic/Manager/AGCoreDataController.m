//
//  AGCoreDataManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCoreDataController.h"
#import "AGAppDelegate.h"
#import "AGCoreData.h"


@interface AGCoreDataController()

@end


@implementation AGCoreDataController

@synthesize coreData;

-(id)init
{
    if (self = [super init]) {
        coreData = [[AGCoreData alloc] init];
    }
    return self;
}

- (AGAccount *) saveAccount:(NSMutableDictionary*)jsonDictionary
{
    AGAccount *account = (AGAccount *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGAccount"];
    [coreData save];
    return account;
}

@end
