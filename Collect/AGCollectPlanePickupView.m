//
//  AGCollectPlanePickupView.m
//  Airogami
//
//  Created by Tianhu Yang on 7/3/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCollectPlanePickupView.h"
#import "AGCollectPlaneNumberView.h"
#import "CALayer+Pause.h"

#define kAGCollectPlanePickupCancel @"collect_pickup_cancel_button.png"
#define kAGCollectPlanePickupRadarDuration 2.0f

@interface AGCollectPlanePickupView()
{
    AGCollectPlaneNumberView *numberView;
    UIImageView * imageView;
    CABasicAnimation *rotateAnimation;
    CALayer *rotatedLayer;
}

@end

@implementation AGCollectPlanePickupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    CGRect frame = [UIScreen mainScreen].bounds;
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8f];
        numberView = [AGCollectPlaneNumberView numberView:self];
        //cancel button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:kAGCollectPlanePickupCancel];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 20, image.size.width + 30, image.size.height + 30);
        [self addSubview:button];
        //image view
        int count = 6;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < count; ++i) {
            NSString *path = [NSString stringWithFormat:@"%@%d.png", @"radar_", i + 1];
            image = [UIImage imageNamed:path];
            [array addObject:image];
        }

        frame.origin = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        frame.size = image.size;
        frame.origin.x -= frame.size.width / 2;
        frame.origin.y -= frame.size.height / 2;
        imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = image;
        imageView.animationImages = array;
        imageView.animationRepeatCount = 1;
        imageView.animationDuration = kAGCollectPlanePickupRadarDuration;
        [self addSubview:imageView];
    
        //rotate layer
        image = [UIImage imageNamed:@"radar_arm.png"];
        rotatedLayer = [CALayer layer];
        rotatedLayer.contents = (__bridge id)(image.CGImage);
        [imageView.layer addSublayer:rotatedLayer];
        rotatedLayer.frame = imageView.bounds;
        rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotateAnimation.repeatCount = FLT_MAX;
        rotateAnimation.duration = kAGCollectPlanePickupRadarDuration;
        rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        rotateAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
        
    }
    return self;
}

- (void) cancelButtonTouched
{
    [self dismiss];
}

- (void) show
{
    numberView.hidden = YES;
    imageView.hidden = NO;
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    [rotatedLayer addAnimation:rotateAnimation forKey:@"transform.rotation"];
    [imageView startAnimating];
    self.alpha = 0.0f;
    [UIView beginAnimations:@"PickupViewAnimations" context:nil];
   [UIView setAnimationDuration:.3f];
   [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
   self.alpha = 1.0f;
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(easeInDidStop:finished:context:)];
   [UIView commitAnimations];
   [self performSelector:@selector(showNumber) withObject:self afterDelay:3.0f];
}


- (void)showNumber
{
    [self showNumber:5];
}


- (void) showNumber:(int)number
{
    numberView.numberLabel.text = [NSString stringWithFormat:@"%d", number];
    numberView.hidden = NO;
    numberView.alpha = 0.0f;
    [UIView beginAnimations:@"WaitImageViewAnimations" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    imageView.alpha = 0.0f;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    
    //numberLabel
    [UIView beginAnimations:@"NumberViewAnimations" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    numberView.alpha = 1.0f;
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

-(void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [rotatedLayer removeAllAnimations];
    [imageView stopAnimating];
    imageView.alpha = 1.0f;
    imageView.hidden = YES;
}

- (void) dismiss
{
    [rotatedLayer removeAllAnimations];
    [imageView stopAnimating];
    [UIView beginAnimations:@"WaitViewAnimations" context:nil];
    [UIView setAnimationDuration:.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.alpha = 0.0f;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(easeOutDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

-(void) easeOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self removeFromSuperview];
}

-(void) easeInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    
}

@end
