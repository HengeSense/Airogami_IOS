//
//  UIBubbleTableView.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>

#import "UIBubbleTableViewDataSource.h"
#import "AGBubbleTableViewDelegate.h"
#import "UIBubbleTableViewCell.h"

typedef enum _NSBubbleTypingType
{
    NSBubbleTypingTypeNobody = 0,
    NSBubbleTypingTypeMe = 1,
    NSBubbleTypingTypeSomebody = 2
} NSBubbleTypingType;

@interface UIBubbleTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet id<UIBubbleTableViewDataSource> bubbleDataSource;
@property (nonatomic, weak) IBOutlet id<AGBubbleTableViewDelegate> bubbleDelegate;
@property (nonatomic) NSTimeInterval snapInterval;
@property (nonatomic) NSBubbleTypingType typingBubble;
@property (nonatomic) BOOL showAvatars;
@property(nonatomic, assign) BOOL refreshable;
@property(nonatomic, strong) UIActivityIndicatorView *indicator;

//- (void) reloadToBottom;
//- (void) reloadToBottom:(BOOL)animated;
- (void) didSelectCellAtIndexPath:(NSIndexPath*) indexPath bubbleData:(NSBubbleData*)bubbleData type:(UIBubbleTableViewCellSelectType) type;
- (void)addData:(BOOL)append animated:(BOOL)animated;

@end
