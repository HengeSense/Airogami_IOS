//
//  UIImage+Addition.m
//  Airogami
//
//  Created by Tianhu Yang on 8/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "UIImage+Addition.h"

static int MaxMediumWidth = 512;
static int MaxSmallWidth = 135;

@implementation UIImage (Addition)

- (UIImage*)imageWithSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//return mediumImage, smallImage

- (NSArray*)scaledImages
{
    CGSize size = self.size, smallSize;
    BOOL changed = NO, smallChanged = NO;
    if (size.width > size.height) {
        if (size.width > MaxMediumWidth) {
            size.height = size.height / size.width * MaxMediumWidth;
            size.width = MaxMediumWidth;
            changed = YES;
        }
        //
        smallSize = size;
        if (smallSize.width > MaxSmallWidth) {
            smallSize.height = smallSize.height / smallSize.width * MaxSmallWidth;
            smallSize.width = MaxSmallWidth;
            smallChanged = YES;
        }
    }
    else{
        if (size.height > MaxMediumWidth) {
            size.width = size.width / size.height * MaxMediumWidth;
            size.height = MaxMediumWidth;
            changed = YES;
        }
        //
        smallSize = size;
        if (smallSize.height > MaxSmallWidth) {
            smallSize.width = smallSize.width / smallSize.height * MaxSmallWidth;
            smallSize.height = MaxSmallWidth;
            smallChanged = YES;
        }
    }
    UIImage *mediumImage = changed ? [self imageWithSize:size] : self;
    UIImage *smallImage = smallChanged ? [mediumImage imageWithSize:smallSize] : mediumImage;
    //
    return [NSArray arrayWithObjects:mediumImage, smallImage, nil];
}

@end
