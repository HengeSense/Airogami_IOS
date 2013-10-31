//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "NSBubbleData.h"
#import "AGUIUtils.h"
#import <QuartzCore/QuartzCore.h>

#define kConstrainedWidth 190

#define kMaxImageWidth 90

@implementation NSBubbleData

#pragma mark - Properties

@synthesize content = _content;
@synthesize date = _date;
@synthesize type = _type;
@synthesize image = _image;
@synthesize imageKey = _imageKey;
@synthesize imageURL = _imageURL;
@synthesize insets = _insets;
@synthesize avatar = _avatar;
@synthesize state = _state;
@synthesize account = _account;
@synthesize obj = _obj;
@synthesize size = _size;
@synthesize interactive = _interactive;


#pragma mark - Text bubble

const UIEdgeInsets textInsetsMine = {10, 19 , 11, 22};
const UIEdgeInsets textInsetsSomeone = {10, 25, 11, 20};

+(UIFont *) font
{
    static UIFont *font;
    if (font == nil) {
        font = [AGUIUtils themeFont:AGThemeFontStyleMedium size:15.0f];
    }
    return font;
}

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
    return [[NSBubbleData alloc] initWithText:text date:date type:type];
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
    if (self = [super init]) {
        _content = text;
        _type = type;
        _date = date;
        _insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
        //
        _size = [(text ? text : @"") sizeWithFont:NSBubbleData.font constrainedToSize:CGSizeMake(kConstrainedWidth, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    }
    return self;
}

#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {10, 19 , 11, 22};
const UIEdgeInsets imageInsetsSomeone = {10, 25, 11, 20};

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
    NSBubbleData *bubbleData = [[NSBubbleData alloc] initWithImage:image date:date type:type];
    return bubbleData;
}

+ (id)dataWithImageKey:(NSString *)imageKey url:(NSURL*)url size:(CGSize)size date:(NSDate *)date type:(NSBubbleType)type
{
    return [[NSBubbleData alloc] initWithObject:imageKey url:url size:size date:date type:type];
}

+ (id)dataWithImage:(UIImage *)image size:(CGSize)size date:(NSDate *)date type:(NSBubbleType)type
{
    return [[NSBubbleData alloc] initWithObject:image url:nil size:size date:date type:type];
}

+ (id)dataWithImageURL:(NSURL*)url size:(CGSize)size date:(NSDate *)date type:(NSBubbleType)type
{
    return [[NSBubbleData alloc] initWithObject:nil url:url size:size date:date type:type];
}

- (id)initWithObject:(id)object url:(NSURL*)url size:(CGSize)size date:(NSDate *)date type:(NSBubbleType)type
{
    if (self = [super init]) {
        if (size.width > size.height)
        {
            size.height /= (size.width / kMaxImageWidth);
            size.width = kMaxImageWidth;
        }
        else{
            size.width /= (size.height / kMaxImageWidth);
            size.height = kMaxImageWidth;
        }
        _size = size;
        if ([object isKindOfClass:[NSString class]]) {
            _imageKey = object;
        }
        else if([object isKindOfClass:[UIImage class]]){
            _image = object;
        }
        _imageURL = url;
        _date = date;
        _type = type;
        _insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
        _interactive = YES;
    }
    
    return self;
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type
{
    if (self = [super init]) {
        _size = image.size;
        _image = image;
        _type = type;
        _date = date;
        _insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    }
    
    return self;
}

@end
