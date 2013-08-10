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

- (BOOL) editAttributes:(NSMutableDictionary*)attributeDictionary managedObject:(NSManagedObject *)managedObject
{
    [attributeDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [managedObject setValue:obj forKey:key];
    }];
    return [coreData save];
}

- (AGAccount*) findAccount:(NSNumber*)accountId
{
    return (AGAccount*)[coreData findById:accountId withEntityName:@"AGAccount"];
}


@end
