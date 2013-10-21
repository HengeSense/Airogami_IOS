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
#import "AGUtils.h"

NSString *AGNotificationGetNeoChains = @"notification.getneochains";
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

NSString *AGNotificationViewChainMessages = @"notification.viewchainmessages";
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
    BOOL moreGetNeoChains;
    NSNumber *getNeoChainMutex;
    BOOL gettingNeoChains;
    //get new chain
    BOOL moreGetChains;
    NSNumber *getChainsMutex;
    BOOL gettingChains;
    //receive chain
    BOOL moreReceiveChains;
    NSNumber *receiveChainMutex;
    BOOL receivingChains;
    //obtain chain
    BOOL moreObtainChains;
    NSNumber *obtainChainMutex;
    BOOL obtainingChains;
    //view chain messages
    BOOL moreViewChainMessages;
    NSNumber *viewChainMessageMutex;
    BOOL viewingChainMessages;
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
        [notificationCenter addObserver:self selector:@selector(getNeoChains:) name:AGNotificationGetNeoChains object:nil];
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
        //view chain message
        [notificationCenter addObserver:self selector:@selector(viewChainMessages:) name:AGNotificationViewChainMessages object:nil];
        [notificationCenter addObserver:self selector:@selector(viewedChainMessagesForChain:) name:AGNotificationViewedChainMessagesForChain object:nil];
        [notificationCenter addObserver:self selector:@selector(viewingChainMessagesForChain:) name:AGNotificationViewingChainMessagesForChain object:nil];
        //
        chainMessageMutex = [NSNumber numberWithBool:YES];
        getNeoChainMutex = [NSNumber numberWithBool:YES];
        getChainsMutex = [NSNumber numberWithBool:YES];
        receiveChainMutex = [NSNumber numberWithBool:YES];
        obtainChainMutex = [NSNumber numberWithBool:YES];
        viewChainMessageMutex = [NSNumber numberWithBool:YES];
        
    }
    return self;
}

-(void)reset
{
    //chain messages
    moreChainMessages = NO;
    obtainingChainMessages = NO;
    //get new chain
    moreGetNeoChains = NO;
    gettingNeoChains = NO;
    //get new chain
    moreGetChains = NO;
    gettingChains = NO;
    //receive chain
    moreReceiveChains = NO;
    receivingChains = NO;
    //obtain chain
    moreObtainChains = NO;
    obtainingChains = NO;
    //
    viewingChainId = nil;
}

- (void) getNeoChains:(NSNotification*) notification
{
    NSNumber *number = [notification.userInfo objectForKey:@"updateInc"];
    NSNumber * maxUpdateInc = [[AGControllerUtils controllerUtils].chainController recentUpdateInc];
    if (number && number.longLongValue <= maxUpdateInc.longLongValue) {//notified
        return;
    }
    BOOL shouldGet = NO;
    @synchronized(getNeoChainMutex){
        if (gettingNeoChains) {
            moreGetNeoChains = YES;
        }
        else{
            gettingNeoChains = YES;
            shouldGet = YES;
        }
    }
    
    if (shouldGet) {
        [self getNeoChains];
    }
    
}

- (void) getNeoChains
{
    NSNumber * start = [[AGControllerUtils controllerUtils].chainController recentUpdateInc];
    AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
    NSDictionary * params = [chainManager paramsForGetNeoChains:start];
    [chainManager getNeoChains:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *chains) {
        if (error == nil) {
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue) {
                [self getNeoChains];
            }
            else{
                //whether has more
                BOOL shouldGet = NO;
                @synchronized(getNeoChainMutex){
                    if (moreGetNeoChains) {
                        moreGetNeoChains = NO;
                        shouldGet = YES;
                    }
                    else{
                        gettingNeoChains = NO;
                    }
                }
                if (shouldGet) {
                    [self getNeoChains];
                }
                else{
                    [self refreshed];
                }
            }
            [self gotNeoChains];
        }
        else{
            //should deal with server error
            @synchronized(getNeoChainMutex){
                moreGetNeoChains = NO;
                gettingNeoChains = NO;
            }
            [self refreshed];
        }
    }];
}

- (void) gotNeoChains
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
    @synchronized(getChainsMutex){
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
    NSArray *neoChainIds = [controllerUtils.chainController getNeoChainIdsForUpdate];
    if (neoChainIds.count) {
        [self getChainsForNeoChainIds:neoChainIds];
    }
    else{
        @synchronized(getChainsMutex){
            moreGetChains = NO;
            gettingChains = NO;
        }
        //
        NSDictionary *dict = [NSDictionary dictionary];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:AGNotificationObtainChainMessages object:self userInfo:dict];
    }
}

