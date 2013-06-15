//
//  AGImagePickAndCrop.m
//  Airogami
//
//  Created by Tianhu Yang on 6/10/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGImagePickAndCrop.h"
#import "YTImageCropper.h"

@interface AGImagePickAndCrop() <UINavigationControllerDelegate, UIImagePickerControllerDelegate, YTImageCropperDelegate>

@end

@implementation AGImagePickAndCrop
@synthesize delegate;

- (void) pickAndCrop:(UIViewController *)viewController type:(int)type
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    switch (type) {
        case AGImagePickAndCropType_Camera:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case AGImagePickAndCropType_Library:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        default:
            break;
    }
    [viewController presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - YTImageCropperDelegate

- (void)imageCropper:(YTImageCropper *)cropper didFinishCroppingWithImage:(UIImage *)image {
	
	[cropper.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.delegate imagePickAndCrop:self didFinishingWithImage:image];
}

- (void)imageCropperDidCancel:(YTImageCropper *)cropper {
    //[cropper.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [cropper.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    YTImageCropper *imageCropper = [[YTImageCropper alloc] initWithImage:image];
    imageCropper.delegate = self;
    [picker pushViewController:imageCropper animated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    [self.delegate imageCropperDidCancel:self];
}
@end
