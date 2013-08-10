//
//  AGProfileImageButton.m
//  Airogami
//
//  Created by Tianhu Yang on 6/10/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGProfileImageButton.h"
#import "AGPhotoView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <QuartzCore/QuartzCore.h>

@implementation AGProfileImageButton

@synthesize mediumUrl;

- (void)initialize
{
    [super initialize];
    [self addTarget: self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void) buttonClicked
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window endEditing:YES];
    CGRect frame = [self.imageView convertRect:self.imageView.bounds toView:window];

    AGPhotoView *photoView = [[AGPhotoView alloc] initWithFrame:frame];
    [photoView setImageWithURL:mediumUrl placeholderImage:self.imageView.image options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
    }];
    [photoView preview];
    
}

@end
