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
#import "AGUtils.h"
#import "AGWaitUtils.h"
#import "AGJSONHttpHandler.h"
#import "AGMessageUtils.h"

static NSString *EditProfilePath = @"account/editProfile.action?";


@implementation AGProfileManager

- (void) uploadIcons:(NSMutableDictionary *)params image:(UIImage *)image context:(id)context block:(AGUploadIconFinishBlock)block
{
    NSMutableDictionary *small = [params objectForKey:@"small"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    
    if (context) {
        [dict setObject:context forKey:@"Context"];
    }
    if (block) {
        [dict setObject:block forKey:@"Block"];
    }
    [dict setObject:[image imageWithSize:AGAccountIconSizeSmall] forKey:@"image"];
    [dict setObject:small forKey:@"small"];
    
    params = [params objectForKey:@"medium"];
    //upload medium icon
    [self uploadIcon:params image:image context:dict block:^(NSError *error, id dict) {
        id context = [dict objectForKey:@"Context"];
        NSMutableDictionary *small = [dict objectForKey:@"small"];
        AGUploadIconFinishBlock block = [dict objectForKey:@"Block"];
        UIImage *image = [dict objectForKey:@"image"];
        if (error == nil) {
            //upload small icon
            [self uploadIcon:small image:image context:context block:block];
        }
        else{
            if (block) {
                block(error, context);
            }
        }
    }];
}

- (void) uploadIcon:(NSMutableDictionary *)params image:(UIImage *)image context:(id)context block:(AGUploadIconFinishBlock)block
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
            if ([error.domain isEqualToString:@"Server Error"]) {
                NSDictionary * info = [NSDictionary dictionaryWithObject:NSLocalizedString(@"message.server.unkown", @"message.server.unkown") forKey:NSLocalizedDescriptionKey];
                error = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:info];
            }
            //NSLog(@"uploadIcon failed");
        }
        else{
            //medium succceed
            //NSLog(@"uploadIcon successfully");
        }
        
        id context = [dict objectForKey:@"Context"];
        AGUploadIconFinishBlock block = [dict objectForKey:@"Block"];
        if (block) {
            block(error, context);
        }
        
    }];
}

- (void) editProfile:(NSMutableDictionary*)params context:(id)context block:(AGEditProfileFinishBlock)block
{
    NSMutableString *path = [NSMutableString stringWithCapacity:1024];
    [path appendString:EditProfilePath];
    
    [AGUtils encodeParams:params path:path device:NO];
    [AGWaitUtils startWait:@""];
    
    [[AGJSONHttpHandler handler] start:path context:context block:^(NSError *error,id context, NSMutableDictionary *dict) {
        [AGWaitUtils startWait:nil];
        if (error) {
            [AGMessageUtils errorMessageHttpRequest:error];;
        }
        else{
            NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
            if (status.intValue == 0) {
                //succeed
#ifdef IS_DEBUG
                NSLog(@"edit profile successfully");
#endif
            }
            else{
                error = [AGMessageUtils errorServer:status.intValue key:[dict objectForKey:AGLogicJSONMessageKey]];
                [AGMessageUtils errorMessageServer];
            }
        }
        block(error, context);
        
    }];
}

@end
