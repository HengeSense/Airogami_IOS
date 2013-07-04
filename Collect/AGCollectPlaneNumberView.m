//
//  AGCollectPlaneNumberView.m
//  Airogami
//
//  Created by Tianhu Yang on 7/3/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCollectPlaneNumberView.h"
#import "AGUIUtils.h"

static float color[] = {76 / 255.0f, 217 / 255.0f, 100 / 255.0f, 1.0};

@interface AGCollectPlaneNumberView()
{
}

@end

@implementation AGCollectPlaneNumberView

@synthesize numberLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin.x = 0;
        frame.origin.y = 0;
        numberLabel = [[UILabel alloc] initWithFrame:frame];
        numberLabel.font = [AGUIUtils themeFont:AGThemeFontStyleHeavy size:88];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.backgroundColor = self.backgroundColor = [UIColor clearColor];
        [self addSubview:numberLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    CGContextSetFillColor(context, color);
    CGContextAddEllipseInRect(context, rect);
    CGContextFillPath(context);
}


+ (AGCollectPlaneNumberView*) numberView:(UIView*)superview
{
    CGRect frame = superview.bounds;
    frame.origin.x = frame.size.width / 2;
    frame.origin.y = frame.size.height / 2;
    frame.size = CGSizeMake(118, 118);
    frame.origin.x -= frame.size.width / 2;
    frame.origin.y -= frame.size.height / 2;
    AGCollectPlaneNumberView *numberView = [[AGCollectPlaneNumberView alloc] initWithFrame:frame];
    [superview addSubview:numberView];
    return numberView;
}

@end
