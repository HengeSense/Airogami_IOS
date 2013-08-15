//
//  AGAppDelegate.h
//  Airogami
//
//  Created by Tianhu Yang on 6/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGAppConfig.h"

@interface AGAppDelegate : UIResponder <UIApplicationDelegate>

+(AGAppDelegate*) appDelegate;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AGAppConfig *appConfig;


@end
