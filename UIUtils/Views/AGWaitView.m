//
//  AGWaitView.m
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGWaitView.h"

@implementation AGWaitView

@synthesize imageView;

-(id) initWithName:(NSString *)name count:(int)count
{

    CGRect frame = [UIScreen mainScreen].bounds;
    self =  [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8f];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        UIImage *image = nil;
        for (int i = 0; i < count; ++i) {
            NSString *path = [NSString stringWithFormat:@"%@%d.png", name, i];
            image = [UIImage imageNamed:path];
            [array addObject:image];
        }
        frame.origin = self.center;
        frame.size = image.size;
        frame.origin.x -= frame.size.width / 2;
        frame.origin.y -= frame.size.height / 2;
        UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
        imageView = iv;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.animationImages = array;
        imageView.animationRepeatCount = 0;
        imageView.animationDuration = 5.0f;
        [self addSubview:imageView];
    }
    
    return self;
}

- (void) show
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    [imageView startAnimating];
    self.alpha = 0.0f;
    [UIView beginAnimations:@"WaitViewAnimations" context:nil];
    [UIView setAnimationDuration:.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.alpha = 1.0f;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(easeINDidStop:finished:context:)];
    [UIView commitAnimations];
}

- (void) dismiss
{
    [self.imageView stopAnimating];
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
    self.alpha = 1.0f;
    [self removeFromSuperview];
}

-(void) easeInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    
}

@end
