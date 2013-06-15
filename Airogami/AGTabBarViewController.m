//
//  AGTabBarViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGTabBarViewController.h"
#import "AGUtils.h"

#define kAGTabBarButtonTag_Compose 0
#define kAGTabBarButtonTag_Pickup 1
#define kAGTabBarButtonTag_Plane 2
#define kAGTabBarCount 3
#define kAGTabBarTitlePrefix @"main.tabbar.title"

static NSString * AGTabBarItemSelectedImages[] = {@"main_tabbar_item_compose.png", @"main_tabbar_item_pickup.png",@"main_tabbar_item_plane.png"};
static NSString * AGTabBarItemUnselectedImages[] = {@"main_tabbar_item_compose_select.png", @"main_tabbar_item_pickup_select.png",@"main_tabbar_item_plane_select.png"};

@interface AGTabBarViewController ()
{
    UIButton *tabBarButtons[kAGTabBarCount];
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
    UITabBarItem *tabBarItems[kAGTabBarCount];
    for (int i = 0; i < kAGTabBarCount; ++i) {
        tabBarItems[i] = [tabBar.items objectAtIndex:i];
        [tabBarItems[i] setFinishedSelectedImage:[UIImage imageNamed:AGTabBarItemSelectedImages[i]] withFinishedUnselectedImage:[UIImage imageNamed:AGTabBarItemUnselectedImages[i]]];
    }
    
    // Change the tab bar background
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_selected.png"]];
    
    // Change the title color of tab bar items
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor whiteColor], UITextAttributeTextColor,
                                                       nil] forState:UIControlStateNormal];
    UIColor *titleHighlightedColor = [UIColor colorWithRed:153/255.0 green:192/255.0 blue:48/255.0 alpha:1.0];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       titleHighlightedColor, UITextAttributeTextColor,
                                                    nil] forState:UIControlStateHighlighted];
}

- (void)buttonClicked:(UIButton*)sender
{
    [self selectTab:sender.tag];
}

- (void)selectTab:(int)index
{
    if (index >= kAGTabBarCount || index < 0) {
        return;
    }
    switch(index)
    {
        case kAGTabBarButtonTag_Compose:
            [tabBarButtons[0] setSelected:true];
            [tabBarButtons[1] setSelected:false];
            [tabBarButtons[2] setSelected:false];
            break;
        case kAGTabBarButtonTag_Pickup:
            [tabBarButtons[0] setSelected:false];
            [tabBarButtons[1] setSelected:true];
            [tabBarButtons[2] setSelected:false];
            break;
        case kAGTabBarButtonTag_Plane:
            [tabBarButtons[0] setSelected:false];
            [tabBarButtons[1] setSelected:false];
            [tabBarButtons[2] setSelected:true];
            break;
    }
    self.selectedIndex = index;
}

@end
