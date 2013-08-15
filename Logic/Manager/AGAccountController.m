//
//  AGCoreDataManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAccountController.h"
#import "AGAppDelegate.h"


@interface AGAccountController()
{
    AGCoreData *coreData;
}

@end


@implementation AGAccountController


-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
    }
    return self;
}

- (AGAccount *) saveAccount:(NSDictionary*)jsonDictionary
{
    AGAccount *account = (AGAccount *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGAccount"];
    [coreData save];
    return account;
}

- (AGAccount*) findAccount:(NSNumber*)accountId
{
    return (AGAccount*)[coreData findById:accountId withEntityName:@"AGAccount"];
}


@end
