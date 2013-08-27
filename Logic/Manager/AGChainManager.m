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
#import "AGChainNotification.h"

static NSString *SendChainPath = @"chain/sendChain.action?";
static NSString *DeleteChainPath = @"chain/deleteChain.action?";
static NSString *ReplyChainPath = @"chain/replyChain.action?";
static NSString *ThrowChainPath = @"chain/throwChain.action?";
static NSString *ReceiveChainsPath = @"chain/receiveChains.action?";
static NSString *ObtainChainsPath = @"chain/obtainChains.action?";
static NSString *ObtainChainMessagesPath = @"chain/obtainChainMessages.action?";


@implementation AGChainManager

- (void) sendChain:(NSDictionary *)params context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:SendChainPath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {//error, chain
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                //wait for process
            }
            else{
                [AGMessageUtils alertMessageWithTitle:@"" message:AGPlaneSendPlaneOK];
            }
            
        }
        if (block) {
            block(error, context);
        }
        
    }];
}

- (void) replyChain:(AGChainMessage*) chainMessage context:(id)context block:(AGReplyChainFinishBlock)block
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:chainMessage.chain.chainId forKey:@"chainId"];
    [params setObject:chainMessage.content forKey:@"chainMessageVO.content"];
    [params setObject:chainMessage.type forKey:@"chainMessageVO.type"];
    [AGJSONHttpHandler request:NO params:params path:ReplyChainPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        AGChainMessage *remoteChainMessage = nil;
        BOOL refresh = NO;
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGCoreData coreData] remove:chainMessage.chain];
                }
                NSDictionary *chainMessageJson = [result objectForKey:@"chainMessage"];
                if (chainMessageJson) {
                    [[AGControllerUtils controllerUtils].chainMessageController saveChainMessage:chainMessageJson];
                }
                [[AGChainNotification chainNotification] obtainedChains];
                [AGMessageUtils alertMessagePlaneChanged];
                refresh = YES;
            }
            else{
                //succeed
                NSDictionary *dict = [result objectForKey:@"chainMessage"];
                remoteChainMessage = [[AGControllerUtils controllerUtils].chainMessageController saveChainMessage:dict];
                [[AGControllerUtils controllerUtils].chainController increaseUpdateInc:chainMessage.chain];
                [[AGCoreData coreData] remove:chainMessage];
                [[AGChainNotification chainNotification] obtainedChains];
            }
            
        }
        if (block) {
            block(error, context, remoteChainMessage, refresh);
        }
        
    }];
}

@end
