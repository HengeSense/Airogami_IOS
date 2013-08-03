//
//  AGAccountManager.m
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAccountManager.h"
#import "AGJSONHttpHandler.h"
#import "NSString+Addition.h"
#import "AGUIUtils.h"
#import "AGDefines.h"
#import "AGManagerUtils.h"

static NSString *SignupPath = @"account/emailSignup.action?";
static NSString *EmailSigninPath = @"account/emailSignin.action?";
static NSString *ScreenNameSigninPath = @"account/screenNameSignin.action?";

@implementation AGAccountManager

- (void) signup:(NSMutableDictionary*) params image:(UIImage *)image
{
    NSMutableString *path = [NSMutableString stringWithCapacity:1024];
    [path appendString:SignupPath];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *value = obj;
        [path appendString:key];
        [path appendString:@"="];
        [path appendString:[value encodeURIComponent]];
        [path appendString:@"&"];
     
    }];
   // [path appendString:@"clientAgent.deviceName=IOS&clientAgent.clientVersion="];
   // [path appendString:AGApplicationVersion];
    
    [AGUIUtils startWait:YES];
    
    [[AGJSONHttpHandler handler] start:path context:image block:^(NSError *error,id context, NSMutableDictionary *dict) {
        [AGUIUtils startWait:NO];
        if (error) {
            [AGUIUtils alertMessageWithTitle:NSLocalizedString(@"error.network.connection", @"error.network.connection") error:error];
        }
        else{
            if (dict == nil) {
                [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.server.unkown", @"message.server.unkown")];
            }
            else{
                NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
                if (status.intValue == 0) {
                    NSMutableDictionary *result = [dict objectForKey:AGLogicJSONResultKey];
                    if ([result isEqual:[NSNull null]]){
                        [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.signup.duplicate", @"msesage.signup.duplicate")];
                    }
                    else{
                        
                        [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.signup.succeed", @"msesage.signup.succeed")];
                        NSLog(@"%@",NSStringFromClass(result.class) );
                        [[AGManagerUtils managerUtils].profileManager uploadIcon:[result objectForKey:AGLogicJSONResultKey] image:context];
                    }
                    
                }
                else{
                    [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.server.unkown", @"message.server.unkown")];
                }
            }
        
        }
    }];
}

- (void) signin:(NSMutableDictionary*) params isEmail:(BOOL)isEmail
{
    NSMutableString *path = [NSMutableString stringWithCapacity:128];
    if (isEmail) {
        [path appendString:EmailSigninPath];
    }
    else{
        [path appendString:ScreenNameSigninPath];
    }
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *value = obj;
        [path appendString:key];
        [path appendString:@"="];
        [path appendString:[value encodeURIComponent]];
        [path appendString:@"&"];
        
    }];
    [path appendString:@"clientAgent.deviceName=IOS&clientAgent.clientVersion="];
    [path appendString:AGApplicationVersion];
    
    [AGUIUtils startWait:YES];
    
    [[AGJSONHttpHandler handler] start:path context:nil block:^(NSError *error,id context, NSMutableDictionary *dict) {
        [AGUIUtils startWait:NO];
        if (error) {
            [AGUIUtils alertMessageWithTitle:NSLocalizedString(@"error.network.connection", @"error.network.connection") error:error];
        }
        else{
            if (dict == nil) {
                [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.server.unkown", @"message.server.unkown")];
            }
            else{
                NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
                
                if (status.intValue == 0) {
                    NSDictionary *result = [dict objectForKey:@"result"];
                    if ([result isEqual:[NSNull null]]){
                        [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.signin.notmatch", @"message.signin.notmatch")];
                    }
                    else{
                        //succeed
                    }
                }
                else{
                    [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.server.unkown", @"message.server.unkown")];
                }

            }
            
            
        }
    }];
}

@end
