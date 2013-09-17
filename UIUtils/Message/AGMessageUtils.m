//
//  AGMessageUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGMessageUtils.h"
#import "AGUIErrorAnimation.h"

static NSString *ServerUnkownMessageKey = @"message.server.unkown.message";
static NSString *ServerUnkownTitleKey = @"message.server.unkown.title";
static NSString *ClientUnkownMessageKey = @"message.client.unkown.message";
static NSString *ClientUnkownTitleKey = @"message.client.unkown.title";
static NSString *ClientNotSigninMessageKey = @"message.client.notsignin.message";
static NSString *ClientNotSigninTitleKey = @"message.client.notsignin.title";
static NSString *UnsavedMessage = @"message.general.edit.unsaved.message";
static NSString *UnsavedGiveup = @"message.general.edit.unsaved.giveup";
static NSString *UnsavedCancel = @"message.general.cancel";
static NSString *UpdateSucceed = @"message.general.edit.succeed";
static NSString *OK = @"message.general.ok";
static NSString *PlaneChanged = @"error.general.planechanged";

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

+ (void) alertMessageWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    NSString *title = [error.userInfo objectForKey:AGErrorTitleKey];
    alert.title = NSLocalizedString(title, title);
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:NSLocalizedString(OK, OK)];
    [alert show];
}

+ (void) errorMessgeWithTitle:(NSString*) title view:(UIView *)view
{
    [AGUIErrorAnimation startWithTitle:NSLocalizedString(title, title) view:view];
}

+ (void) alertMessageUpdated
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.message = NSLocalizedString(UpdateSucceed, UpdateSucceed);
    [alert addButtonWithTitle:NSLocalizedString(OK, OK)];
    [alert show];
}

+ (void) alertMessagePlaneChanged
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.message = NSLocalizedString(PlaneChanged, PlaneChanged);
    [alert addButtonWithTitle:NSLocalizedString(OK, OK)];
    [alert show];
}

+ (void) alertMessageModified:(id<UIAlertViewDelegate>)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(UnsavedMessage, UnsavedMessage) delegate:delegate cancelButtonTitle:NSLocalizedString(UnsavedCancel, UnsavedCancel) otherButtonTitles:NSLocalizedString(UnsavedGiveup, UnsavedGiveup), nil];
    [alertView show];
}//error.network.connection

+(NSError*) errorServer:(NSNumber*)number titleKey:(NSString*)titleKey msgKey:(NSString*)msgKey
{
    if (titleKey == nil) {
        titleKey = ServerUnkownTitleKey;
    }
    if (msgKey == nil) {
        msgKey = ServerUnkownMessageKey;
    }
    return [AGMessageUtils error:number.intValue domain:@"Server" titleKey:titleKey msgKey:msgKey];
}

+(NSError*) errorClient:(NSNumber*)number titleKey:(NSString*)titleKey msgKey:(NSString*)msgKey
{
    if (titleKey == nil) {
        titleKey = ClientUnkownTitleKey;
    }
    if (msgKey == nil) {
        msgKey = ClientUnkownMessageKey;
    }
    return [AGMessageUtils error:number.intValue domain:@"Client" titleKey:titleKey msgKey:msgKey];
}

+ (NSError*) errorServer
{
    return [AGMessageUtils errorServer:nil titleKey:nil msgKey:nil];
}

+ (NSError*) errorClient
{
    return [AGMessageUtils errorClient:nil titleKey:nil msgKey:nil];
}

+ (NSError*) errorNotSignin
{
    return [AGMessageUtils error:AGLogicJSONStatusNotSignin domain:@"Client" titleKey:ClientNotSigninTitleKey msgKey:ClientNotSigninMessageKey];
}

+(NSError*) error:(int)code domain:(NSString*)domain titleKey:(NSString*)titleKey msgKey:(NSString*)msgKey
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:NSLocalizedString(msgKey, msgKey) forKey:NSLocalizedDescriptionKey];
    [details setValue:NSLocalizedString(titleKey, titleKey) forKey:AGErrorTitleKey];
    NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:details];
    return error;
}

@end
