//
//  AGCollectPlanePulldownHeaderView.m
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGRefreshPulldownHeader.h"
#import "AGNotificationCenter.h"
#import <QuartzCore/QuartzCore.h>

#define FLIP_ANIMATION_DURATION 0.18f

typedef enum {
    AGCollectPulldownHeaderNormal = 0,
    AGCollectPulldownHeaderPulling,
    AGCollectPulldownHeaderRefreshing
    
}AGCollectPulldownHeaderState;

@interface AGRefreshPulldownHeader()
{
    AGCollectPulldownHeaderState state;
    UIActivityIndicatorView *indicator;
}

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation AGRefreshPulldownHeader

@synthesize delegate;
@synthesize scrollView;

- (id) init
{
    if (self = [super init]) {
        state = AGCollectPulldownHeaderNormal;
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return self;
}

-(void)initialize
{
    [self.pulldownView addSubview:indicator];
    indicator.center = self.arrowImageView.center;
}


- (void) setState:(AGCollectPulldownHeaderState) aState
{
    switch (state = aState) {
        case AGCollectPulldownHeaderNormal:
            self.titleLabel.text = NSLocalizedString(@"ui.refresh.pull", @"Pull down to refresh ...");
            [UIView beginAnimations:@"Animation" context:nil];
            self.arrowImageView.transform = CGAffineTransformIdentity;
            [UIView commitAnimations];
            break;
        case AGCollectPulldownHeaderPulling:
            self.titleLabel.text = NSLocalizedString(@"ui.refresh.release", @"Release to find more ...");
            [UIView beginAnimations:@"Animation" context:nil];
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            [UIView commitAnimations];
            break;
        case AGCollectPulldownHeaderRefreshing:
            self.arrowImageView.hidden = YES;
            [indicator startAnimating];
            UIEdgeInsets contentInset = scrollView.contentInset ;
            contentInset.top = 48.0f;
            [UIView beginAnimations:@"AGCollectPulldownHeaderRefreshing" context:NULL];
            scrollView.contentInset = contentInset;
            [UIView commitAnimations];
            self.titleLabel.text = NSLocalizedString(@"ui.refresh.refreshing", @"Refreshing ...");
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView{
	
    if(scrollView.isDragging && state != AGCollectPulldownHeaderRefreshing)
    {
        if (scrollView.contentOffset.y < -60.0f) {
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

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate{
	
	if (state == AGCollectPulldownHeaderPulling) {
        [self setState:AGCollectPulldownHeaderRefreshing];
        [delegate refresh];
        //[self performSelector:@selector(stop) withObject:nil afterDelay:3.0f];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshed:) name:AGNotificationRefreshed object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationRefresh object:self userInfo:nil];
    }
	
}

-(void)refreshed:(NSNotification*)notification
{
    [self stop];
}

-(void) stop
{
    self.arrowImageView.hidden = NO;
    [indicator stopAnimating];
    //
    UIEdgeInsets contentInset = scrollView.contentInset ;
    contentInset.top = 0.0f;
    [UIView beginAnimations:@"AGCollectPulldownHeaderRefreshing" context:NULL];
    scrollView.contentInset = contentInset;
    [UIView commitAnimations];
    
    state = AGCollectPulldownHeaderNormal;
    self.titleLabel.text = NSLocalizedString(@"ui.refresh.pull", @"Pull down to refresh ...");
    
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (id) header
{
    AGRefreshPulldownHeader * header =[[AGRefreshPulldownHeader alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"AGCollectPlanePulldownView" owner:header options:nil];
    [header initialize];
    return header;
}

@end
