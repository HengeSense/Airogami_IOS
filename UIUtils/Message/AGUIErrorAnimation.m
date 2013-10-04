//
//  AGUIErrorAnimation.m
//  Airogami
//
//  Created by Tianhu Yang on 6/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGUIErrorAnimation.h"

#define AnimationID @"show_error"
#define kAGErrorBar @"error_bar.png"

static AGUIErrorAnimation *uiErrorAnimation;

@interface AGUIErrorAnimation()
{
    UIView *view;
}
@property(nonatomic,assign) BOOL active;
@end

@implementation AGUIErrorAnimation

@synthesize active;

+ (AGUIErrorAnimation*) uiErrorAnimation
{
    if (uiErrorAnimation == nil) {
        uiErrorAnimation = [[AGUIErrorAnimation alloc] init];
    }
    return uiErrorAnimation;
}

+ (void) startWithTitle:(NSString*)title view:(UIView*)superview
{
    if ([AGUIErrorAnimation uiErrorAnimation].active) {
        return;
    }
    superview = superview;
    //
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kAGErrorBar]];
    CGRect rect = imageView.frame;
    rect.origin.y = - rect.size.height;
    imageView.frame = rect;
    rect.origin.y = 0;
    rect.origin.x = 50;
    rect.size.width = rect.size.width - rect.origin.x - 20;
    rect.size.height = 55;
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.font = [UIFont systemFontOfSize:14.0f];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.textColor = [UIColor colorWithRed:242 / 255.0f green:128 / 255.0f blue:122 / 255.0f alpha:1.0f];
    [imageView addSubview:label];
    [superview addSubview:imageView];
    [[AGUIErrorAnimation uiErrorAnimation] startWithView:imageView];
}

- (void) startWithView:(UIView *)aView
{
    view = aView;
    active = YES;
    [self moveDown:AnimationID finished:[NSNumber numberWithBool:YES] context:nil];
}

- (void)moveDown:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    CGRect rect = view.frame;
    rect.origin.y = 0;
    [UIView animateWithDuration:.2
                          delay:0.0
                        options:(UIViewAnimationCurveLinear|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [UIView setAnimationDelegate:self];
                         [UIView setAnimationDidStopSelector:@selector(moveUp:finished:context:)];
                         view.frame = rect;
                     }
                     completion:^(BOOL finished){
                     }];
    
}

- (void)moveUp:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    CGRect rect = view.frame;
    rect.origin.y = -rect.size.height;
    [UIView animateWithDuration:.2
                          delay:2.0
                        options:(UIViewAnimationCurveLinear|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [UIView setAnimationDelegate:self];
                         [UIView setAnimationDidStopSelector:@selector(end:finished:context:)];
                         view.frame = rect;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

- (void)end:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [view removeFromSuperview];
    view = nil;
    active = NO;
}

@end
