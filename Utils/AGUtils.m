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
#import "AGNotificationCenter.h"
#import "AGAppDelegate.h"
#import "AGUIUtils.h"

//#warning birthday doesn't neeed this
//GMT string and NSDate
static NSDateFormatter *dateFormatter;

static NSDateFormatter *birthdayFormatter;

static NSString *Year = @"text.ui.year";
static NSString *Month = @"text.ui.month";
static NSString *Day = @"text.ui.day";
static NSString *Hour = @"text.ui.hour";
static NSString *Minute = @"text.ui.minute";

@implementation AGUtils

+ (void) initialize
{
    [AGCategory initialize];
    [AGNotificationCenter initialize];
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    //
    birthdayFormatter = [[NSDateFormatter alloc] init];
    birthdayFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //
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

static void encode(NSMutableString *path, id key, id obj)
{
    NSString *value=@"";
    if ([obj isKindOfClass:[NSString class]]) {
        value = obj;
    }
    else if([obj isKindOfClass:[NSNumber class]]) {
        NSNumber *number = obj;
        if (strcmp(@encode(BOOL), number.objCType) == 0) {
            value = number.boolValue ? @"true" : @"false";
        }
        else{
            value = [number stringValue];
        }
        
    }
    else if([obj isKindOfClass:[NSDate class]]) {
        value = [AGUtils dateToString:obj];
    }
    
    [path appendString:key];
    [path appendString:@"="];
    [path appendString:[value encodeURIComponent]];
    [path appendString:@"&"];
}

+ (void)encodeParams:(NSDictionary*)params path:(NSMutableString*)path device:(BOOL)yes
{
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isKindOfClass:[NSArray class]]) {
            NSArray *array = obj;
            for (id object in array) {
                encode(path, key, object);
            }
        }
        else{
            encode(path, key, obj);
        }
        
    }];
    
    if (yes) {
        NSString * deviceString = [NSString stringWithFormat:@"%@=%d&%@=%d",[@"clientAgent.deviceType" encodeURIComponent],AGDeviceType, [@"clientAgent.clientVersion" encodeURIComponent], AGApplicationVersion];
        [path appendString:deviceString];
        //guid
        deviceString = [NSString stringWithFormat:@"&%@=%@", [@"clientAgent.guid" encodeURIComponent], [[AGAppDelegate appDelegate].appConfig.guid encodeURIComponent]];
        [path appendString:deviceString];
        //
        NSData *deviceToken = [AGAppDelegate appDelegate].deviceToken;
        if (deviceToken) {
            NSString *token = [[deviceToken description] stringByReplacingOccurrencesOfString:@" " withString:@""];
            token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
            [path appendString:[NSString stringWithFormat:@"&clientAgent.deviceToken=%@", token]];
            
        }
        
        
    }
#ifdef IS_DEBUG
    NSLog(@"Encode params: %@",path);
#endif
}

//NSDate to GMT string
+ (NSString*) dateToString:(NSDate*)date
{
    return [dateFormatter stringFromDate:date];
}

//GMT string to NSDate
+ (NSDate*) stringToDate:(NSString*)string
{
    return [dateFormatter dateFromString:string];
}

+ (NSString*) birthdayToString:(NSDate*)date
{
    return [birthdayFormatter stringFromDate:date];
}

+ (NSDate*) stringToBirthday:(NSString*)string
{
    return [birthdayFormatter dateFromString:string];
}

+ (NSString*) dateTillNowToString:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    unsigned flag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:flag fromDate:date toDate:now options:0];
    NSString *string = nil;
    if (dateComponents.year) {
        string = [NSString stringWithFormat:@"%d %@", dateComponents.year, AGLS(Year)];
    }
    else if (dateComponents.month)
    {
        string = [NSString stringWithFormat:@"%d %@", dateComponents.month, AGLS(Month)];
    }
    else if (dateComponents.day)
    {
        string = [NSString stringWithFormat:@"%d %@", dateComponents.day, AGLS(Day)];
    }
    else if (dateComponents.hour)
    {
        string = [NSString stringWithFormat:@"%d %@", dateComponents.hour, AGLS(Hour)];
    }
    else if (dateComponents.minute)
    {
        string = [NSString stringWithFormat:@"%d %@", dateComponents.minute, AGLS(Minute)];
    }
    else{
        string = [NSString stringWithFormat:@"1 %@", AGLS(Minute)];
    }
    return string;
}

+ (NSString*) birthdayToAge:(NSDate*)birthday
{
    if (birthday == nil || [birthday isKindOfClass:[NSDate class]] == NO) {
        return @"0";
    }
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

+ (NSArray*) mergeSortedArray:(NSArray*) first second:(NSArray*)second usingBlock:(AGMergeSortedArrayBlock)block
{
    assert(block);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:first.count + second.count];
    int i = 0, j = 0;
    while (YES) {
        if (i == first.count) {
            while (j < second.count) {
                [array addObject:[second objectAtIndex:j++]];
            }
            break;
        }
        
        if (j == second.count) {
            while (i < first.count) {
                [array addObject:[first objectAtIndex:i++]];
            }
            break;
        }
        
        id obj1 = [first objectAtIndex:i];
        id obj2 = [second objectAtIndex:j];
        if (block(obj1, obj2) > 0) {
            [array addObject:obj1];
            ++i;
        }
        else{
            [array addObject:obj2];
            ++j;
        }
    }
    return array;
}


@end
