//
//  ALTabBarController.m
//  ALCommon
//
//  Created by Andrew Little on 10-08-17.
//  Copyright (c) 2010 Little Apps - www.myroles.ca. All rights reserved.
//

#import "YTTabBarController.h"


@implementation YTTabBarController


- (void) viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = self.tabBar.frame;
    frame.origin.y = 0;
    tabBarView = [[YTTabBar alloc] initWithFrame:frame count:self.viewControllers.count selected:self.selectedIndex];
    tabBarView.delegate = self;
    [self.tabBar addSubview:tabBarView];
}

-(void) onSelect:(int)index
{
    self.selectedIndex = index;
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex
{
    super.selectedIndex = selectedIndex;
    [tabBarView selectTab:selectedIndex];
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

@end
