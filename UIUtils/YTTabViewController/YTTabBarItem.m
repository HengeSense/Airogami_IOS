//
//  YTTabBarItem.m
//  Airogami
//
//  Created by Tianhu Yang on 6/17/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "YTTabBarItem.h"

#define YTTabBarItemIconWidth 20

@implementation YTTabBarItem

@synthesize delegate;

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
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
