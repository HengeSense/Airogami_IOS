//
//  AGDatePicker.m
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGDatePicker.h"

@implementation AGDatePicker

@synthesize delegate, titleLabel;

- (id) init
{
    if (self = [super init]) {
        [[NSBundle mainBundle] loadNibNamed:@"AGDatePickerView" owner:self options:nil];
        [self.toolBar addSubview:titleLabel];
    }
    return self;
}

- (IBAction)cancelTouched:(UIBarButtonItem *)sender {
    [delegate finish:NO];
}


- (IBAction)doneTouched:(UIBarButtonItem *)sender {
    [delegate finish:YES];
}


@end
