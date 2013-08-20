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

typedef enum _NSBubbleCellState
{
    BubbleCellStateSending = -2,
    BubbleCellStateSent = -1,
    BubbleCellStateSendFailed = 0,
    BubbleCellStateSentLiked = 1,
    BubbleCellStateReceivedUnliked = 2,
    BubbleCellStateReceivedLiked = 3
} NSBubbleCellState;

#define kBubbleCellStateButtonWidth 40

@interface NSBubbleData : NSObject

@property (nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSBubbleType type;
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) AGAccount *account;
@property (nonatomic, strong) id obj;
@property (nonatomic, assign) NSBubbleCellState state;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;

@end
