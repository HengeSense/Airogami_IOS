//
//  AGDataManger.m
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGDataManger.h"
#import "AGDefines.h"
#import "AGUIDefines.h"
#import "NSString+Addition.h"
#import "AGJSONHttpHandler.h"
#import "AGMessageUtils.h"
#import "AGUploadHttpHandler.h"
#import "AGAccount.h"

static NSString *MessageDataPath = @"data/messageDataToken.action?";
static NSString *ChainDataPath = @"data/chainDataToken.action?";

@implementation AGDataManger

- (void) messageDataToken:(NSDictionary *)params context:(id)context block:(AGMessageDataTokenBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:MessageDataPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *tokens = nil;
        NSNumber *msgDataInc = nil;
        if (error) {
            //[AGMessageUtils alertMessageWithFilteredError:error];
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                error = [AGMessageUtils errorClient];
            }
            else{
                //succeed
                NSString *tokenString = [result objectForKey:@"token"];
                if (tokenString && [tokenString isEqual:[NSNull null]] == NO) {
                    NSDictionary *token = [NSJSONSerialization JSONObjectWithData:[tokenString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    tokens = [NSArray arrayWithObject:token];
                }
                else{
                    NSString *smallString = [result objectForKey:@"small"];
                    assert(smallString && [smallString isEqual:[NSNull null]] == NO);
                    NSString *mediumString = [result objectForKey:@"medium"];
                    assert(mediumString && [mediumString isEqual:[NSNull null]] == NO);
                    //
                    NSDictionary *small = [NSJSONSerialization JSONObjectWithData:[smallString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSDictionary *medium = [NSJSONSerialization JSONObjectWithData:[mediumString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    tokens = [NSArray arrayWithObjects:medium, small, nil];
                }
                
                msgDataInc = [result objectForKey:@"msgDataInc"];
            }
            
        }
        if (block) {
            block(error, context, tokens, msgDataInc);
        }
        
    }];
}

- (NSDictionary*)paramsForMessageDataToken:(NSNumber*)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:type forKey:@"type"];
    return params;
}

- (NSDictionary*)paramsForChainDataToken:(NSNumber*)type chainId:(NSNumber*)chainId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:type forKey:@"type"];
    [params setObject:chainId forKey:@"chainId"];
    return params;
}

- (void) uploadData:(NSData *)data params:(NSDictionary *)params type:(AGContentTypeEnum)type context:(id)context block:(AGHttpDoneBlock)block
{
    assert(type >= AGContentTypeAudio && type <= AGContentTypeImage);
    [[AGUploadHttpHandler handler] uploadData:data type:type params:params context:context block:^(NSError *error, id context) {
        
        if (error) {
#ifdef IS_DEBUG
            //NSLog(@"uploadData Error: %@", error.userInfo);
#endif
        }
        else{
#ifdef IS_DEBUG
            NSLog(@"DataManager:uploadData successfully");
#endif
        }
        if (block) {
            block(error, context);
        }
        
    }];
}


@end
