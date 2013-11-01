//
//  AGPhotoLabel.m
//  Airogami
//
//  Created by Tianhu Yang on 10/31/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPhotoLabel.h"
#import "AGUIUtils.h"

@implementation AGPhotoLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [AGUIUtils themeFont:AGThemeFontStyleMedium size:16.0f];
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6f];
        self.numberOfLines = 0;
        self.userInteractionEnabled = YES;
        self.tag = 1;
    }
    return self;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint previous = [touch previousLocationInView:self];
    CGPoint now = [touch locationInView:self];
    CGRect frame = self.frame;
    frame.origin.y += now.y - previous.y;
    if (frame.origin.y >= 0 && frame.origin.y + frame.size.height <= self.superview.bounds.size.height) {
        self.frame = frame;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
