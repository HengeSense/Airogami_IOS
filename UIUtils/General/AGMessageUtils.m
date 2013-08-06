//
//  AGMessageUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGMessageUtils.h"
#import "AGUIErrorAnimation.h"

@implementation AGMessageUtils

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

+(void) errorNetwork:(NSError*)error
{
    [AGMessageUtils alertMessageWithTitle:NSLocalizedString(@"error.network.connection", @"error.network.connection") error:error];
}

+(void) errorServer
{
    [AGMessageUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.server.unkown", @"message.server.unkown")];
}

@end
