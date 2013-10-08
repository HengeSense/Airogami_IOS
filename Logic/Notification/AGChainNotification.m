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
#import "AGAccountStat.h"

NSString *AGNotificationGetNewChains = @"notification.getnewchains";
NSString *AGNotificationGetChains = @"notification.getchains";
NSString *AGNotificationChainRefreshed = @"notification.chainrefreshed";

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

NSString *AGNotificationViewingChainMessagesForChain = @"notification.viewingChainMessagesForChain";
NSString *AGNotificationViewedChainMessagesForChain = @"notification.viewedChainMessagesForChain";
NSString *AGNotificationUnreadChainMessagesChangedForChain = @"notification.unreadChainMessagesChangedForChain";

@interface AGChainNotification()
{
    //chain messages
    BOOL moreChainMessages;
    NSNumber *chainMessageMutex;
    BOOL obtainingChainMessages;
    //get new chain
    BOOL moreGetNewChains;
    NSNumber *getNewChainMutex;
    BOOL gettingNewChains;
    //get new chain
    BOOL moreGetChains;
    NSNumber *getChainMutex;
    BOOL gettingChains;
    //receive chain
    BOOL moreReceiveChains;
    NSNumber *receiveChainMutex;
    BOOL receivingChains;
    //obtain chain
    BOOL moreObtainChains;
    NSNumber *obtainChainMutex;
    BOOL obtainingChains;
    //
    NSNumber *viewingChainId;
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
        //
        [notificationCenter addObserver:self selector:@selector(getNewChains:) name:AGNotificationGetNewChains object:nil];
        [notificationCenter addObserver:self selector:@selector(getChains:) name:AGNotificationGetChains object:nil];
        //collect
        [notificationCenter addObserver:self selector:@selector(receiveChains:) name:AGNotificationReceiveChains object:nil];

        //obtain chains
        [notificationCenter addObserver:self selector:@selector(obtainChains:) name:AGNotificationObtainChains object:nil];
        
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(obtainChainMessages:) name:AGNotificationObtainChainMessages object:nil];
        //get messages for chain
        //obtain messages
        [notificationCenter addObserver:self selector:@selector(getChainMessagesForChain:) name:AGNotificationGetChainMessagesForChain object:nil];
        //
        [notificationCenter addObserver:self selector:@selector(viewedChainMessagesForChain:) name:AGNotificationViewedChainMessagesForChain object:nil];
        [notificationCenter addObserver:self selector:@selector(viewingChainMessagesForChain:) name:AGNotificationViewingChainMessagesForChain object:nil];
    }
    return self;
}

- (void) getNewChains:(NSNotification*) notification
{
    NSNumber *number = [notification.userInfo objectForKey:@"updateInc"];
    NSNumber * maxUpdateInc = [[AGControllerUtils controllerUtils].chainController recentUpdateInc];
    if (number && number.longLongValue <= maxUpdateInc.longLongValue) {//notified
        return;
    }
    BOOL shouldGet = NO;
    @synchronized(getNewChainMutex){
        if (gettingNewChains) {
            moreGetNewChains = YES;
        }
        else{
            gettingNewChains = YES;
            shouldGet = YES;
        }
    }
    
    if (shouldGet) {
        [self getNewChains];
    }
    
}

- (void) getNewChains
{
    NSNumber * start = [[AGControllerUtils controllerUtils].chainController recentUpdateInc];
    AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
    NSDictionary * params = [chainManager paramsForGetNewChains:start];
    [chainManager getNewChains:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *chains) {
        if (error == nil) {
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self getNewChains];
            }
            else{
                //whether has more
                BOOL shouldGet = NO;
                @synchronized(getNewChainMutex){
                    if (moreGetNewChains) {
                        moreGetNewChains = NO;
                        shouldGet = YES;
                    }
                    else{
                        gettingNewChains = NO;
                    }
                }
                if (shouldGet) {
                    [self getNewChains];
                }
                else{
                    [self refreshed];
                }
            }
            [self gotNewChains];
        }
        else{
            //should deal with server error
            @synchronized(getNewChainMutex){
                moreGetNewChains = NO;
                gettingNewChains = NO;
            }
            [self refreshed];
        }
    }];
}

- (void) gotNewChains
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationGetChains object:self userInfo:dict];
}

