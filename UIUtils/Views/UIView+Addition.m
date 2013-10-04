//
//  UIView+Addition.m
//  Airogami
//
//  Created by Tianhu Yang on 10/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)

//for UIScrollView
/*- (void) setTopRoundedCornerWithRadius:(float) radius
{
    CGRect frame = self.bounds;
    CGMutablePathRef path = CGPathCreateMutable();
    frame.origin.y = -frame.size.height;
    CGPathAddRect(path, &CGAffineTransformIdentity, frame);
    frame.origin.y = 0;
    frame.size.height *= 2.0f;
    // Create the path (with only the top corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CGPathAddPath(path, &CGAffineTransformIdentity, maskPath.CGPath);
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = frame;
    maskLayer.path = path;
    
    CGPathRelease(path);
    
    // Set the newly created shape layer as the mask for the  view's layer
    self.layer.mask = maskLayer;
}*/

- (void) setTopRoundedCornerWithRadius:(float) radius
{
    CGRect frame = self.bounds;
    // Create the path (with only the top corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(radius, radius)];
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = frame;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the  view's layer
    self.layer.mask = maskLayer;
}

@end
