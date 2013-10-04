//
//  AGAgePicker.m
//  Airogami
//
//  Created by Tianhu Yang on 10/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAgePicker.h"
#import "AGMessageUtils.h"
#import "AGUIUtils.h"

static int MinAge = 13;
static NSString * AgeInvalidMessage = @"message.ui.write.edit.age.invalid";
static NSString * AgeStartTitle = @"title.ui.write.edit.age.start";
static NSString * AgeEndTitle = @"title.ui.write.edit.age.end";

@implementation AGAgePicker

@synthesize titleLabel, delegate;
@synthesize start, end;
@synthesize view;

- (id) init
{
    if (self = [super init]) {
        [[NSBundle mainBundle] loadNibNamed:@"AGAgePickerView" owner:self options:nil];
        [self.toolBar addSubview:titleLabel];
    }
    return self;
}

- (IBAction)cancelTouched:(UIBarButtonItem *)sender {
    [delegate finish:NO];
}


- (IBAction)doneTouched:(UIBarButtonItem *)sender {
    if ([self validate]) {
        [delegate finish:YES];
    }
    
}

- (BOOL)validate
{
    BOOL succeed = YES;
    if (start != -1 && end != -1 && start > end) {
        succeed = NO;
        [AGMessageUtils errorMessgeWithTitle:AgeInvalidMessage view:self.view];
    }
    return succeed;
}

- (void) setStart:(int)start_
{
    start = start_;
    int row = 0;
    if (start != -1) {
        row = start - MinAge + 1;
    }

    [self.pickerView selectRow:row inComponent:0 animated:NO];
}

- (void) setEnd:(int)end_
{
    end = end_;
    int row = 0;
    if (end != -1) {
        row = end - MinAge + 1;
    }
    
    [self.pickerView selectRow:row inComponent:1 animated:NO];
}

#pragma mark - pickerView delegate

- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        if (row == 0) {
            start = -1;
        }
        else{
            start = MinAge + row - 1;
        }
    }
    else{
        if (row == 0) {
            end = -1;
        }
        else{
            end = MinAge + row - 1;
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 88;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    if (row == 0) {
        if (component == 0) {
            title = AGLS(AgeStartTitle);
        }
        else{
            title = AGLS(AgeEndTitle);
        }
    }
    else{
        title = [NSString stringWithFormat:@"%d", MinAge + row - 1];
    }
    
    return title;
}

+ (AGAgePicker*)agePicker
{
    return [[AGAgePicker alloc] init];
}

@end
