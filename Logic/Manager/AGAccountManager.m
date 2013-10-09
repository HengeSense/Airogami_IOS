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
#import "AGControllerUtils.h"
#import "AGRootViewController.h"
#import "AGAppDirector.h"
#import "AGAuthenticate.h"
#import "AGFileManager.h"
#import "AGNotificationCenter.h"
#import "AGAccountStat.h"
#import "AGAppDirector.h"

static NSString *SignupPath = @"account/emailSignup.action?";
static NSString *EmailSigninPath = @"account/emailSignin.action?";
static NSString *ScreenNameSigninPath = @"account/screenNameSignin.action?";
static NSString *SignoutPath = @"account/signout.action?";
static NSString *ChangePasswordPath = @"account/changePassword.action?";
static NSString *ChangeScreenNamePath = @"account/changeScreenName.action?";
static NSString *ObtainTokensPath = @"data/dataManager?";
//
static NSString *SignupDuplicate = @"message.signup.duplicate";
static NSString *SigninNotMatch = @"error.signin.notmatch.message";
static NSString *SigninNeeded = @"error.signin.need.title";
static NSString *SigninOther = @"error.signin.other.message";
static NSString *SigninBanned = @"error.account.signin.banned";

@interface AGAccountManager()
{
    AGAppDirector *appDirector;
}
@end

@implementation AGAccountManager

- (id)init
{
    if (self = [super init]) {
        appDirector = [AGAppDirector appDirector];
    }
    return self;
}

