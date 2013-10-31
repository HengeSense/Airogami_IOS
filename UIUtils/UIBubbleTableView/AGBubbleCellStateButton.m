//
//  AGBubbleCellStateButton.m
//  Airogami
//
//  Created by Tianhu Yang on 7/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGBubbleCellStateButton.h"

#define kStateButtonImageWidth 30

static NSString *StateButtonImages[] = { @"chat_chat_send_failed.png", @"chat_chat_unread.png", @"chat_chat_read.png", @"bubbleCellStateReceivedUnliked.png" , @"bubbleCellStateReceivedLiked.png"};
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
    self.userInteractionEnabled = NO;
}

-(void) likeReceived
{
    
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    indicator.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
}


- (void) setCellState:(AGSendStateEnum)state
{
    assert(state >= AGSendStateNone && state <= AGSendStateRead);
    cellState = state;
    if (state != AGSendStateNone) {
        self.userInteractionEnabled = (state == AGSendStateFailed);
        if (state == AGSendStateSending) {
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
