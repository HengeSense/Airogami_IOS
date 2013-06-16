//
//  ImageCropper.h
//  Created by http://github.com/iosdeveloper
//

#import <UIKit/UIKit.h>

@protocol YTImageCropperDelegate;

@interface YTImageCropper : UIViewController <UIScrollViewDelegate> {
	UIImage *image;
}


@property (nonatomic, assign) id <YTImageCropperDelegate> delegate;

- (id)initWithImage:(UIImage *)image;

@end

@protocol YTImageCropperDelegate <NSObject>
- (void)imageCropper:(YTImageCropper *)cropper didFinishCroppingWithImage:(UIImage *)image;
- (void)imageCropperDidCancel:(YTImageCropper *)cropper;
@end