- (void) signup:(NSDictionary*)params image:(UIImage *)image block:(AGAccountSignupDoneBlock)block
{
    NSString *password = [params objectForKey:@"password"];
    
    [AGWaitUtils startWait:@""];
    
    [[AGJSONHttpHandler handler] start:SignupPath params:params device:YES context:image block:^(NSError *error,id context, NSMutableDictionary *dict) {
        BOOL stop = YES;
        if (error) {
            [AGMessageUtils alertMessageWithError:error];
        }
        else{
            NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
            if (status.intValue == 0) {
                NSMutableDictionary *result = [dict objectForKey:AGLogicJSONResultKey];
                NSString *str = [result objectForKey:AGLogicJSONErrorKey];
                if (str) {
                    if ([str isEqualToString:@"duplicate"]) {
                        [AGMessageUtils alertMessageWithTitle:@"" message:SignupDuplicate];
                    }
                    else{
                        error = [AGMessageUtils errorServer];
                        [AGMessageUtils alertMessageWithError:error];
                    }
                
                }
                else{
                    //succeed
                    stop = NO;
                    NSMutableDictionary *accountJson = [result objectForKey:@"account"];
                    //
                    AGAppConfig *appConfig = [AGAppDirector appDirector].appConfig;
                    [appConfig updateAccountId:[accountJson objectForKey:@"accountId"]];
                    [[AGCoreData coreData] resetPath];
                    //
                    
                    appDirector.account = [[AGControllerUtils controllerUtils].accountController saveAccount:accountJson];
                    [appConfig updateAppAccount:appDirector.account password:password];
                    
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

- (void) signin:(NSDictionary*) pp automatic:(BOOL)automatic animated:(BOOL)animated context:(id)context  block:(AGAccountSigninDoneBlock)block
{
    NSMutableString *path = [NSMutableString stringWithCapacity:128];
    if ([pp objectForKey:@"email"]) {
        [path appendString:EmailSigninPath];
    }
    else{
        [path appendString:ScreenNameSigninPath];
    }
    NSMutableDictionary *params = [pp mutableCopy];
    if (automatic) {
        [params setObject:@"true" forKey:@"automatic"];
        //[params setObject:account.accountStat.signinCount forKey:@"signinCount"];
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
            if (animated && [error.domain isEqualToString:@"Cancel"] == NO) {
                [AGMessageUtils alertMessageWithError:error];
            }
        
        }
        else{
            NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
            
            if (status.intValue == 0) {
                NSMutableDictionary *result = [dict objectForKey:AGLogicJSONResultKey];
                NSMutableDictionary *accountJson = [result objectForKey:@"account"];
                NSString *str = [result objectForKey:AGLogicJSONErrorKey];
                AGAppConfig *appConfig = [AGAppDirector appDirector].appConfig;
                if (str) {
                    if ([str isEqual:@"banned"]) {
                        if (automatic || animated) {
                            [AGMessageUtils alertMessageWithTitle:nil message:SigninBanned];
                        }
                        if (automatic) {
                            [appDirector gotoSign];
                        }
                    }
                    //signinCount not match
                    else if ([str isEqual:@"elsewhere"]){
                        if (automatic || animated) {
                            [AGMessageUtils alertMessageWithTitle:SigninNeeded message:SigninOther];
                        }
                        if (automatic) {
                            [appDirector gotoSign];
                        }
                        
                    }
                    else if([str isEqual:AGLogicJSONNoneValue]){
                        //not match
                        if (automatic) {
                            [AGMessageUtils alertMessageWithTitle:SigninNeeded message:SigninNotMatch];
                        }
                        else if (animated){
                            [AGMessageUtils alertMessageWithTitle:nil message:SigninNotMatch];
                        }
                        if (automatic) {
                            [appDirector gotoSign];
                        }
                    }
                    error = [AGMessageUtils errorClient];
                    
                }
                else{
                    //succeed
                    succeed = YES;
                    if (accountJson) {
                        //
                        AGCoreData *coreData;
                        NSNumber *signinCount = nil;
                        if (automatic) {
                            coreData = [AGCoreData coreData];
                            [coreData registerObserverForEntityName:@"AGAccount" forKey:@"updateCount" count:1];
                        }
                        else{
                            NSNumber *accountId = [accountJson objectForKey:@"accountId"];;
                            [appConfig updateAccountId:accountId];
                            [[AGCoreData coreData] resetPath];
                            signinCount = [[AGControllerUtils controllerUtils].accountController findAccountStat:accountId].signinCount;
                            if (signinCount) {
                                signinCount = [NSNumber numberWithInt:signinCount.intValue + 1];
                            }
                        }
                        //
                        appDirector.account = [[AGControllerUtils controllerUtils].accountController saveAccount:accountJson];
                        //
                        AGAccountController *accountController = [AGControllerUtils controllerUtils].accountController;
                        if (automatic) {
                            NSArray *changedAccounts = [coreData unregisterObserver];
                            if (changedAccounts.count) {
                                [accountController addNewAccounts:changedAccounts];
                                NSDictionary *dict = [NSDictionary dictionary];
                                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainAccounts object:self userInfo:dict];
                            }
                        }
                        else{
                            [appConfig updateAppAccount:appDirector.account password:password];
                            if (signinCount && [signinCount isEqualToNumber:appDirector.account.accountStat.signinCount] == NO) {
                                [accountController setSynchronizing:YES];
                            }
                        }
                        
                    }
                    else{
                        //already signed in
#ifdef IS_DEBUG
                        NSLog(@"Already signed in");
#endif
                    }
                    
                }
            }
            else{
#ifdef IS_DEBUG
                NSLog(@"%@", dict);
#endif
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

-(void) signout:(id)context block:(AGHttpDoneBlock)block
{
    if (appDirector.account == nil) {
        if (block) {
             block(nil, context);
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:appDirector.account.accountStat.signinCount forKey:@"signinCount"];
    [params setObject:appDirector.account.accountId forKey:@"accountId"];
    
    [AGWaitUtils startWait:@""];
    
    [[AGJSONHttpHandler handler] start:SignoutPath params:params device:YES  context:context block:^(NSError *error,id context, NSMutableDictionary *dict) {
        [AGWaitUtils startWait:nil];
        if (error) {
            if ([error.domain isEqualToString:@"Cancel"] == NO) {
                [AGMessageUtils alertMessageWithError:error];
            }
            
#ifdef IS_DEBUG
            NSLog(@"http request error%@", error);
#endif
        }
        else{
            NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
            if (status.intValue == 0) {
#ifdef IS_DEBUG
                NSLog(@"signout.result = %@", [dict objectForKey:AGLogicJSONResultKey]);
#endif
            }
            else{
                error = [AGMessageUtils errorServer];
            }
        }
        if (block) {
            block(error, context);
        }
        
    }];
}

- (void) obtainTokens:(NSMutableDictionary *)params context:(id)context block:(AGHttpFinishBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ObtainTokensPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (block) {
            block(error, context, result);
        }
       
   }];
}

- (void) changePassword:(NSDictionary *)params context:(id)context block:(AGHttpSucceedBlock)block
{
    NSString *password = [params objectForKey:@"newPassword"];
    [AGJSONHttpHandler request:YES params:params path:ChangePasswordPath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        BOOL succeed = NO;
        if (error) {
            
        }
        else{
             NSNumber *number = [result objectForKey:AGLogicJSONSucceedKey];
             succeed = number.boolValue;
            if (succeed) {
                [[AGAppDirector appDirector].appConfig updatePassword:password];
            }
        }
        if (block) {
            block(error, context, succeed);
        }
        
    }];
}

- (void) changeScreenName:(NSDictionary *)params context:(id)context block:(AGHttpSucceedBlock)block
{
    NSString *screenName = [params objectForKey:@"screenName"];
    [AGJSONHttpHandler request:YES params:params path:ChangeScreenNamePath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        BOOL succeed = NO;
        if (error) {
            
        }
        else{
            NSNumber *number = [result objectForKey:AGLogicJSONSucceedKey];
            succeed = number.boolValue;
            if (succeed) {
                appDirector.account.profile.screenName = screenName;
                [[AGCoreData coreData] save];
            }
        }
        if (block) {
            block(error, context, succeed);
        }
        
    }];
}

- (NSDictionary*) paramsForChangePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:oldPassword forKey:@"oldPassword"];
    [params setObject:newPassword forKey:@"newPassword"];
    return params;
}

- (NSDictionary*) paramsForChangeScreenName:(NSString*)screenName
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:screenName forKey:@"screenName"];
    return params;
}


//Kickoff autoSignin
- (void)autoSignin:(id)context block:(AGHttpDoneBlock)block
{
    AGAppConfig *appConfig = [AGAppDirector appDirector].appConfig;
    NSMutableDictionary *params = [appConfig autoSigninParams];
    if (params.count) {
        [self signin:params automatic:YES animated:NO context:nil block:^(NSError *error, BOOL succeed) {
#ifdef IS_DEBUG
            NSLog(@"Kickoff autoSignin: succeed=%d", succeed);
#endif
            if (block) {
                block(error, context);
            }
        }];
    }
}

- (void) autoSignin:(NSDictionary*)reqDict
{
    AGAppConfig *appConfig = [AGAppDirector appDirector].appConfig;
    NSMutableDictionary *params = [appConfig autoSigninParams];
    if (params.count) {
        //NSString *prompt = [reqDict objectForKey:@"prompt"];
        //BOOL animated = prompt != nil;
        [self signin:params automatic:YES animated:NO context:nil block:^(NSError *error, BOOL succeed) {
            if (reqDict) {
                if (succeed) {
                    [AGJSONHttpHandler start:reqDict];
                }
                else{
                    AGHttpJSONHandlerFinishBlock block = [reqDict objectForKey:@"block"];
                    id context = [reqDict objectForKey:@"context"];
                    if (block) {
                        block(error, context, nil);
                    }
                }
            }
#ifdef IS_DEBUG
            NSLog(@"autoSignin: succeed=%d", succeed);
#endif
        }];
    }

}


@end
