//
//  AGImagePicker.h
//  Airogami
//
//  Created by Tianhu Yang on 10/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    AGImagePickerType_Library,
    AGImagePickerType_Camera
}AGImagePickerType;

@class AGImagePicker;

@protocol AGImagePickerDelegate <NSObject>

- (void)imagePicker:(AGImagePicker *)imagePicker didFinish:(BOOL)finished image:(UIImage *)image;

@end

@interface AGImagePicker : NSObject

@property(nonatomic, weak) id<AGImagePickerDelegate> delegate;
- (void) pick:(UIViewController *)viewController type:(AGImagePickerType)type;

@end
