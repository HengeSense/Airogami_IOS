//
//  YTImageCropperMaskView.m
//  ImageCropper
//
//  Created by Tianhu Yang on 6/10/13.
//
//

#import "YTImageCropperMaskView.h"

@implementation YTImageCropperMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    rect.origin.y = (rect.size.height - rect.size.width) / 2;
    rect.size.height = rect.size.width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGContextSetLineWidth(context, 1.0);
    CGFloat components[] = {1.0, 1.0, 1.0, 0.5};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
    CGColorRelease(color);
    
    
    CGFloat fillComponents[] = {0.0, 0.0, 0.0, 0.5};
    color = CGColorCreate(colorspace, fillComponents);
    CGContextSetFillColorWithColor(context, color);
    CGContextStrokePath(context);
    rect.size.height = rect.origin.y;
    rect.origin.y = 0;
    CGContextAddRect(context, rect);
    rect.origin.y += rect.size.width + rect.size.height;
    CGContextAddRect(context, rect);
    CGContextFillPath(context);
    CGColorRelease(color);
    
    
    CGColorSpaceRelease(colorspace);
   
}


@end
