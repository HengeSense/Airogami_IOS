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

static NSString *EditProfilePath = @"account/editProfile.action?";


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

- (void) editProfile:(NSDictionary*)pp image:(UIImage*)image context:(id)context block:(AGHttpDoneBlock)block
{
    NSMutableDictionary *params = [pp mutableCopy];
    if (image) {
        [params setObject:@"tokens" forKey:@"tokens"];
    }
    [AGJSONHttpHandler request:NO params:params path:EditProfilePath prompt:@"" context:context block:^(NSError *error, id context, id result) {
        if (error) {
            if (block) {
                block(error, context);
            }
        }
        else{
            if (image) {
                [params removeObjectForKey:@"tokens"];
                result = [NSJSONSerialization JSONObjectWithData:[[result objectForKey:@"tokens"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSMutableDictionary *tokens = [result objectForKey:AGLogicJSONResultKey];
                if (tokens) {
                    [self uploadIcons:tokens image:image context:context block:^(NSError *error, id context) {
                        if (error) {
                            [AGMessageUtils alertMessageWithError:error];
                        }
                        if (block) {
                            block(error, context);
                        }
                    }];
                }
            
            }
            else{
                if (block) {
                    block(error, context);
                }
            }
        }
        
    }];
}

@end
