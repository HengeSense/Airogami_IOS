//
//  AGMessageUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGMessageUtils.h"
#import "AGUIErrorAnimation.h"

static NSString *ServerUnkownMessageKey = @"message.server.unkown";
static NSString *UnsavedMessage = @"message.general.edit.unsaved.message";
static NSString *UnsavedGiveup = @"message.general.edit.unsaved.giveup";
static NSString *UnsavedCancel = @"message.general.cancel";
static NSString *UpdateSucceed = @"message.general.edit.succeed";
static NSString *OK = @"message.general.ok";

@implementation AGMessageUtils

+ (void) alertMessageWithTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = NSLocalizedString(title, title);
    alert.message = NSLocalizedString(msg, msg);
    [alert addButtonWithTitle:NSLocalizedString(OK, OK)];
    [alert show];
}

+ (void) alertMessageWithTitle:(NSString *)title error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = NSLocalizedString(title, title);
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:NSLocalizedString(OK, OK)];
    [alert show];
}

+ (void) errorMessgeWithTitle:(NSString*) title view:(UIView *)view
{
    [AGUIErrorAnimation startWithTitle:NSLocalizedString(title, title) view:view];
}

+ (void) updatedAlertMessage
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.message = NSLocalizedString(UpdateSucceed, UpdateSucceed);
    [alert addButtonWithTitle:NSLocalizedString(OK, OK)];
    [alert show];
}

+ (void) modifiedAlertMessage:(id<UIAlertViewDelegate>)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(UnsavedMessage, UnsavedMessage) delegate:delegate cancelButtonTitle:NSLocalizedString(UnsavedCancel, UnsavedCancel) otherButtonTitles:NSLocalizedString(UnsavedGiveup, UnsavedGiveup), nil];
    [alertView show];
}

+(void) errorMessageHttpRequest:(NSError*)error
{
    if ([@"Server" isEqual:error.domain]) {
        [AGMessageUtils alertMessageWithTitle:NSLocalizedString(@"error.network.connection", @"error.network.connection") error:error];
    }
    else{
        [AGMessageUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"", ServerUnkownMessageKey)];
    }

}

+(void) errorMessageServer
{
    [AGMessageUtils alertMessageWithTitle:@"" message:NSLocalizedString(ServerUnkownMessageKey, ServerUnkownMessageKey)];
}

+(NSError*) errorServer:(int)code key:(NSString*)key
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    if (key == nil) {
        key = ServerUnkownMessageKey;
    }
    [details setValue:NSLocalizedString(key, key) forKey:NSLocalizedDescriptionKey];
    NSError *error = [[NSError alloc] initWithDomain:@"Server" code:code userInfo:details];
    return error;
}

@end
