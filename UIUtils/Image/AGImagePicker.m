//
//  AGImagePicker.m
//  Airogami
//
//  Created by Tianhu Yang on 10/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGImagePicker.h"

@interface AGImagePicker()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation AGImagePicker

@synthesize delegate;

- (void) pick:(UIViewController *)viewController type:(AGImagePickerType)type
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    switch (type) {
        case AGImagePickerType_Camera:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case AGImagePickerType_Library:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        default:
            break;
    }
    [viewController presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [delegate imagePicker:self didFinish:YES image:image];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    [delegate imagePicker:self didFinish:NO image:nil];
}

@end
