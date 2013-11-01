//
//  AGImageTextPicker.h
//  Airogami
//
//  Created by Tianhu Yang on 10/31/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    AGImagePickerType_Library,
    AGImagePickerType_Camera
}AGImagePickerType;

@class AGImageTextPicker;

@protocol AGImageTextPickerDelegate <NSObject>

- (void)imageTextPicker:(AGImageTextPicker *)imagePicker didFinish:(BOOL)finished image:(UIImage *)image text:(NSString*)text;

@end

@interface AGImageTextPicker : UIViewController

@property(nonatomic, weak) id<AGImageTextPickerDelegate> delegate;

+(id) imageTextPicker;

- (void) pick:(UIViewController *)viewController type:(AGImagePickerType)type;

@end
