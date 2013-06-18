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
    tabBarView = [[YTTabBar alloc] initWithFrame:self.tabBar.frame count:self.viewControllers.count];
    tabBarView.delegate = self;
    self.tabBar.hidden = YES;
    [self.view addSubview:tabBarView];
}

-(void) onSelect:(int)index
{
    //self.selectedIndex = index;
    self.selectedViewController = [self.viewControllers objectAtIndex:index];
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex
{
    [tabBarView selectTab:selectedIndex];
}

@end
