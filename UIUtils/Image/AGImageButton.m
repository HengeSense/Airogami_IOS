//
//  AGImageButton.m
//  Airogami
//
//  Created by Tianhu Yang on 7/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGImageButton.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AGImageButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    CALayer *layer = self.imageView.layer;
    layer.cornerRadius = 6.0f;
    //layer.borderWidth = 1.0f;
    // layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void) setImageUrl:(NSURL *)url placeImage:(UIImage *)planeImage
{
    UIButton *button = self;
    [button setImage:planeImage forState:UIControlStateNormal];
    [self.imageView setImageWithURL:url placeholderImage:planeImage options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
#ifdef IS_DEBUG
        if (error) {
            NSLog(@"AGImageButton.setImageUrl: %@", error);
        }
#endif
        if (error == nil && image != nil) {
            [button setImage:image forState:UIControlStateNormal];
        }
    }];
}

@end
