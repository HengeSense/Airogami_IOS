//
//  AGProfileImageButton.m
//  Airogami
//
//  Created by Tianhu Yang on 6/10/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGProfileImageButton.h"
#import "AGPhotoView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AGProfileImageButton


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
    photoView.image = self.imageView.image;
    [photoView preview];
    
}

@end
