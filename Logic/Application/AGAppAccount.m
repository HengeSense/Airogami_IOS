//
//  AGAppAccount.m
//  Airogami
//
//  Created by Tianhu Yang on 8/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAppAccount.h"

@implementation AGAppAccount

@synthesize accountId;
@synthesize email;
@synthesize screenName;
@synthesize password;

- (NSArray*) codingProperties
{
    static NSArray *keys;
    if (keys == nil) {
        keys = [self propertyKeys];
    }
    return keys;
}

@end
