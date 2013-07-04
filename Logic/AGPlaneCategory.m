//
//  AGPlaneCategory.m
//  Airogami
//
//  Created by Tianhu Yang on 7/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPlaneCategory.h"

static NSDictionary *categoryDict;
static NSString* names[] = {@"Random", @"Qustion", @"Confession", @"Relationship", @"LocalInfo", @"Feeling", @"Chain"};
static NSString* keys[] = {
@"plane.category.random",
@"plane.category.question",
@"plane.category.confession",
@"plane.category.relationship",
@"plane.category.localinfo",
@"plane.category.feeling",
@"plane.category.chain"
};

@implementation AGPlaneCategory

@synthesize categoryId, name, description;

-(id) initWithId:(int)ID name:(NSString*)aName description:(NSString*) aDescription
{
    if (self = [super init]) {
        categoryId = [NSNumber numberWithInt:ID];
        name = aName;
        description = aDescription;
    }
    return self;
}


+(void) initialize
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    for (int i = 0 ; i < 7; ++i) {
        AGPlaneCategory *category = [[AGPlaneCategory alloc] initWithId:i + 1 name:names[i] description:NSLocalizedString(keys[i], keys[i])];
        [dict setObject:category forKey:category.categoryId];
    }
    categoryDict = dict;
}

+(AGPlaneCategory*) categoryWithId:(int)ID
{
    return [categoryDict objectForKey:[NSNumber numberWithInt:ID]];
}

@end
