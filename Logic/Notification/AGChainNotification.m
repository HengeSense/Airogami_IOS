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
NSString *AGNotificationGetCollectedChains = @"notification.getcollectedchains";

NSString *AGNotificationObtainedChains = @"notification.obtainedchains";
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
    //updates
    BOOL moreUpdates;
    NSNumber *updateMutex;
    BOOL gettingUpdates;
    //chain messages
    /*BOOL moreChainMessages;
    NSNumber *chainMessageMutex;
    BOOL obtainingChainMessages;
    //get new chains
    BOOL moreGetNeoChains;
    NSNumber *getNeoChainMutex;
    BOOL gettingNeoChains;
    //get chains
    BOOL moreGetChains;
    NSNumber *getChainsMutex;
    BOOL gettingChains;*/
    //view chain messages
    BOOL moreViewChainMessages;
    NSNumber *viewChainMessageMutex;
    BOOL viewingChainMessages;
    //
    NSNumber *viewingChainId;
    //
    NSNumber *lastChainId;
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
        //[notificationCenter addObserver:self selector:@selector(getChains:) name:AGNotificationGetChains object:nil];
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
        /*chainMessageMutex = [NSNumber numberWithBool:YES];
        getNeoChainMutex = [NSNumber numberWithBool:YES];
        getChainsMutex = [NSNumber numberWithBool:YES];*/
        updateMutex = [NSNumber numberWithBool:YES];
        viewChainMessageMutex = [NSNumber numberWithBool:YES];
        
    }
    return self;
}

-(void)reset
{
    //chain messages
    /*moreChainMessages = NO;
    obtainingChainMessages = NO;
    //get new chain
    moreGetNeoChains = NO;
    gettingNeoChains = NO;
    //get new chain
    moreGetChains = NO;
    gettingChains = NO;*/
    //updates
    moreUpdates = NO;
    gettingUpdates = NO;
    //
    viewingChainId = nil;
}

#pragma mark - get neo chains

- (void) getNeoChains:(NSNotification*) notification
{
    NSNumber *number = [notification.userInfo objectForKey:@"updateInc"];
    NSNumber * maxUpdateInc = [[AGControllerUtils controllerUtils].chainController recentUpdateInc];
    if (number && number.longLongValue <= maxUpdateInc.longLongValue) {//notified
        return;
    }
    BOOL shouldGet = NO;
    @synchronized(updateMutex){
        if (gettingUpdates) {
            moreUpdates = YES;
        }
        else{
            gettingUpdates = YES;
            shouldGet = YES;
        }
    }
    
    if (shouldGet) {
        [self getNeoChains];
    }
    else{
        [self refreshed];
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
            }
            else{
                [self refreshed];
            }
            [self gotNeoChains];
        }
        else{
            //should deal with server error
            @synchronized(updateMutex){
                moreUpdates = NO;
                gettingUpdates = NO;
            }
            [self refreshed];
        }
    }];
}

- (void) gotNeoChains
{
    lastChainId = nil;
    [self getChains];
}

- (void)refreshed
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"chain" forKey:@"source"];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationChainRefreshed object:self userInfo:dict];
}

#pragma mark - get chains

- (void) getChains
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSArray *neoChainIds = [controllerUtils.chainController getNeoChainIdsForUpdate:lastChainId];
    if (neoChainIds.count) {
        lastChainId = neoChainIds.lastObject;
        [self getChainsForNeoChainIds:neoChainIds];
    }
    else{
        lastChainId = nil;
        [self obtainChainMessages];
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
            @synchronized(updateMutex){
                moreUpdates = NO;
                gettingUpdates = NO;
            }
        }
    }];
}


#pragma mark - obtain chain messages

// for pickup
- (void) obtainChainMessages:(NSNotification*)notification
{
    BOOL shouldGet = NO;
    @synchronized(updateMutex){
        if (gettingUpdates) {
            moreUpdates = YES;
        }
        else{
            gettingUpdates = YES;
            shouldGet = YES;
        }
    }
    
    if (shouldGet) {
        lastChainId = nil;
        [self obtainChainMessages];
    }
}

- (void) obtainChainMessages
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGNeoChain *neoChain = [controllerUtils.chainController getNextNeoChainForChainMessage:lastChainId];
    if (neoChain) {
        lastChainId = neoChain.chainId;
        [self obtainChainMessagesForChain:neoChain];
    }
    else{
        [[AGControllerUtils controllerUtils].chainController removeAllNeoChains];
        //whether has more
        BOOL shouldGet = NO;
        @synchronized(updateMutex){
            if (moreUpdates) {
                moreUpdates = NO;
                shouldGet = YES;
            }
            else{
                gettingUpdates = NO;
            }
        }
        if (shouldGet) {
            [self getNeoChains];
        }
    }
}

- (void) obtainChainMessagesForChain:(AGNeoChain*)neoChain
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
    AGChain *chain = neoChain.chain;
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
            @synchronized(updateMutex){
                moreUpdates = NO;
                gettingUpdates = NO;
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
                //
                [[AGManagerUtils managerUtils].audioManager playReceivedMessageWhenViewing];
            }
            else{
                [[AGControllerUtils controllerUtils].chainMessageController updateChainMessagesCount:chainMessage chain:chain];
                //
                dict = [NSDictionary dictionaryWithObjectsAndKeys:chain.chainId, @"chainId",@"YES", @"NoObtained", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUnreadChainMessagesChangedForChain object:nil userInfo:dict];
                //
                [[AGManagerUtils managerUtils].audioManager playReceivedMessage];
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

#pragma mark - view chain messages

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

#pragma mark - others

- (void) collectedChains
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollectedChains object:self userInfo:dict];
    
}

- (void) obtainedChains
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainedChains object:self userInfo:dict];
    
}

@end
