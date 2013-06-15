//
//  AGImagePickAndCrop.h
//  Airogami
//
//  Created by Tianhu Yang on 6/10/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

enum AGImagePickAndCropType{
    AGImagePickAndCropType_Library,
    AGImagePickAndCropType_Camera
};

@protocol AGImagePickAndCropDelegate;

@interface AGImagePickAndCrop : NSObject
{
}

@property(nonatomic, assign) id<AGImagePickAndCropDelegate> delegate;

- (void) pickAndCrop:(UIViewController*) viewController type:(int)type;

@end


@protocol AGImagePickAndCropDelegate <NSObject>
- (void)imagePickAndCrop:(AGImagePickAndCrop *)pickAndCrop didFinishingWithImage:(UIImage *)image;
- (void)imageCropperDidCancel:(AGImagePickAndCrop *)pickAndCrop;
@end