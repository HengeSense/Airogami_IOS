//
//  NSBubbleData.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>
#import "AGAccount.h"

#define kAvartarHeight 48
#define kCellSpacing 10
#define kAvatarMargin 4

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;


#define kBubbleCellStateButtonWidth 40

@interface NSBubbleData : NSObject

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *imageKey;
@property (nonatomic, retain) NSURL *imageURL;
@property (readonly, nonatomic) NSBubbleType type;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (nonatomic, retain) UIImage *avatar;
@property (nonatomic, retain) AGAccount *account;
@property (nonatomic, retain) id obj;
@property (nonatomic, assign) AGSendStateEnum state;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL interactive;

+ (UIFont *) font;
- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
//- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImageURL:(NSURL*)url size:(CGSize)size date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImageKey:(NSString *)imageKey url:(NSURL*)url size:(CGSize)size date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image size:(CGSize)size date:(NSDate *)date type:(NSBubbleType)type;
//- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
//+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;

@end
