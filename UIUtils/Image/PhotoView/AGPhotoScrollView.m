//
//  AGImageScrollView.m
//  Airogami
//
//  Created by Tianhu Yang on 10/31/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPhotoScrollView.h"

@implementation AGPhotoScrollView

@synthesize photoScrollViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maximumZoomScale = 2.0f;
        self.minimumZoomScale = 1.0f;
        self.showsHorizontalScrollIndicator = self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UIView *view = [self viewWithTag:1];
    if ([event touchesForView:view].count == 0) {
        [photoScrollViewDelegate dismiss];
    }
    
}


@end
