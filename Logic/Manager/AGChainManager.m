//
//  AGChainManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChainManager.h"
#import "AGJSONHttpHandler.h"
#import "AGMessageUtils.h"
#import "AGUIUtils.h"
#import "AGMessageUtils.h"
#import "AGChainController.h"
#import "AGCoreData.h"
#import "AGControllerUtils.h"
#import "AGChainMessageController.h"
#import "AGNotificationCenter.h"

static NSString *SendChainPath = @"chain/sendChain.action?";
static NSString *DeleteChainPath = @"chain/deleteChain.action?";
static NSString *ReplyChainPath = @"chain/replyChain.action?";
static NSString *GetNeoChainsPath = @"chain/getNeoChains.action?";
static NSString *GetChainsPath = @"chain/getChains.action?";
static NSString *GetOldChainsPath = @"chain/getOldChains.action?";
static NSString *ThrowChainPath = @"chain/throwChain.action?";
static NSString *ReceiveChainsPath = @"chain/receiveChains.action?";
static NSString *ObtainChainsPath = @"chain/obtainChains.action?";
static NSString *ObtainChainMessagesPath = @"chain/obtainChainMessages.action?";
static NSString *ViewedChainMessagesPath = @"chain/viewedChainMessages.action?";



@implementation AGChainManager

- (void) sendChain:(NSDictionary *)params context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:SendChainPath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {//error, chain
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                error = [AGMessageUtils errorClient];
                if ([errorString isEqualToString:@"limit"]) {
                    [AGMessageUtils alertMessageWithTitle:@"" message:AGChainSendChainLimit];
                }
                else{
                    [AGMessageUtils alertMessageWithError:error];
                }
            }
            else{
                [AGMessageUtils alertMessageWithTitle:@"" message:AGChainSendChainOK];
            }
            
            //update accountStat
            NSDictionary *accountStatJson = [result objectForKey:AGLogicJSONAccountStatLeftKey];
            [[AGControllerUtils controllerUtils].accountController saveAccountStat:accountStatJson];
            
        }
        if (block) {
            block(error, context);
        }
        
    }];
}

- (void) replyChain:(NSDictionary*)params chain:(AGChain*)chain context:(id)context block:(AGHttpSucceedBlock)block
{
    [AGJSONHttpHandler request:NO params:params path:ReplyChainPath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        AGChainMessage *remoteChainMessage = nil;
        BOOL succeed = NO;
        if (error) {
            
        }
        else{
            succeed = YES;
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGCoreData coreData] remove:chain];
                }
                else{
                    NSDictionary *chainMessageJson = [result objectForKey:@"chainMessage"];
                    //[[AGControllerUtils controllerUtils].chainMessageController updateChainMessage:chainMessageJson forChain:chain];
                    [[AGControllerUtils controllerUtils].chainMessageController saveChainMessage:chainMessageJson forChain:chain];
                    [[AGChainNotification chainNotification] obtainedChains];
                }
                [[AGChainNotification chainNotification] collectedChains];
                [AGMessageUtils alertMessageChainChanged];
                //error = [AGMessageUtils errorClient];
            }
            else{
                //succeed
                NSDictionary *dict = [result objectForKey:@"chainMessage"];
                remoteChainMessage = [[AGControllerUtils controllerUtils].chainMessageController saveChainMessage:dict forChain:chain];
                chain.updatedTime = remoteChainMessage.createdTime;
                [[AGControllerUtils controllerUtils].chainController updateChainMessage:chain];
                //[[AGCoreData coreData] save];
                //
                //[[AGControllerUtils controllerUtils].chainController increaseUpdateInc];
                [[AGChainNotification chainNotification] obtainedChains];
                [[AGChainNotification chainNotification] collectedChains];
            }
        }
        
        if (block) {
            block(error, context, succeed);
        }
        
    }];
}


- (NSDictionary*)paramsForReplyChain:(NSNumber*)chainId content:(NSString*)content type:(int)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:chainId forKey:@"chainId"];
    [params setObject:content forKey:@"chainMessageVO.content"];
    [params setObject:[NSNumber numberWithInteger:type] forKey:@"chainMessageVO.type"];
    return params;
}

- (void) getNeoChains:(NSDictionary*) params context:(id)context block:(AGGetNeoChainsBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:GetNeoChainsPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *neoChains = nil;
        if (error) {
            
        }
        else{
            //succeed
            neoChains = [[AGControllerUtils controllerUtils].chainController saveNeoChains:[result objectForKey:@"neoChains"]];
        }
        if (block) {
            block(error, context, result, neoChains);
        }
        
    }];
}

- (NSDictionary*)paramsForGetOldChains:(NSNumber*)start end:(NSNumber*)end limit:(NSNumber*)limit
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    if (end) {
        [params setObject:end forKey:@"end"];
    }
    if (limit) {
        [params setObject:limit forKey:@"limit"];
    }
    
    return params;
}

- (NSDictionary*)paramsForGetNeoChains:(NSNumber*)start
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    return params;
}

- (void) getChains:(NSDictionary*) params context:(id)context block:(AGGetChainsBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:GetChainsPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *chains = nil;
        if (error) {
            
        }
        else{
            //succeed
            NSArray *chainsJson = [result objectForKey:@"chains"];
            AGCoreData *coreData = [AGCoreData coreData];
            [coreData registerObserverForEntityName:@"AGAccount" forKey:@"updateCount" count:chainsJson.count];
            chains = [[AGControllerUtils controllerUtils].chainController saveChains:chainsJson];
            NSArray *changedAccounts = [coreData unregisterObserver];
            if (changedAccounts.count) {
                AGAccountController *accountController = [AGControllerUtils controllerUtils].accountController;
                [accountController addNeoAccounts:changedAccounts];
                NSDictionary *dict = [NSDictionary dictionary];
                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainAccounts object:self userInfo:dict];
            }
        }
        if (block) {
            block(error, context, result, chains);
        }
        
    }];
}

