//
//  AGUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 6/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGUtils.h"
#import "AGCategory.h"
#import "NSString+Addition.h"

static NSDateFormatter *dateFormatter;

@implementation AGUtils

+ (void) initialize
{
    [AGCategory initialize];
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
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
        NSString *value=@"";
        if ([obj isKindOfClass:[NSString class]]) {
            value = obj;
        }
        else if([obj isKindOfClass:[NSNumber class]]) {
            value = [((NSNumber*)obj) stringValue];
        }
        else if([obj isKindOfClass:[NSDate class]]) {
            value = [AGUtils dateToString:obj];
        }
        
        [path appendString:key];
        [path appendString:@"="];
        [path appendString:[value encodeURIComponent]];
        [path appendString:@"&"];
        
    }];
    
    if (yes) {
        [path appendString:@"clientAgent.deviceName=IOS&clientAgent.clientVersion="];
        [path appendString:AGApplicationVersion];
    }
#ifdef IS_DEBUG
    NSLog(@"Encode params: %@",path);
#endif
}

+ (NSString*) dateToString:(NSDate*)date
{
    return [dateFormatter stringFromDate:date];
}

+ (NSDate*) stringToDate:(NSString*)string
{
    return [dateFormatter dateFromString:string];
}

+ (NSString*) birthdayToAge:(NSDate*)birthday
{
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    return [NSString stringWithFormat:@"%d",age];
}

+ (NSString *)obtainUuid
{
    CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    NSString *      result;
    
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    result = [NSString stringWithFormat:@"%@", uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}


@end
