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

static NSString *AGContentTypes[] = {@".audio", @".jpg"};

static NSString *MessageDataPath = @"data/messageDataToken.action?";
static NSString *ChainDataPath = @"data/chainDataToken.action?";

@implementation AGDataManger

//accounts/reversed accountId/account/icon ...
- (NSURL*) accountIconUrl:(NSNumber*)accountId small:(BOOL) small
{
    NSString *suffix;
    if (small) {
        suffix = @"";
    }
    else{
        suffix = @"-medium";
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@accounts/%@/account/icon%@.jpg", AGDataServerUrl, accountId.stringValue.reverseString, suffix]];
}

//accounts/reversed accountId/messageData/reversed msgDataInc
- (NSURL*) messageDataUrl:(NSNumber*)accountId msgDataInc:(NSNumber*)msgDataInc type:(AGMessageTypeEnum) type
{
    assert(type >= AGMessageTypeAudio && type <= AGMessageTypeImage);
    NSURL *url = nil;
    NSString *suffix = AGContentTypes[type - AGMessageTypeAudio];
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@accounts/%@/messageData/%@%@", AGDataServerUrl, accountId.stringValue.reverseString, msgDataInc.stringValue.reverseString, suffix]];
    return url;
}

- (void) messageDataToken:(NSDictionary *)params context:(id)context block:(AGMessageDataTokenBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:MessageDataPath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSDictionary *token = nil;
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
                    token = [NSJSONSerialization JSONObjectWithData:[tokenString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                }
            }
            
        }
        if (block) {
            block(error, context, token);
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
            NSLog(@"uploadData Error: %@", error.userInfo);
#endif
        }
        else{
#ifdef IS_DEBUG
            NSLog(@"uploadData successfully");
#endif
        }
        if (block) {
            block(error, context);
        }
        
    }];
}


@end
