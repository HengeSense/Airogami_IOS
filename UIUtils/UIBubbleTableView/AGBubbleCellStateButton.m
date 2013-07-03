//
//  AGBubbleCellStateButton.m
//  Airogami
//
//  Created by Tianhu Yang on 7/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGBubbleCellStateButton.h"

#define kStateButtonImageWidth 30

static NSString *StateButtonImages[] = { @"bubbleCellStateSendFailed.png", @"bubbleCellStateSentLiked.png", @"bubbleCellStateReceivedUnliked.png" , @"bubbleCellStateReceivedLiked.png"};
static NSString *StateButtonSelectedImages[] = { @"", @"", @"" , @"bubbleCellStateReceivedLiked_large.png"};

@interface AGBubbleCellStateButton()
{
    UIActivityIndicatorView *indicator;
}

@end

@implementation AGBubbleCellStateButton

@synthesize cellState;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self initialize];
    }
    return self;
}

- (id) init{
    
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

-(void) initialize
{
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:indicator];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    indicator.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
}

- (void) likeReceived
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:StateButtonSelectedImages[3]]];
    CGRect frame = self.bounds;
    frame.origin = CGPointMake(frame.size.width / 2 - kStateButtonImageWidth / 2.0f, frame.size.height / 2 - kStateButtonImageWidth / 2.0f);
    frame.size = CGSizeMake(kStateButtonImageWidth, kStateButtonImageWidth);
    imageView.frame = frame;
    [self addSubview:imageView];
    [UIView beginAnimations:@"LikeAnimations" context:(__bridge void *)(imageView)];
    imageView.transform = CGAffineTransformMakeScale(2, 2);
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(magnifyAnimationDidStop:finished:context:)];
    [UIView commitAnimations];
    
    self.selected = YES;
    
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
    self.cellState = BubbleCellStateReceivedLiked;
}

- (void) setCellState:(NSBubbleCellState)state
{
    cellState = state;
    if (state != BubbleCellStateSent) {
        self.userInteractionEnabled = (state == BubbleCellStateSendFailed || state == BubbleCellStateReceivedUnliked );
        if (state == BubbleCellStateSending) {
            [self setImage:nil forState:UIControlStateNormal];
            [indicator startAnimating];
        }
        else{
            [self setImage:[UIImage imageNamed:StateButtonImages[state]] forState:UIControlStateNormal];
            [indicator stopAnimating];
        }
        self.hidden = NO;
    }
    else{
        self.hidden = YES;
    }
    
}

@end
