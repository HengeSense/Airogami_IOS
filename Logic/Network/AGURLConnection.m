//
//  AGURLConnection.m
//  Airogami
//
//  Created by Tianhu Yang on 8/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGURLConnection.h"

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

@end
