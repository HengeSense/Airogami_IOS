//
//  AGChainNotification.m
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChainNotification.h"
#import "AGControllerUtils.h"
#import "AGChainManager.h"

NSString *AGNotificationCollectedChains = @"notification.collectedchains";
NSString *AGNotificationReceiveChains = @"notification.receivechains";
NSString *AGNotificationGetCollectedChains = @"notification.getcollectedchains";

NSString *AGNotificationObtainedChains = @"notification.obtainedchains";
NSString *AGNotificationObtainChains = @"notification.obtainchains";
NSString *AGNotificationGetObtainedChains = @"notification.getobtainedchains";

NSString *AGNotificationObtainedChainMessagesForChain = @"notification.obtainedchainmessagesforchain";
NSString *AGNotificationObtainChainMessages = @"notification.obtainchainmessages";
NSString *AGNotificationGetObtainedChainMessages = @"notification.getobtainedchainmessages";

NSString *AGNotificationGetChainMessagesForChain = @"notification.getchainmessagesforchain";
NSString *AGNotificationGotChainMessagesForChain = @"notification.gotchainmessagesforchain";

@interface AGChainNotification()
{
    //chain messages
    BOOL moreChainMessages;
    NSNumber *chainMessageMutex;
    BOOL obtainingChainMessages;
}

@end

@implementation AGChainNotification

+(AGChainNotification*) chainNotification
{
    static AGChainNotification *chainNotification;
    if (chainNotification == nil) {
        chainNotification = [[AGChainNotification alloc] init];
    }
    return chainNotification;
}

- (void) obtainedChains
{
    
}

- (void) collectedChains
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollectedChains object:self userInfo:nil];
}

- (void) obtainChainMessages:(NSNotification*) notification
{
    BOOL shouldObtain = NO;
    @synchronized(chainMessageMutex){
        if (obtainingChainMessages) {
            moreChainMessages = YES;
        }
        else{
            obtainingChainMessages = YES;
            shouldObtain = YES;
        }
    }
    
    if (shouldObtain) {
        [self obtainChainMessages];
    }
    
}

- (void) obtainChainMessages
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGNewChain *newChain = [controllerUtils.chainController getNextNewChain];
    if (newChain) {
        [self obtainChainMessagesForChain:newChain];
    }
    else{
        @synchronized(chainMessageMutex){
            moreChainMessages = NO;
            obtainingChainMessages = NO;
        }
    }
}

/*- (void) obtainChainMessagesForChain:(AGNewChain*)newChain
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
    AGChain *chain = newChain.chain;
    NSNumber *oldUpdateInc = newChain.updateInc;
    NSNumber *lastMsgId = [controllerUtils.chainController recentChainMessageForCollect:<#(NSNumber *)#>].messageId;
    if (lastMsgId) {
        [params setObject:lastMsgId forKey:@"startId"];
    }
    [params setObject:chain.chainId forKey:@"chainId"];
    
    AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
    [chainManager obtainMessages:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error == nil) {
            NSArray *messages = [[AGControllerUtils controllerUtils].messageController saveMessages:[result objectForKey:@"messages"] chain:chain];
            
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self obtainMessagesForChain:newChain];
            }
            else{
                [controllerUtils.chainController removeNewChainForChat:newChain oldUpdateInc:oldUpdateInc];
                [self obtainMessages];
            }
            if (messages.count) {
                [self obtainedMessages:messages forChain:chain.chainId];
                NSNumber *lastMsgId = ((AGMessage*)[messages lastObject]).messageId;
                NSDictionary *params = [chainManager paramsForViewedMessages:chain lastMsgId:lastMsgId];
                [chainManager viewedMessages:params context:nil block:^(NSError *error, id context) {
                    
                }];
            }
            
        }
        else{
            //should deal with server error
            @synchronized(messageMutex){
                moreMessages = NO;
                obtainingMessages = NO;
            }
        }
    }];
    
}*/

@end
