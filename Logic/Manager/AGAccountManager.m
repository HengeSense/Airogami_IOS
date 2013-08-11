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
#import "AGUIDefines.h"
#import "AGManagerUtils.h"
#import "AGUtils.h"
#import "AGAppDelegate.h"
#import "AGRootViewController.h"

static NSString *SignupPath = @"account/emailSignup.action?";
static NSString *EmailSigninPath = @"account/emailSignin.action?";
static NSString *ScreenNameSigninPath = @"account/screenNameSignin.action?";
static NSString *SignoutPath = @"account/signout.action?";
static NSString *ObtainTokensPath = @"data/dataManager?";
//
static NSString *SignupDuplicate = @"message.signup.duplicate";
static NSString *SigninNotMatch = @"error.signin.notmatch.message";
static NSString *SigninNeeded = @"error.signin.need.title";
static NSString *SigninOther = @"error.signin.other.message";

@implementation AGAccountManager

@synthesize account;

- (id)init
{
    if (self = [super init]) {
        account = [[AGAppDelegate appDelegate].appConfig obtainAccount];
    }
    return self;
}

- (void) signup:(NSDictionary*) params image:(UIImage *)image block:(AGAccountSignupDoneBlock)block
{
    NSMutableString *path = [NSMutableString stringWithCapacity:1024];
    [path appendString:SignupPath];
    [AGUtils encodeParams:params path:path device:YES];
    
    [AGWaitUtils startWait:@""];
    
    [[AGJSONHttpHandler handler] start:path context:image block:^(NSError *error,id context, NSMutableDictionary *dict) {
        BOOL stop = YES;
        if (error) {
            [AGMessageUtils alertMessageWithError:error];
        }
        else{
            NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
            if (status.intValue == 0) {
                NSMutableDictionary *result = [dict objectForKey:AGLogicJSONResultKey];
                if ([result isEqual:[NSNull null]]){
                    [AGMessageUtils alertMessageWithTitle:@"" message:SignupDuplicate];
                }
                else{
                    //succeed
                    stop = NO;
                    NSMutableDictionary *accountJson = [result objectForKey:@"account"];
                    account = [[AGAppDelegate appDelegate].coreDataController saveAccount:accountJson];
                    
                    result = [NSJSONSerialization JSONObjectWithData:[[result objectForKey:@"tokens"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSMutableDictionary *tokens = [result objectForKey:AGLogicJSONResultKey];
                    if (tokens) {
                        [[AGManagerUtils managerUtils].profileManager uploadIcons:tokens image:context context:nil block:^(NSError *error, id context) {
                            if (block) {
                                block(YES);
                            }
                        }];
                    }
                    
                }
                
            }
            else{
#ifdef IS_DEBUG
                NSLog(@"Sign up error: %@", [dict objectForKey:AGLogicJSONMessageKey]);
#endif
                error = [AGMessageUtils errorServer];
                [AGMessageUtils alertMessageWithError:error];
            }
        
        }
        if (stop) {
            [AGWaitUtils startWait:nil];
        }
        
     
    }];
}

- (void) signin:(NSDictionary*) params automatic:(BOOL)automatic animated:(BOOL)animated context:(id)context  block:(AGAccountSigninDoneBlock)block
{
    NSMutableString *path = [NSMutableString stringWithCapacity:128];
    if ([params objectForKey:@"email"]) {
        [path appendString:EmailSigninPath];
    }
    else{
        [path appendString:ScreenNameSigninPath];
    }
    
    NSString *password = [params objectForKey:@"password"];
    
    [AGUtils encodeParams:params path:path device:YES];
    if (animated) {
        [AGWaitUtils startWait:@""];
    }
    
    [[AGJSONHttpHandler handler] start:path context:context block:^(NSError *error,id context, NSMutableDictionary *dict) {
        if (animated) {
            [AGWaitUtils startWait:nil];
        }
        BOOL succeed = NO;
        if (error) {
            if (animated) {
                [AGMessageUtils alertMessageWithError:error];
            }
        
        }
        else{
            NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
            
            if (status.intValue == 0) {
                NSMutableDictionary *result = [dict objectForKey:AGLogicJSONResultKey];
                if ([result isEqual:[NSNull null]]){
                    //not match
                    if (animated) {
                        [AGMessageUtils alertMessageWithTitle:@"" message:SigninNotMatch];
                    }
                    if (automatic) {
                        [AGMessageUtils alertMessageWithTitle:SigninNeeded message:SigninNotMatch];
                        [[AGAppDelegate appDelegate].appConfig resetAppAccount];
                        [[AGRootViewController rootViewController] switchToSign];
                    }
                
                }
                else{
                    //succeed
                    account = [[AGAppDelegate appDelegate].coreDataController saveAccount:result];
                    AGAppConfig *appConfig = [AGAppDelegate appDelegate].appConfig;
                    if (automatic) {
                        //signined at other place
                        if ([appConfig accountUpdated:account]) {
                            [AGMessageUtils alertMessageWithTitle:SigninNeeded message:SigninOther];
                            [appConfig resetAppAccount];
                            [[AGRootViewController rootViewController] switchToSign];
                        }
                    }
                    else{
                        [appConfig updateAppAccount:account password:password];
                    }
                    succeed = YES;
                }
            }
            else{
                error = [AGMessageUtils errorServer];
                if (animated) {
                    [AGMessageUtils alertMessageWithError:error];
                }
            
            }
        }
        if (block) {
           block(error, succeed);
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
            //NSLog(@"http request error%@", error.localizedDescription);
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
        
    }];
}

- (void) obtainTokens:(NSMutableDictionary *)params context:(id)context block:(AGAccountObtainTokensDoneBlock)block
{
   [AGJSONHttpHandler request:params path:ObtainTokensPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
       block(error, context, result);
   }];
}

- (void) autoSignin
{
    AGAppConfig *appConfig = [AGAppDelegate appDelegate].appConfig;
    NSMutableDictionary *params = [appConfig siginParams];
    if (params.count) {
        [self signin:params automatic:YES animated:NO context:nil block:^(NSError *error, BOOL succeed) {
#ifdef IS_DEBUG
            NSLog(@"autoSignin: succeed=%d", succeed);
#endif
        }];
    }

}

@end
