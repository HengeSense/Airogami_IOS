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
#import "AGWaitUtils.h"
#import "AGUIUtils.h"
#import "AGWaitUtils.h"
#import "AGDefines.h"
#import "AGManagerUtils.h"

static NSString *SignupPath = @"account/emailSignup.action?";
static NSString *EmailSigninPath = @"account/emailSignin.action?";
static NSString *ScreenNameSigninPath = @"account/screenNameSignin.action?";

@implementation AGAccountManager

- (void) signup:(NSMutableDictionary*) params image:(UIImage *)image block:(AGAccountSignDoneBlock)block
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
    [path appendString:@"clientAgent.deviceName=IOS&clientAgent.clientVersion="];
    [path appendString:AGApplicationVersion];
    
    [AGWaitUtils startWait:@""];
    
    [[AGJSONHttpHandler handler] start:path context:image block:^(NSError *error,id context, NSMutableDictionary *dict) {
        BOOL stop = YES;
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
                        //succeed
                        stop = NO;
                        [AGWaitUtils startWait:NSLocalizedString(@"message.account.signup.uploadingicons", @"message.account.operate.uploadingicons")];
                        NSMutableDictionary *account = [result objectForKey:@"account"];
                        
                        result = [NSJSONSerialization JSONObjectWithData:[[result objectForKey:@"tokens"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        NSMutableDictionary *tokens = [result objectForKey:AGLogicJSONResultKey];
                        
                        [[AGManagerUtils managerUtils].profileManager uploadIcons:tokens image:context context:nil block:^(NSError *error, id context) {
                            [AGWaitUtils startWait:nil];
                            if (block) {
                                block(nil);
                            }
                        }];
                        
                    }
                    
                }
                else{
                    [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.server.unkown", @"message.server.unkown")];
                }
            }
        
        }
        if (stop) {
            [AGWaitUtils startWait:nil];
        }
        
     
    }];
}

- (void) signin:(NSMutableDictionary*) params isEmail:(BOOL)isEmail block:(AGAccountSignDoneBlock)block
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
    
    [AGWaitUtils startWait:@""];
    
    [[AGJSONHttpHandler handler] start:path context:nil block:^(NSError *error,id context, NSMutableDictionary *dict) {
        [AGWaitUtils startWait:nil];
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
                        if (block) {
                            block();
                        }
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
