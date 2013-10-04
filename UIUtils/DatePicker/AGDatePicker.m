//
//  AGDatePicker.m
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGDatePicker.h"

static int MinAge = 13;
static int MaxAge = 99;

@implementation AGDatePicker

@synthesize delegate, titleLabel;

- (id) init
{
    if (self = [super init]) {
        [[NSBundle mainBundle] loadNibNamed:@"AGDatePickerView" owner:self options:nil];
        [self.toolBar addSubview:titleLabel];
        //
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.year = -MinAge;
        self.datePicker.maximumDate = [calendar dateByAddingComponents:comps toDate:date options:0];
        //
        comps.year = -MaxAge;
        self.datePicker.minimumDate = [calendar dateByAddingComponents:comps toDate:date options:0];
        //
        
        comps.year = -20;
        self.datePicker.date = [calendar dateByAddingComponents:comps toDate:date options:0];
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
