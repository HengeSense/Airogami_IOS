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
#import "AGManagerUtils.h"

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
    //receive chain
    BOOL moreReceiveChains;
    NSNumber *receiveChainMutex;
    BOOL receivingChains;
    //obtain chain
    BOOL moreObtainChains;
    NSNumber *obtainChainMutex;
    BOOL obtainingChains;
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

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        //collect
        [notificationCenter addObserver:self selector:@selector(receiveChains:) name:AGNotificationReceiveChains object:nil];

        //obtain chains
        [notificationCenter addObserver:self selector:@selector(obtainChains:) name:AGNotificationObtainChains object:nil];
        
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(obtainChainMessages:) name:AGNotificationObtainChainMessages object:nil];
        //get messages for chain
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(getChainMessagesForChain:) name:AGNotificationGetChainMessagesForChain object:nil];
    }
    return self;
}

- (void) receiveChains:(NSNotification*) notification
{
    NSNumber *number = [notification.userInfo objectForKey:@"updateInc"];
    NSNumber * maxUpdateInc = [[AGControllerUtils controllerUtils].chainController recentChainUpdateIncForCollect];
    if (number && number.longLongValue <= maxUpdateInc.longLongValue) {//notified
        return;
    }
    BOOL shouldReceive = NO;
    @synchronized(receiveChainMutex){
        if (receivingChains) {
            moreReceiveChains = YES;
        }
        else{
            receivingChains = YES;
            shouldReceive = YES;
        }
    }
    
    if (shouldReceive) {
        [self receiveChains];
    }
    
    
}

- (void) receiveChains
{
    NSNumber * start = [[AGControllerUtils controllerUtils].chainController recentChainUpdateIncForCollect];
    NSDictionary * params = [[AGManagerUtils managerUtils].chainManager paramsForReceiveChains:start];;
    [[AGManagerUtils managerUtils].chainManager receiveChains:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *chains) {
        if (error == nil) {
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self receiveChains];
            }
            else{
                //whether has more
                BOOL shouldReceive= NO;
                @synchronized(receiveChainMutex){
                    if (moreReceiveChains) {
                        moreReceiveChains = NO;
                        shouldReceive = YES;
                    }
                    else{
                        receivingChains = NO;
                    }
                }
                if (shouldReceive) {
                    [self receiveChains];
                }
            }
            if (chains.count) {
                [[AGControllerUtils controllerUtils].chainController addNewChains:chains];
                [self collectedChains];
                NSDictionary *dict = [NSDictionary dictionary];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AGNotificationObtainChainMessages object:self userInfo:dict];

            }
            
        }
        else{
            //should deal with server error
            @synchronized(receiveChainMutex){
                moreReceiveChains = NO;
                receivingChains = NO;
            }
        }
    }];
}

- (void) collectedChains
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollectedChains object:self userInfo:dict];
    
}

- (void) obtainChains:(NSNotification*) notification
{
    NSNumber *number = [notification.userInfo objectForKey:@"updateInc"];
    NSNumber * maxUpdateInc = [[AGControllerUtils controllerUtils].chainController recentChainUpdateIncForChat];
    if (number && number.longLongValue <= maxUpdateInc.longLongValue) {//notified
        return;
    }
    BOOL shouldObtain = NO;
    @synchronized(obtainChainMutex){
        if (obtainingChains) {
            moreObtainChains = YES;
        }
        else{
            obtainingChains = YES;
            shouldObtain = YES;
        }
    }
    
    if (shouldObtain) {
        [self obtainChains];
    }
    
}

- (void) obtainChains
{
    NSNumber * start = [[AGControllerUtils controllerUtils].chainController recentChainUpdateIncForChat];
    NSDictionary * params = [[AGManagerUtils managerUtils].chainManager paramsForObtainChains:start];
    [[AGManagerUtils managerUtils].chainManager obtainChains:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *chains) {
        if (error == nil) {
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self obtainChains];
            }
            else{
                
                //whether has more
                BOOL shouldObtain = NO;
                @synchronized(obtainChainMutex){
                    if (moreObtainChains) {
                        moreObtainChains = NO;
                        shouldObtain = YES;
                    }
                    else{
                        obtainingChains = NO;
                    }
                }
                if (shouldObtain) {
                    [self obtainChains];
                }
            }
            if (chains.count) {
                [[AGControllerUtils controllerUtils].chainController addNewChains:chains];
                [self obtainedChains];
                NSDictionary *dict = [NSDictionary dictionary];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AGNotificationObtainChainMessages object:self userInfo:dict];
            }
            
        }
        else{
            //should deal with server error
            @synchronized(obtainChainMutex){
                moreObtainChains = NO;
                obtainingChains = NO;
            }
        }
    }];
}