- (NSDictionary*)paramsForGetChains:(NSArray*)chainIds
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:chainIds forKey:@"chainIds"];
    
    return params;
}

- (void) getOldChains:(NSDictionary*) params context:(id)context block:(AGGetOldChainsBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:GetOldChainsPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *oldChains = nil;
        if (error) {
            [AGMessageUtils alertMessageWithFilteredError:error];
        }
        else{
            //succeed
            NSArray *oldChainsJson = [result objectForKey:@"oldChains"];
            oldChains = [[AGControllerUtils controllerUtils].chainController saveOldChains:oldChainsJson];
        }
        if (block) {
            block(error, context, result, oldChains);
        }
        
    }];
}

- (void) receiveChains:(NSDictionary*) params context:(id)context block:(AGChainsBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ReceiveChainsPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *chains = [NSArray array];
        if (error) {
            
        }
        else{
            //succeed
            chains = [[AGControllerUtils controllerUtils].chainController saveChains:[result objectForKey:@"chains"] forCollect:YES];
        }
        if (block) {
            block(error, context, result, chains);
        }
        
    }];
}

- (NSDictionary*)paramsForReceiveChains:(NSNumber*)start
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    return params;
}

- (void) obtainChains:(NSDictionary*) params context:(id)context block:(AGChainsBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ObtainChainsPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *chains = [NSArray array];
        if (error) {
            
        }
        else{
            //succeed
            chains = [[AGControllerUtils controllerUtils].chainController saveChains:[result objectForKey:@"chains"] forCollect:NO];
        }
        if (block) {
            block(error, context, result, chains);
        }
        
    }];
}

- (NSDictionary*)paramsForObtainChains:(NSNumber*)start
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    
    return params;
}

- (void) throwChain:(NSDictionary*) params chain:(AGChain*)chain context:(id)context block:(AGHttpSucceedBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ThrowChainPath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        BOOL succeed = NO;
        if (error) {
            
        }
        else{
            succeed = YES;
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGCoreData coreData] remove:chain];
                }
                else{//changed status, etc
                    NSDictionary *chainMessageJson = [result objectForKey:@"chainMessage"];
                    //[[AGControllerUtils controllerUtils].chainMessageController updateChainMessage:chainMessageJson forChain:chain];
                    [[AGControllerUtils controllerUtils].chainMessageController saveChainMessage:chainMessageJson forChain:chain];
                    [[AGChainNotification chainNotification] obtainedChains];
                }
                [[AGChainNotification chainNotification] collectedChains];
                [AGMessageUtils alertMessageChainChanged];
            }
            else{
                [[AGCoreData coreData] remove:chain];
                [[AGChainNotification chainNotification] collectedChains];
            }
            
        }
        if (block) {
            block(error, context, succeed);
        }
        
    }];
}

- (NSDictionary*)paramsForThrowChain:(NSNumber*)chainId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:chainId forKey:@"chainId"];
    return params;
}

- (void) deleteChain:(NSDictionary*) params chain:(AGChain*)chain context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:DeleteChainPath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGCoreData coreData] remove:chain];
                }
                NSDictionary *chainMessageJson = [result objectForKey:@"chainMessage"];
                //changed status, etc
                if (chainMessageJson) {
                    AGChainMessage *chainMessage = [[AGControllerUtils controllerUtils].chainMessageController saveChainMessage:chainMessageJson forChain:chain];
                    if (chainMessage.status.intValue != AGChainMessageStatusDeleted) {
                        [AGMessageUtils alertMessageChainChanged];
                    }
                
                }
                
            }
            else{
                //viewedChainMessagesForChain
                NSDictionary *dict = [NSDictionary dictionaryWithObject:chain forKey:@"chain"];
                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewedChainMessagesForChain object:nil userInfo:dict];
                [[AGCoreData coreData] remove:chain];
            }
            
            [[AGChainNotification chainNotification] obtainedChains];
        }
        if (block) {
            block(error, context);
        }
        
    }];
}

- (NSDictionary*)paramsForDeleteChain:(NSNumber*)chainId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:chainId forKey:@"chainId"];
    
    return params;
}

- (void) obtainChainMessages:(NSDictionary *)params context:(id)context block:(AGHttpFinishBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ObtainChainMessagesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
            //succeed
        }
        if (block) {
            block(error, context, result);
        }
        
    }];
}

- (NSDictionary*)paramsForObtainChainMessages:(NSNumber*)chainId last:(NSDate*)last
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:chainId forKey:@"chainId"];
    if (last) {
        [params setObject:last forKey:@"last"];
    }
    
    return params;
}

- (void) viewedChainMessages:(NSDictionary *)params context:(id)context block:(AGHttpFinishBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ViewedChainMessagesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
#ifdef IS_DEBUG
            NSLog(@"ChainManager.viewedChainMessages: result = %@", result);
#endif
        }
        if (block) {
            block(error, context, result);
        }
        
    }];
}

- (NSDictionary*)paramsForViewedChainMessages:(NSNumber*)chainId last:(NSDate*)last
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:chainId forKey:@"chainId"];
    [params setObject:last forKey:@"last"];
    return params;
}

@end
