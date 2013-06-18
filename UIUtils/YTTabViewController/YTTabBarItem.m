//
//  YTTabBarItem.m
//  Airogami
//
//  Created by Tianhu Yang on 6/17/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "YTTabBarItem.h"

#define YTTabBarItemIconWidth 50

@implementation YTTabBarItem

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame index:(int)anIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        selectedColor = [UIColor whiteColor];
        unselectedColor = [UIColor grayColor];
        index = anIndex;
        //button
        frame.origin.x = 0;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        [button addTarget:self action:@selector(onButtonTouched:) forControlEvents:UIControlEventTouchDown];
        frame.origin.x = YTTabBarItemIconWidth;
        frame.size.width = frame.size.width - frame.origin.x;
        [self addSubview:button];
        //label
        label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = unselectedColor;
        label.font = [UIFont boldSystemFontOfSize:12];
        [self addSubview:label];
    }
    return self;
}

-(void) setSelectedImage:(UIImage*)aSelectedImage unseletedImage:(UIImage*)anUnselectedImage
{
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:selectedImage = aSelectedImage forState:UIControlStateSelected];
    [button setBackgroundImage:unselectedImage = anUnselectedImage forState:UIControlStateNormal];
}

-(void) setSelectedColor:(UIColor*)aSelectedColor unseletedColor:(UIColor*)anUnselectedColor
{
    
    selectedColor = aSelectedColor;
    unselectedColor = anUnselectedColor;
    if (button.selected) {
        label.textColor = aSelectedColor;
    }
    else
    {
        label.textColor = anUnselectedColor;
    }
}

- (void) setText:(NSString *)aText
{
    label.text = aText;
}

- (NSString*) text
{
    return label.text;
}

- (void) setSelected:(BOOL)selected
{
    if (selected) {
        label.textColor = selectedColor;
        //[button setImage:selectedImage forState:UIControlStateHighlighted];
    }
    else{
        label.textColor = unselectedColor;
        //[button setImage:unselectedImage forState:UIControlStateHighlighted];
    }
    button.selected = selected;
}

- (BOOL) selected
{
    return button.selected;
}

- (void) onButtonTouched:(UIButton*) sender
{
    if (sender.selected == NO) {
        self.selected = YES;
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
