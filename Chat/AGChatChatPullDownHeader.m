//
//  AGChatChatPullDownHeader.m
//  Airogami
//
//  Created by Tianhu Yang on 8/20/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatChatPullDownHeader.h"

typedef enum {
    AGChatChatPulldownHeaderNormal = 0,
    AGChatChatPulldownHeaderPulling
    
}AGChatChatPulldownHeaderState;

@interface AGChatChatPullDownHeader()
{
    AGChatChatPulldownHeaderState state;
    UIActivityIndicatorView *indicator;
}

@end

@implementation AGChatChatPullDownHeader

@synthesize delegate;
@synthesize pullDownView;

- (id) init
{
    if (self = [super init]) {
        state = AGChatChatPulldownHeaderNormal;
    }
    return self;
}

- (void)initialize
{
    CGRect frame = CGRectMake(0, 0, 30, 30);
    CGRect bounds = self.pullDownView.bounds;
    frame.origin.x = (bounds.size.width - frame.size.width) / 2;
    frame.origin.y = (bounds.size.height - frame.size.height) / 2;
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [pullDownView addSubview:indicator];
}

- (void) setState:(AGChatChatPulldownHeaderState) aState
{
    switch (state = aState) {
        case AGChatChatPulldownHeaderNormal:
            [indicator stopAnimating];
            break;
        case AGChatChatPulldownHeaderPulling:
            [indicator startAnimating];
            break;
            
        default:
            break;
    }
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
    if(scrollView.isDragging)
    {
        if (scrollView.contentOffset.y < -60.0f) {
            [delegate refresh];
        }
        if (scrollView.contentOffset.y < -40.0f) {
            if (state != AGChatChatPulldownHeaderPulling) {
                [self setState:AGChatChatPulldownHeaderPulling];
                
            }
        }
        else{
            if (state != AGChatChatPulldownHeaderNormal) {
                [self setState:AGChatChatPulldownHeaderNormal];
            }
            
        }
    }
	//[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void) beginRefresh
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (state == AGChatChatPulldownHeaderPulling) {
        [self setState:AGChatChatPulldownHeaderNormal];
        //[delegate refresh];
    }
	
}

+ (id) header
{
    AGChatChatPullDownHeader * header =[[AGChatChatPullDownHeader alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"AGChatChatPullDownView" owner:header options:nil];
    [header initialize];
    return header;
}

@end
