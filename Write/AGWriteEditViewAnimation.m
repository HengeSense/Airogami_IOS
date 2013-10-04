//
//  AGWriteEditViewAnimation.m
//  Airogami
//
//  Created by Tianhu Yang on 6/24/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGWriteEditViewAnimation.h"

static int padding = 47;

@interface AGWriteEditViewAnimation()
{
    CGPoint position;
    BOOL started;
}
@property(nonatomic, weak) UIView *sexContainer;

@end
@implementation AGWriteEditViewAnimation

@synthesize sexContainer;


- (id) initWithView:(UIView*) view
{
    if (self = [super init]) {
        self.sexContainer = view;
    }
    
    return self;
}

- (void) toggle:(CGPoint)point
{
    if (started) {
        [self fold:point];
    }
    else{
        [self expand:point];
    }
}

- (void) expand:(CGPoint)aPoint
{
    if (started) {
        return;
    }
    started = YES;
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self.sexContainer];
    for (UIButton *button in self.sexContainer.subviews) {
        button.center = aPoint;
        button.alpha = 0.f;
    }
    [UIView animateWithDuration:.2
                          delay:0.0
                        options:(UIViewAnimationCurveLinear|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         CGPoint point = aPoint;
                         for (UIButton *button in self.sexContainer.subviews) {
                             button.transform = CGAffineTransformMakeRotation(M_PI);
                             button.alpha = .3f;
                         }
                         //left
                         UIView *button = [self.sexContainer  viewWithTag:2];
                         point.x -= padding;
                         point.y -= 66;
                         button.center = point;
                         //middle
                         button = [self.sexContainer  viewWithTag:1];
                         point.x += padding;
                         button.center = point;
                         //right
                         button = [self.sexContainer  viewWithTag:3];
                         point.x += padding;
                         button.center = point;
                         
                         
                         [UIView setAnimationDelegate:self];
                         [UIView setAnimationDidStopSelector:@selector(expandRotate:finished:context:)];
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void) expandRotate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    [UIView animateWithDuration:.2
                          delay:0.0
                        options:(UIViewAnimationCurveLinear|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         for (UIButton *button in sexContainer.subviews) {
                             button.transform = CGAffineTransformMakeRotation( 2 * M_PI);
                             button.alpha = 1.0f;
                         }
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

- (void) fold:(CGPoint)aPoint
{
    if (started == NO) {
        return;
    }
    started = NO;
    position = aPoint;
    [UIView animateWithDuration:.2
                          delay:0.0
                        options:(UIViewAnimationCurveLinear|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         for (UIButton *button in sexContainer.subviews) {
                             button.transform = CGAffineTransformMakeRotation(M_PI);
                             button.alpha = .3f;
                         }
                                                  
                         [UIView setAnimationDelegate:self];
                         [UIView setAnimationDidStopSelector:@selector(foldTranslate:finished:context:)];
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];

}

- (void) foldTranslate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [UIView animateWithDuration:.2
                          delay:0.0
                        options:(UIViewAnimationCurveLinear|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         for (UIButton *button in sexContainer.subviews) {
                             button.transform = CGAffineTransformMakeRotation(2 * M_PI);
                             button.alpha = 0.f;
                             button.center = position;
                         }
                         
                     }
                     completion:^(BOOL finished){
                         [self.sexContainer removeFromSuperview];
                     }];

    

}

@end
