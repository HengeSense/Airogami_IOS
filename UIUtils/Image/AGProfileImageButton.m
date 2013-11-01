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

@interface AGProfileImageButton()

@property(nonatomic, strong) NSNumber *done;

@end

@implementation AGProfileImageButton

@synthesize mediumUrl;
@synthesize done;

- (void)initialize
{
    [super initialize];
    done = [NSNumber numberWithBool:YES];
    [self addTarget: self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void) buttonClicked
{
    if (done.boolValue) {
        done = [NSNumber numberWithBool:NO];
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        [window endEditing:YES];
        CGRect frame = [self.imageView convertRect:self.imageView.bounds toView:window];
        
        AGPhotoView *photoView = [[AGPhotoView alloc] initWithFrame:frame];
        
        [photoView preview:self.imageView.image medium:mediumUrl soure:self];
    }
    
}

- (void) setImageWithAccount:(AGAccount*)account
{
    NSURL *url = [account accountIconUrl:YES];
    [self setImageUrl:url placeImage:[AGUIDefines profileDefaultImage]];
    url = [account accountIconUrl:NO];
    self.mediumUrl = url;
}

@end
