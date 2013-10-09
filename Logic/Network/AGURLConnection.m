//
//  AGURLConnection.m
//  Airogami
//
//  Created by Tianhu Yang on 8/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGURLConnection.h"
#import "AGMessageUtils.h"

@interface AGURLConnection()

{
    NSMutableDictionary *dict;
}

@end

@implementation AGURLConnection

-(void) setValue:(id)value forUndefinedKey:(NSString *)key
{
    if (dict == nil) {
        dict = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    [dict setObject:value forKey:key];
}

-(id) valueForUndefinedKey:(NSString *)key
{
    return [dict objectForKey:key];
}

-(void) cancel
{
    [super cancel];
    AGURLConnectionFinishBlock block = [dict valueForKey:@"ResultBlock"];
    if (block) {
        NSError *error = [AGMessageUtils errorCancel];
        id context = [dict valueForKey:@"Context"];
        block(error, context, nil);
    }
}

@end
