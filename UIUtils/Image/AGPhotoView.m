//
//  AGPhotoView.m
//  Airogami
//
//  Created by Tianhu Yang on 7/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPhotoView.h"

@interface AGPhotoView()

@property(nonatomic, assign) CGRect originalFrame;

@end

@implementation AGPhotoView

@synthesize originalFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        originalFrame = frame;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) preview
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    CGRect frame;
    CGSize size = window.bounds.size;
    frame.size = self.image.size;
    frame.origin.x = (size.width - frame.size.width) / 2;
    frame.origin.y = (size.height - frame.size.height) / 2;
    [UIView beginAnimations:@"ProfileImageButtonAnimations" context:nil];
    self.frame = frame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showDidStop:finished:context:)];
    [UIView commitAnimations];
}

-(void)showDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:window.bounds];
    scrollView.maximumZoomScale = 2.0f;
    scrollView.minimumZoomScale = 1.0f;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.contentSize = self.bounds.size;
    [window addSubview:scrollView];
    [scrollView addSubview:self];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIScrollView *scrollView = (UIScrollView *) self.superview;
    scrollView.zoomScale = 1.0f;
    [UIView beginAnimations:@"ProfileImageButtonAnimations" context:nil];
    self.frame = originalFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissDidStop:finished:context:)];
    [UIView commitAnimations];
}

-(void) dismissDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.superview removeFromSuperview];
    [self removeFromSuperview];
}

@end
