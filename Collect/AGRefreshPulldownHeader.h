//
//  AGCollectPlanePulldownHeaderView.h
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AGRefreshPulldownHeaderDelegate <NSObject>

- (void) refresh;

@end

@interface AGRefreshPulldownHeader : NSObject

@property (strong, nonatomic) IBOutlet UIView *pulldownView;
@property(nonatomic, weak) id<AGRefreshPulldownHeaderDelegate> delegate;
@property(nonatomic, weak) UIScrollView *scrollView;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void) stop;

+ (id) header;
@end
