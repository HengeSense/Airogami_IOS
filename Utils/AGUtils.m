//
//  AGUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 6/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGUtils.h"
#import "AGPlaneCategory.h"
#import "NSString+Addition.h"

@implementation AGUtils

+ (void) initialize
{
    [AGPlaneCategory initialize];
}

+ (UIImage *)normalizeImage:(UIImage*)image {
    if (image.imageOrientation != UIImageOrientationUp){
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawInRect:(CGRect){0, 0, image.size}];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

+ (NSArray *)localizedStringArray:(NSString*)prefix count:(int) count
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; ++i) {
        NSString *key = [NSString stringWithFormat:@"%@_%d", prefix, i];
        [array addObject:NSLocalizedString(key, key)];
    }
    return array;
}

+ (void)encodeParams:(NSDictionary*)params path:(NSMutableString*)path device:(BOOL)yes
{
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *value = obj;
        [path appendString:key];
        [path appendString:@"="];
        [path appendString:[value encodeURIComponent]];
        [path appendString:@"&"];
        
    }];
    
    if (yes) {
        [path appendString:@"clientAgent.deviceName=IOS&clientAgent.clientVersion="];
        [path appendString:AGApplicationVersion];
    }
}

@end
