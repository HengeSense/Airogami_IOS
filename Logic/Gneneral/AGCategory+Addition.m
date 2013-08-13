//
//  AGCategory+Addition.m
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCategory+Addition.h"

static NSDictionary *categoryDict;
//static NSString* names[] = {@"Random", @"Qustion", @"Confession", @"Relationship", @"LocalInfo", @"Feeling", @"Chain"};
static NSString* keys[] = {
    @"plane.category.random",
    @"plane.category.question",
    @"plane.category.confession",
    @"plane.category.relationship",
    @"plane.category.localinfo",
    @"plane.category.feeling",
    @"plane.category.chain"
};

static NSString *key = @"plane.category.unknown";

@implementation AGCategory (Addition)

+(void) initialize
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    for (int i = 0 ; i < 7; ++i) {
        NSNumber *categoryId = [NSNumber numberWithInt:i + 1];
        [dict setObject:NSLocalizedString(keys[i], keys[i]) forKey:categoryId];
    }
    categoryDict = dict;
}

+(NSString*) title:(NSNumber*)categoryId
{
    NSString *title = [categoryDict objectForKey:categoryId];
    if (title == nil) {
        title = NSLocalizedString(key, key);
    }
    return title;
}

@end
