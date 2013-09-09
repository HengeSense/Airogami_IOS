//
//  AGProfileManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGProfileManager.h"
#import "AGUploadHttpHandler.h"
#import "AGUIUtils.h"
#import "UIImage+Addition.h"
#import "AGDefines.h"
#import "AGUIDefines.h"
#import "AGUtils.h"
#import "AGUIDefines.h"
#import "AGWaitUtils.h"
#import "AGJSONHttpHandler.h"
#import "AGMessageUtils.h"
#import "AGControllerUtils.h"

static NSString *EditProfilePath = @"account/editProfile.action?";
static NSString *ObtainProfilePath= @"account/obtainProfile.action?";


@implementation AGProfileManager

//not display error
- (void) uploadIcons:(NSDictionary *)params image:(UIImage *)image context:(id)context block:(AGHttpDoneBlock)block
{
    NSMutableDictionary *small = [params objectForKey:@"small"];
    UIImage *sImage = [image imageWithSize:AGAccountIconSizeSmall];
    params = [params objectForKey:@"medium"];
    [AGWaitUtils startWait:NSLocalizedString(AGAccountUploadingIcons, SignupUploadingIcons)];
    //upload medium icon
    [self uploadIcon:params image:image context:context block:^(NSError *error, id context) {
        if (error == nil) {
            //upload small icon
            [self uploadIcon:small image:sImage context:context block:^(NSError *error, id context) {
                [AGWaitUtils startWait:nil];
                if (block) {
                     block(error, context);
                }
            }];
        }
        else{
            
            [AGWaitUtils startWait:nil];
            
            if (block) {
                block(error, context);
            }
        }
    }];
}

- (void) uploadIcon:(NSDictionary *)params image:(UIImage *)image context:(id)context block:(AGHttpDoneBlock)block
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    if (context) {
        [dict setObject:context forKey:@"Context"];
    }
    if (block) {
        [dict setObject:block forKey:@"Block"];
    }
    
    [[AGUploadHttpHandler handler] uploadImage:image params:params context:dict block:^(NSError *error, id dict) {
        
        if (error) {
#ifdef IS_DEBUG
            NSLog(@"uploadIcon Error: %@", error.userInfo);
#endif
        }
        else{
            //medium succceed
            //NSLog(@"uploadIcon successfully");
        }
        
        id context = [dict objectForKey:@"Context"];
        AGHttpDoneBlock block = [dict objectForKey:@"Block"];
        if (block) {
            block(error, context);
        }
        
    }];
}

- (void) editProfile:(NSDictionary*)pp image:(UIImage*)image context:(id)context block:(AGEditProfileDoneBlock)block
{
    NSMutableDictionary *params = [pp mutableCopy];
    if (image) {
        [params setObject:@"tokens" forKey:@"tokens"];
    }
    [AGJSONHttpHandler request:NO params:params path:EditProfilePath prompt:@"" context:context block:^(NSError *error, id context, id result) {
        BOOL imageDone = NO, profileDone = NO;
        if (error) {
            if (block) {
                block(error, context, profileDone, imageDone);
            }
        }
        else{
            NSDictionary *profileJson = [result objectForKey:@"profile"];
            AGProfile *profile = [[AGControllerUtils controllerUtils].accountController saveProfile:profileJson];
            profileDone = profile != nil;
            if (image) {
                //[params removeObjectForKey:@"tokens"];
                NSString *tokensString = [result objectForKey:@"tokens"];
                if (tokensString && [tokensString isEqual:[NSNull null]] == NO) {
                    result = [NSJSONSerialization JSONObjectWithData:[tokensString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSMutableDictionary *tokens = [result objectForKey:AGLogicJSONResultKey];
                    if (tokens && [tokens isEqual:[NSNull null]] == NO) {
                        [self uploadIcons:tokens image:image context:context block:^(NSError *error, id context) {
                            BOOL imageDone = NO;
                            if (error) {
                                [AGMessageUtils alertMessageWithError:error];
                            }
                            else{
                                imageDone = YES;
                            }
                            if (block) {
                                block(error, context, profileDone, imageDone);
                            }
                        }];
                    }
                    else{
                        error = [AGMessageUtils errorServer];
                        [AGMessageUtils alertMessageWithError:error];
                        if (block) {
                            block(error, context, profileDone, imageDone);
                        }
                    }
                }
                else{
                    error = [AGMessageUtils errorServer];
                    [AGMessageUtils alertMessageWithError:error];
                    if (block) {
                        block(error, context, profileDone, imageDone);
                    }
                }
                
            
            }
            else{
                if (block) {
                    block(error, context, profileDone, imageDone);
                }
            }
        }
        
    }];
}

- (void) obtainProfile:(NSDictionary *)params context:(id)context block:(AGHttpSucceedBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ObtainProfilePath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        BOOL succeed = NO;
        if (error) {
            
        }
        else{
            NSDictionary *profileJson = [result objectForKey:@"profile"];
            AGProfile *profile = [[AGControllerUtils controllerUtils].accountController saveProfile:profileJson];
            succeed = profile != nil;
        
        }
        if (block) {
            block(error, context, succeed);
        }
    }];
}

- (NSDictionary*) paramsForObtainProfile:(NSNumber*)accountId updateCount:(NSNumber*)updateCount
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:accountId forKey:@"accountId"];
    if(updateCount){
        [params setObject:updateCount forKey:@"updateCount"];
    }
    return params;
}

@end
