//
//  AGUIUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 6/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGUIUtils.h"
#import "AGUIErrorAnimation.h"

#define kAGAlertMessageOK @"OK"

@implementation AGUIUtils

+ (void) alertMessageWithTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = NSLocalizedString(title, title);
    alert.message = NSLocalizedString(msg, msg);
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
    [alert show];
}

+ (void) alertMessageWithTitle:(NSString *)title error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = NSLocalizedString(title, title);
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
    [alert show];
}

+ (void) errorMessgeWithTitle:(NSString*) title view:(UIView *)view
{
    [AGUIErrorAnimation startWithTitle:NSLocalizedString(title, title) view:view];
    
}

+ (void) buttonImageNormalToHighlight:(UIButton *)button
{
    UIImage *image = [button imageForState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateHighlighted];
}

+ (void) buttonBackgroundImageNormalToHighlight:(UIButton *)button
{
    UIImage *image = [button backgroundImageForState:UIControlStateNormal];
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
}

@end
