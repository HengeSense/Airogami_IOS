//
//  SCNProfileImage.m
//  Scoutin
//
//  Created by Tianhu Yang on 5/7/13.
//  Copyright (c) 2013 Tianhu Yang. All rights reserved.
//

#import "AGProfileImage.h"
#import "AGManagerUtils.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AGProfileImage
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if(self){
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    CALayer *layer = self.layer;
    layer.cornerRadius = 3.0f;
    self.clipsToBounds = YES;
}

- (void) setImageWithAccountId:(NSNumber*)accountId
{
    AGDataManger *dataManager = [AGManagerUtils managerUtils].dataManager;
    NSURL *url = [dataManager accountIconUrl:accountId small:YES];
    [self setImageWithURL:url placeholderImage:[AGUIDefines profileDefaultImage] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
#ifdef IS_DEBUG
        if (error) {
            NSLog(@"AGProfileImage.setImageWithAccountId: %@", error);
        }
#endif
    }];
}

@end
