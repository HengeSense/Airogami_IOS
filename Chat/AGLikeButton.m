//
//  AGLikeButton.m
//  Airogami
//
//  Created by Tianhu Yang on 10/22/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGLikeButton.h"

#define kButtonImageWidth 30

static NSString *UnlikedImage = @"bubbleCellStateReceivedUnliked.png";
static NSString *LikedImage = @"bubbleCellStateReceivedLiked.png";

@implementation AGLikeButton

@synthesize liked;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    self.liked = NO;
}

-(void)setLiked:(BOOL)liked_
{
    liked = liked_;
    NSString *name = liked ? LikedImage : UnlikedImage;
    self.userInteractionEnabled = !liked;
    [self setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
}

- (void) likeAnimate
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:LikedImage]];
    CGRect frame = self.bounds;
    frame.origin = CGPointMake(frame.size.width / 2 - kButtonImageWidth / 2.0f, frame.size.height / 2 - kButtonImageWidth / 2.0f);
    frame.size = CGSizeMake(kButtonImageWidth, kButtonImageWidth);
    imageView.frame = frame;
    [self addSubview:imageView];
    [UIView beginAnimations:@"LikeAnimations" context:(__bridge void *)(imageView)];
    imageView.transform = CGAffineTransformMakeScale(2, 2);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(magnifyAnimationDidStop:finished:context:)];
    [UIView commitAnimations];
    //
    self.liked = YES;
    
}

- (void)magnifyAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIImageView *imageView = (__bridge UIImageView *)(context);
    [UIView beginAnimations:@"LikeAnimations" context:(__bridge void *)(imageView)];
    imageView.transform = CGAffineTransformIdentity;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(minifyAnimationDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

- (void)minifyAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIImageView *imageView = (__bridge UIImageView *)(context);
    [imageView removeFromSuperview];
}

@end
