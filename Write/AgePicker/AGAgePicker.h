//
//  AGAgePicker.h
//  Airogami
//
//  Created by Tianhu Yang on 10/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGAgePickerDelegate <NSObject>

- (void) finish:(BOOL)done;

@end

@interface AGAgePicker : NSObject<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) id <AGAgePickerDelegate> delegate;
@property (weak, nonatomic) UIView *view;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;

@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (assign, nonatomic) int start;

@property (assign, nonatomic) int end;

+ (AGAgePicker*)agePicker;

@end
