//
//  AGRoorViewController.h
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGSettingProfileMasterViewController.h"
#import "AGLocationViewController.h"

@interface AGRootViewController : UIViewController

+ (AGRootViewController*)rootViewController;
+ (AGSettingProfileMasterViewController*) settingViewController;
+ (AGLocationViewController*) locationViewController;
- (void) switchToMain;
- (void) switchToSign;

@end