- (void) obtainedChains
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainedChains object:self userInfo:dict];
    
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

- (void) obtainChainMessagesForChain:(AGNewChain*)newChain
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
    AGChain *chain = newChain.chain;
    NSNumber *oldUpdateInc = newChain.updateInc;
    NSDate *last = [controllerUtils.chainController recentChainMessageForChat:chain.chainId].createdTime;
    if (last) {
        [params setObject:last forKey:@"last"];
    }
    [params setObject:chain.chainId forKey:@"chainId"];
    
    AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
    [chainManager obtainChainMessages:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error == nil) {
            NSArray *chainMessages = [[AGControllerUtils controllerUtils].chainMessageController saveChainMessages:[result objectForKey:@"chainMessages"] chain:chain];
            
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self obtainChainMessagesForChain:newChain];
            }
            else{
                [controllerUtils.chainController removeNewChain:newChain oldUpdateInc:oldUpdateInc];
                [self obtainChainMessages];
            }
            if (chainMessages.count) {
                [self obtainedChainMessages:chainMessages forChain:chain.chainId];
                NSDate *last = ((AGChainMessage*)[chainMessages lastObject]).createdTime;
                NSDictionary *params = [chainManager paramsForViewedChainMessages:chain.chainId last:last];
                [chainManager viewedChainMessages:params context:nil block:^(NSError *error, id context) {
                    
                }];
            }
            
        }
        else{
            //should deal with server error
            @synchronized(chainMessageMutex){
                moreChainMessages = NO;
                obtainingChainMessages = NO;
            }
        }
    }];
    
}

- (void) obtainedChainMessages:(NSArray*)messages forChain:(NSNumber*)chainId
{
    //
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:messages, @"chainMessages", chainId, @"chainId",@"append",@"action", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationGotChainMessagesForChain object:self userInfo:dict];
    //
    int status = [[AGControllerUtils controllerUtils].chainController chainStatus:chainId];
    if (status == AGChainMessageStatusNew) {
        [notificationCenter postNotificationName:AGNotificationCollectedChains object:self userInfo:nil];
    }
    else if (status == AGChainMessageStatusReplied) {
        [notificationCenter postNotificationName:AGNotificationObtainedChains object:self userInfo:dict];
    }
    
}

- (void) getChainMessagesForChain:(NSNotification*)notification
{
    NSNumber *chainId = [notification.userInfo objectForKey:@"chainId"];
    NSDate *startTime = [notification.userInfo objectForKey:@"startTime"];
    NSAssert(chainId != nil, @"nil chainId");
    [self gotChainMessagesForChain:chainId startTime:startTime];
}

- (void) gotChainMessagesForChain:(NSNumber*)chainId startTime:(NSDate*)startTime
{
    AGChainMessageController *chainMessageController = [AGControllerUtils controllerUtils].chainMessageController;
    NSDictionary *dict = [chainMessageController getChainMessagesForChain:chainId startTime:startTime];
    NSArray *doneMessages = [dict objectForKey:@"chainMessages"];
    NSNumber *more = [dict objectForKey:@"more"];
    NSMutableArray *chainMessages = [NSMutableArray arrayWithCapacity:doneMessages.count];
    int lower = more.boolValue ? 0 : - 1;
    for (int i = doneMessages.count - 1; i > lower; --i) {
        [chainMessages addObject:[doneMessages objectAtIndex:i]];
    }
    
    NSString *action = @"reset";
    if (startTime) {
        action = @"prepend";
    }
    dict = [NSDictionary dictionaryWithObjectsAndKeys:chainMessages, @"chainMessages", chainId, @"chainId", action, @"action", more, @"more", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationGotChainMessagesForChain object:self userInfo:dict];
}

@end
