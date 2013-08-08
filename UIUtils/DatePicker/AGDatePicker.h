//
//  AGDatePicker.h
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGDatePickerDelegate <NSObject>

- (void) finish:(BOOL)done;

@end

@interface AGDatePicker : NSObject

@property (weak, nonatomic) id <AGDatePickerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;


@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end
