//
//  AGAccountManager.m
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAccountManager.h"
#import "AGJSONHttpHandler.h"
#import "AGWaitUtils.h"
#import "AGMessageUtils.h"
#import "AGWaitUtils.h"
#import "AGDefines.h"
#import "AGManagerUtils.h"
#import "AGUtils.h"

static NSString *SignupPath = @"account/emailSignup.action?";
static NSString *EmailSigninPath = @"account/emailSignin.action?";
static NSString *ScreenNameSigninPath = @"account/screenNameSignin.action?";
static NSString *SignoutPath = @"account/signout.action?";

@implementation AGAccountManager

- (void) signup:(NSMutableDictionary*) params image:(UIImage *)image block:(AGAccountSignDoneBlock)block
{
    NSMutableString *path = [NSMutableString stringWithCapacity:1024];
    [path appendString:SignupPath];
    [AGUtils encodeParams:params path:path device:YES];
    
    [AGWaitUtils startWait:@""];
    
    [[AGJSONHttpHandler handler] start:path context:image block:^(NSError *error,id context, NSMutableDictionary *dict) {
        BOOL stop = YES;
        if (error) {
            [AGMessageUtils errorNetwork:error];
        }
        else{
            if (dict == nil) {
                [AGMessageUtils errorServer];
            }
            else{
                NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
                if (status.intValue == 0) {
                    NSMutableDictionary *result = [dict objectForKey:AGLogicJSONResultKey];
                    if ([result isEqual:[NSNull null]]){
                        [AGMessageUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.signup.duplicate", @"msesage.signup.duplicate")];
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
                    [AGMessageUtils errorServer];
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
    
    [AGUtils encodeParams:params path:path device:YES];
    [AGWaitUtils startWait:@""];
    
    [[AGJSONHttpHandler handler] start:path context:nil block:^(NSError *error,id context, NSMutableDictionary *dict) {
        [AGWaitUtils startWait:nil];
        if (error) {
            [AGMessageUtils errorNetwork:error];
        }
        else{
            if (dict == nil) {
                [AGMessageUtils errorServer];
            }
            else{
                NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
                
                if (status.intValue == 0) {
                    NSDictionary *result = [dict objectForKey:@"result"];
                    if ([result isEqual:[NSNull null]]){
                        [AGMessageUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.signin.notmatch", @"message.signin.notmatch")];
                    }
                    else{
                        //succeed
                        if (block) {
                            block();
                        }
                    }
                }
                else{
                    [AGMessageUtils errorServer];
                }

            }
            
            
        }
        
    }];
}

-(void) signout
{
    NSString *path = SignoutPath;
    //[AGWaitUtils startWait:@""];
    
    [[AGJSONHttpHandler handler] start:path context:nil block:^(NSError *error,id context, NSMutableDictionary *dict) {
        //[AGWaitUtils startWait:nil];
        if (error) {
            //NSLog(@"network error%@", error.localizedDescription);
        }
        else{
            if (dict == nil) {
                //NSLog(@"server error%@", error.localizedDescription);
            }
            else{
                NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
                if (status.intValue == 0) {
                     //NSLog(@"signout succeeded");
                }
                else{
                     //NSLog(@"server error");
                }
                
            }
            
            
        }
        
    }];
}

@end