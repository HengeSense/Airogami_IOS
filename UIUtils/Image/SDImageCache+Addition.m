//
//  SDImageCache+Addition.m
//  Airogami
//
//  Created by Tianhu Yang on 10/29/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "SDImageCache+Addition.h"

@implementation SDImageCache (Addition)

+(SDImageCache*) imageCache
{
    static SDImageCache *imageCache;
    if (imageCache == nil) {
        imageCache = [SDImageCache.alloc initWithNamespace:@"ImageCache"];
        imageCache.maxCacheAge = INT32_MAX;
        imageCache.maxCacheSize = INT64_MAX;
    }
    return imageCache;
}

@end
