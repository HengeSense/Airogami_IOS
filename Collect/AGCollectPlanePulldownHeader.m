//
//  AGCollectPlanePulldownHeaderView.m
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCollectPlanePulldownHeader.h"
#import <QuartzCore/QuartzCore.h>

#define FLIP_ANIMATION_DURATION 0.18f

typedef enum {
    AGCollectPulldownHeaderNormal = 0,
    AGCollectPulldownHeaderPulling
    
}AGCollectPulldownHeaderState;

@interface AGCollectPlanePulldownHeader()
{
    AGCollectPulldownHeaderState state;
}

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation AGCollectPlanePulldownHeader

@synthesize delegate;

- (id) init
{
    if (self = [super init]) {
        state = AGCollectPulldownHeaderNormal;
    }
    return self;
}


- (void) setState:(AGCollectPulldownHeaderState) aState
{
    switch (state = aState) {
        case AGCollectPulldownHeaderNormal:
            self.titleLabel.text = NSLocalizedString(@"collect.refresh.pull", @"Pull down to find more ...");
            [UIView beginAnimations:@"Animation" context:nil];
            self.arrowImageView.transform = CGAffineTransformIdentity;
            [UIView commitAnimations];
            break;
        case AGCollectPulldownHeaderPulling:
            self.titleLabel.text = NSLocalizedString(@"collect.refresh.release", @"Release to find more ...");
            [UIView beginAnimations:@"Animation" context:nil];
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            [UIView commitAnimations];
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
    if(scrollView.isDragging)
    {
        if (scrollView.contentOffset.y < -45.0f) {
            if (state != AGCollectPulldownHeaderPulling) {
                [self setState:AGCollectPulldownHeaderPulling];
            }
        
        }
        else{
            if (state != AGCollectPulldownHeaderNormal) {
                [self setState:AGCollectPulldownHeaderNormal];
            }
        
        }
    }
	//[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (state == AGCollectPulldownHeaderPulling) {
        [self setState:AGCollectPulldownHeaderNormal];
        [delegate refresh];        
    }
	
}

+ (id) header
{
    AGCollectPlanePulldownHeader * header =[[AGCollectPlanePulldownHeader alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"AGCollectPlanePulldownView" owner:header options:nil];
    return header;
}

@end