- (void)refreshed
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"chain" forKey:@"source"];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationChainRefreshed object:self userInfo:dict];
}

- (void) getChains:(NSNotification*) notification
{
    BOOL shouldGet = NO;
    @synchronized(getChainMutex){
        if (gettingChains) {
            moreGetChains = YES;
        }
        else{
            gettingChains = YES;
            shouldGet = YES;
        }
    }
    
    if (shouldGet) {
        [self getChains];
    }
    
}

- (void) getChains
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSArray *newChainIds = [controllerUtils.chainController getNewChainIdsForUpdate];
    if (newChainIds.count) {
        [self getChainsForNewChainIds:newChainIds];
    }
    else{
        @synchronized(getChainMutex){
            moreGetChains = NO;
            gettingChains = NO;
        }
        //
        NSDictionary *dict = [NSDictionary dictionary];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:AGNotificationObtainChainMessages object:self userInfo:dict];
    }
}

- (void) getChainsForNewChainIds:(NSArray*)newChainIds
{
    AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
    NSDictionary *params = [chainManager paramsForGetChains:newChainIds];
    [chainManager getChains:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *chains) {
        if (error == nil) {
            [self getChains];
        }
        else{
            //should deal with server error
            @synchronized(getNewChainMutex){
                moreGetNewChains = NO;
                gettingNewChains = NO;
            }
        }
    }];
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
    AGNewChain *newChain = [controllerUtils.chainController getNextNewChainForChainMessage];
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
    NSDate *last = [controllerUtils.chainController recentChainMessage:chain.chainId].createdTime;
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
                [controllerUtils.chainController updateChainMessage:chain];
                //
                [self obtainedChainMessages:chainMessages forChain:chain];
                
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

- (void) obtainedChainMessages:(NSArray*)chainMessages forChain:(AGChain*)chain
{
    //
    AGChainMessage *chainMessage = [[AGControllerUtils controllerUtils].chainMessageController getChainMessageForChain:chain.chainId];
    if (chainMessage) {
        [[AGControllerUtils controllerUtils].chainMessageController updateMineLastTime:chainMessage chain:chain];
        //
         NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *dict = nil;
        if (chainMessage.status.shortValue == AGChainMessageStatusNew) {
            [notificationCenter postNotificationName:AGNotificationCollectedChains object:self userInfo:nil];
        }
        else if (chainMessage.status.shortValue == AGChainMessageStatusReplied) {
            if ([chain.chainId isEqual:viewingChainId]) {
                [[AGControllerUtils controllerUtils].chainMessageController viewedChainMessagesForChain:chain];
            }
            else{
                [[AGControllerUtils controllerUtils].chainMessageController updateChainMessagesCount:chainMessage chain:chain];
                //
                dict = [NSDictionary dictionaryWithObjectsAndKeys:chain.chainId, @"chainId",@"YES", @"NoObtained", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadChainMessagesChangedForChain object:nil userInfo:dict];
            }
            dict = [NSDictionary dictionary];
            [notificationCenter postNotificationName:AGNotificationObtainedChains object:self userInfo:nil];
        }
        //
        dict = [NSDictionary dictionaryWithObjectsAndKeys:chainMessages, @"chainMessages", chain.chainId, @"chainId",@"append",@"action", nil];
        [notificationCenter postNotificationName:AGNotificationGotChainMessagesForChain object:self userInfo:dict];
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

- (void)viewedChainMessagesForChain:(NSNotification*)notification
{
    AGChain *chain = [notification.userInfo objectForKey:@"chain"];
    NSDate *last = [[AGControllerUtils controllerUtils].chainMessageController viewedChainMessagesForChain:chain];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:chain.chainId, @"chainId", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadChainMessagesChangedForChain object:nil userInfo:dict];
    //
    AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
    NSDictionary *params = [chainManager paramsForViewedChainMessages:chain.chainId last:last];
    [chainManager viewedChainMessages:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
            NSDate *lastViewedTime = [result objectForKey:@"lastViewedTime"];
            if (lastViewedTime) {
                [[AGControllerUtils controllerUtils].chainController updateLastViewedTime:lastViewedTime chain:chain];
            }
        }
    }];
}

- (void) viewingChainMessagesForChain:(NSNotification*)notification
{
    AGChain *chain = [notification.userInfo objectForKey:@"chain"];
    viewingChainId = chain.chainId;
}

@end
