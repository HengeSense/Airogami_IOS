//
//  AGProfileImageButton.m
//  Airogami
//
//  Created by Tianhu Yang on 6/10/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGProfileImageButton.h"
#import "AGPhotoView.h"
#import "AGManagerUtils.h"
#import <QuartzCore/QuartzCore.h>
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
    
    [photoView preview:self.imageView.image url:mediumUrl];
    
}

- (void) setImageWithAccountId:(NSNumber *)accountId
{
    AGDataManger *dataManager = [AGManagerUtils managerUtils].dataManager;
    NSURL *url = [dataManager accountIconUrl:accountId small:YES];
    [self setImageUrl:url placeImage:[AGUIDefines profileDefaultImage]];
    url = [dataManager accountIconUrl:accountId small:NO];
    self.mediumUrl = url;
}

@end
