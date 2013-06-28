//
//  AGCollectPlanePulldownHeaderView.h
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AGCollectPlanePulldownHeaderDelegate <NSObject>

- (void) refresh;

@end

@interface AGCollectPlanePulldownHeader : NSObject

@property (strong, nonatomic) IBOutlet UIView *pulldownView;
@property(nonatomic, weak) id<AGCollectPlanePulldownHeaderDelegate> delegate;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

+ (id) header;
@end
