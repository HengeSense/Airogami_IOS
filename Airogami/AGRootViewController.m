//
//  AGRoorViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGRootViewController.h"

static NSString *stories[] = {@"AGWriteStoryboard", @"AGCollectStoryboard",@"AGChatStoryboard", @"AGSettingStoryboard"};

static UIStoryboard *commonStoryBoard;

enum{
    AGRootToSign,
    AGRootToMain
};


@interface AGRootViewController ()
{
    int rootNavigateTo;
    UIViewController *viewController;
    NSArray *viewControllers;
}

@end

@implementation AGRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return  self;
}

- (void) initialize
{
    rootNavigateTo = AGRootToMain;
    switch (rootNavigateTo) {
        case AGRootToSign:
            [self prepareForSign];
            break;
        case AGRootToMain:
            [self prepareForMain];
            break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    switch (rootNavigateTo) {
        case AGRootToSign:
            [self navigateToSign];
            break;
        case AGRootToMain:
            [self navigateToMain];
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController*)segue.destinationViewController;
        tabBarController.viewControllers = viewControllers;
        viewControllers = nil;
    }
}

- (void) prepareForSign
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    UIStoryboard *storyBaord = [UIStoryboard storyboardWithName:@"AGSignStoryboard" bundle:nil];
    viewController = [storyBaord instantiateInitialViewController];
}

- (void) prepareForMain
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 3; ++i) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:stories[i] bundle:nil];
        UIViewController *vc = [storyBoard instantiateInitialViewController];
        [array addObject:vc];
    }
    viewControllers = array;
}

- (void) navigateToSign
{
    [self presentViewController:viewController animated:NO completion:nil];
    viewController = nil;
}

- (void) navigateToMain
{
    [self performSegueWithIdentifier:@"ToMain" sender:self];
}

+ (AGSettingProfileMasterViewController*) settingViewController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:stories[3] bundle:nil];
    AGSettingProfileMasterViewController  *setting = [storyBoard instantiateViewControllerWithIdentifier:@"AGSettingProfileMasterViewController"];
    return setting;
}

+ (UIStoryboard*) commonStoryBoard
{
    if (commonStoryBoard == nil) {
        commonStoryBoard = [UIStoryboard storyboardWithName:@"AGCommonStoryboard" bundle:nil];
    }
    return commonStoryBoard;
}

+ (AGLocationViewController*) locationViewController
{
   return [[AGRootViewController commonStoryBoard] instantiateViewControllerWithIdentifier:@"AGLocationViewController"];
}

@end
