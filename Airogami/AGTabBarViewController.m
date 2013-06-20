//
//  AGTabBarViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGTabBarViewController.h"
#import "AGUtils.h"


static NSString * AGTabBarItemUnselectedImages[] = {@"main_tabbar_item_write.png", @"main_tabbar_item_collect.png", @"main_tabbar_item_chat.png", @"main_tabbar_item_setting.png"};
static NSString * AGTabBarItemSelectedImages[] = {@"main_tabbar_item_write_selected.png", @"main_tabbar_item_collect_selected.png",@"main_tabbar_item_chat_selected.png", @"main_tabbar_item_setting_selected.png"};

static NSString * AGTabBarBgrd = @"main_tabbar_bgrd.png";

@interface AGTabBarViewController ()
{
}

@end

@implementation AGTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self createUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createUI
{
    UITabBar *tabBar = self.tabBar;
    for (int i = 0; i < self.viewControllers.count; ++i) {
        UITabBarItem *tabBarItem = [tabBar.items objectAtIndex:i];
        YTTabBarItem *tabBarItemView = [tabBarView.tabBarItems objectAtIndex:i];
        [tabBarItemView setSelectedImage:[UIImage imageNamed:AGTabBarItemSelectedImages[i]] unseletedImage:[UIImage imageNamed:AGTabBarItemUnselectedImages[i]]];
        tabBarItemView.text = tabBarItem.title;
    }
    tabBarView.image = [UIImage imageNamed:AGTabBarBgrd];
}

@end
