//
//  YTTabBarItem.m
//  Airogami
//
//  Created by Tianhu Yang on 6/17/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "YTTabBarItem.h"
#import "AGUIUtils.h"

#define YTTabBarItemIconWidth 20

@implementation YTTabBarItem

@synthesize delegate, badge;

- (id)initWithFrame:(CGRect)frame index:(int)anIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        index = anIndex;
        //
        UIColor *aSelectedColor = [UIColor whiteColor];
        UIColor *anUnselectedColor = [UIColor grayColor];
        [self setTitleColor:aSelectedColor forState:UIControlStateSelected];
        [self setTitleColor:anUnselectedColor forState:UIControlStateNormal];
        [self setTitleColor:aSelectedColor forState:UIControlStateSelected | UIControlStateHighlighted];
        self.titleLabel.font = [AGUIUtils themeFont:AGThemeFontStyleMedium size:15.0f];
        //
        UIEdgeInsets edgeInset = UIEdgeInsetsZero;
        edgeInset.left = YTTabBarItemIconWidth;
        self.titleEdgeInsets = edgeInset;
        //
        [self addTarget:self action:@selector(onButtonTouched:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

-(void) setSelectedImage:(UIImage*)aSelectedImage unseletedImage:(UIImage*)anUnselectedImage
{
    [self setBackgroundImage: aSelectedImage forState:UIControlStateSelected];
    [self setBackgroundImage: aSelectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    [self setBackgroundImage: anUnselectedImage forState:UIControlStateNormal];
}

-(void) setSelectedColor:(UIColor*)aSelectedColor unseletedColor:(UIColor*)anUnselectedColor
{
    
    [self setTitleColor:aSelectedColor forState:UIControlStateSelected];
    [self setTitleColor:anUnselectedColor forState:UIControlStateNormal];
    [self setTitleColor:aSelectedColor forState:UIControlStateSelected | UIControlStateHighlighted];
}

- (void) setText:(NSString *)aText
{
    [self setTitle:aText forState:UIControlStateNormal];
}

- (NSString*) text
{
    return [self titleForState:UIControlStateNormal];
}

- (void) onButtonTouched:(UIButton*) sender
{
    if (sender.selected == NO) {
        [delegate onSelected:index];
    }

}

- (void) setBadge:(NSString *)aBadge
{
    badge = aBadge;
    if (customBadge == nil) {
        customBadge = [CustomBadge customBadgeWithString:badge
                                                       withStringColor:[UIColor whiteColor]
                                                        withInsetColor:[UIColor redColor]
                                                        withBadgeFrame:YES
                                                   withBadgeFrameColor:[UIColor whiteColor] 
                                                             withScale:1.0
                                                           withShining:YES];
        [self addSubview:customBadge];
    }
    else{
        customBadge.badgeText = badge;
    }
    
    if (badge.length == 0) {
        customBadge.hidden = YES;
    }
    else
    {
        customBadge.hidden = NO;
        CGRect frame = customBadge.frame;
        frame.origin.y = 3;
        frame.origin.x = self.frame.size.width - frame.size.width - 10;
        customBadge.frame = frame;
    }
}

@end