- (void) getChainsForNeoChainIds:(NSArray*)neoChainIds
{
    AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
    NSDictionary *params = [chainManager paramsForGetChains:neoChainIds];
    [chainManager getChains:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *chains) {
        if (error == nil) {
            [self getChains];
        }
        else{
            //should deal with server error
            @synchronized(getNeoChainMutex){
                moreGetNeoChains = NO;
                gettingNeoChains = NO;
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
                [[AGControllerUtils controllerUtils].chainController addNeoChains:chains];
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
                [[AGControllerUtils controllerUtils].chainController addNeoChains:chains];
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
    AGNeoChain *neoChain = [controllerUtils.chainController getNextNeoChainForChainMessage];
    if (neoChain) {
        [self obtainChainMessagesForChain:neoChain];
    }
    else{
        @synchronized(chainMessageMutex){
            moreChainMessages = NO;
            obtainingChainMessages = NO;
        }
    }
}

- (void) obtainChainMessagesForChain:(AGNeoChain*)neoChain
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
    AGChain *chain = neoChain.chain;
    NSNumber *oldUpdateInc = neoChain.updateInc;
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
                [self obtainChainMessagesForChain:neoChain];
            }
            else{
                [controllerUtils.chainController removeNeoChain:neoChain oldUpdateInc:oldUpdateInc];
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
                dict = [NSDictionary dictionaryWithObjectsAndKeys:chain, @"chain", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewedChainMessagesForChain object:nil userInfo:dict];
            }
            else{
                [[AGControllerUtils controllerUtils].chainMessageController updateChainMessagesCount:chainMessage chain:chain];
                //
                dict = [NSDictionary dictionaryWithObjectsAndKeys:chain.chainId, @"chainId",@"YES", @"NoObtained", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadChainMessagesChangedForChain object:nil userInfo:dict];
            }
            dict = [NSDictionary dictionary];
            [notificationCenter postNotificationName:AGNotificationObtainedChains object:self userInfo:dict];
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

- (void) viewChainMessages:(NSNotification*) notification
{
    BOOL shouldView = NO;
    @synchronized(viewChainMessageMutex){
        if (viewingChainMessages) {
            moreViewChainMessages = YES;
        }
        else{
            viewingChainMessages = YES;
            shouldView = YES;
        }
    }
    
    if (shouldView) {
        [self viewChainMessages];
    }
    
}

- (void) viewChainMessages
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGChainMessage *chainMessage = [controllerUtils.chainMessageController getNextUnviewedChainMessage];
    if (chainMessage) {
        [self viewChainMessage:chainMessage];
    }
    else{
        @synchronized(viewChainMessageMutex){
            moreViewChainMessages = NO;
            viewingChainMessages = NO;
        }
    }
}

- (void) viewChainMessage:(AGChainMessage*) chainMessage
{
    AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
    NSDictionary *params = [chainManager paramsForViewedChainMessages:chainMessage.chain.chainId last:chainMessage.mineLastTime];
    NSDate *mineLastTime = chainMessage.mineLastTime;
    [chainManager viewedChainMessages:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            //should deal with server error
            @synchronized(viewChainMessageMutex){
                moreViewChainMessages = NO;
                viewingChainMessages = NO;
            }
        }
        else{
            NSString *lastViewedTimeJson = [result objectForKey:@"lastViewedTime"];
            NSDate *lastViewedTime = nil;
            if (lastViewedTimeJson) {
                lastViewedTime = [AGUtils stringToDate:lastViewedTimeJson];
            }
            else{
                lastViewedTime = mineLastTime;
            }
            [[AGControllerUtils controllerUtils].chainController updateLastViewedTime:lastViewedTime chain:chainMessage.chain];
            [self viewChainMessages];
        }
    }];
    
    
}

- (void)viewedChainMessagesForChain:(NSNotification*)notification
{
    AGChain *chain = [notification.userInfo objectForKey:@"chain"];
    NSDate *last = [[AGControllerUtils controllerUtils].chainMessageController viewedChainMessagesForChain:chain];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:chain.chainId, @"chainId", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadChainMessagesChangedForChain object:nil userInfo:dict];
    //
    if (last) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewChainMessages object:nil userInfo:dict];
    }
    
}

- (void) viewingChainMessagesForChain:(NSNotification*)notification
{
    AGChain *chain = [notification.userInfo objectForKey:@"chain"];
    viewingChainId = chain.chainId;
}

@end
