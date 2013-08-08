//
//  AGAppDelegate.m
//  Airogami
//
//  Created by Tianhu Yang on 6/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAppDelegate.h"
#import "AGUIUtils.h"
#import "AGUtils.h"
#import "AGManagerUtils.h"

static AGAppDelegate *AppDelegate;

@interface AGAppDelegate()
{
}
@end

@implementation AGAppDelegate

@synthesize coreDataController;

+(AGAppDelegate*) appDelegate
{
    return AppDelegate;
}

-(id)init
{
    if (self = [super init]) {
        AppDelegate = self;
        coreDataController = [[AGCoreDataController alloc] init];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [AGUIUtils initialize];
    [AGUtils initialize];
    
    //main background 
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[AGUIDefines mainBackgroundImage]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.frame = [UIScreen mainScreen].bounds;
    [self.window addSubview:imageView];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSError *error;
    AGCoreData *coreData = coreDataController.coreData;
    if (coreData.managedObjectContext != nil) {
        if ([coreData.managedObjectContext hasChanges] && ![coreData.managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef IS_DEBUG
			abort();
#endif
        }
    }
}

@end
