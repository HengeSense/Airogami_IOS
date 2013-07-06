//
//  AGSexSwitch.m
//  Airogami
//
//  Created by Tianhu Yang on 7/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGSexSwitch.h"

@implementation AGSexSwitch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    self.onText = @"Male";
    self.offText = @"Female";
    self.offTintColor = [UIColor colorWithRed:0xf2 / 255.f green:0x7f / 255.f blue:0x7a / 255.f alpha:1.0f];
    self.onTintColor = [UIColor colorWithRed:0x75 / 255.f green:0xab / 255.f blue:0xd0 / 255.f alpha:1.0f];
    self.on = YES;
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
