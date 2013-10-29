//
//  AGNotificationCenter.m
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGNotificationCenter.h"
#import "AGControllerUtils.h"
#import "AGUtils.h"
#import "AGManagerUtils.h"
#import "AGAccountStat.h"
#import "AGAppDirector.h"

NSString *AGNotificationUpdateDate = @"notification.updatedate";

NSString *AGNotificationRefreshed = @"notification.refreshed";
NSString *AGNotificationRefresh = @"notification.refresh";

NSString *AGNotificationCollected = @"notification.collected";
NSString *AGNotificationReceive = @"notification.receive";
NSString *AGNotificationGetCollected = @"notification.getcollected";

NSString *AGNotificationObtained = @"notification.obtained";
NSString *AGNotificationObtain = @"notification.obtain";
NSString *AGNotificationGetObtained = @"notification.getobtained";
NSString *AGNotificationGetUnreadMessagesCount = @"notification.getUnreadMessagesCount";
NSString *AGNotificationGotUnreadMessagesCount = @"notification.gotUnreadMessagesCount";

@interface AGNotificationCenter()
{
    NSArray *planesForCollect;
    NSArray *chainsForCollect;
    NSArray *planesForChat;
    NSArray *chainsForChat;
    BOOL planeRefreshed, chainRefreshed;
}

@end

@implementation AGNotificationCenter

+(void) initialize
{
    [AGNotificationCenter notificationCenter];
}

+ (AGNotificationCenter*) notificationCenter
{
    static AGNotificationCenter *notificationCenter;
    if (notificationCenter == nil) {
        notificationCenter = [[AGNotificationCenter alloc] init];
        //maybe redundent
        [AGPlaneNotification planeNotification];
        [AGChainNotification chainNotification];
        [AGAccountNotification accountNotification];
        [AGMessageNotification messageNotification];
    }
    return notificationCenter;
}

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        //refresh
        [notificationCenter addObserver:self selector:@selector(refresh:) name:AGNotificationRefresh object:nil];
        [notificationCenter addObserver:self selector:@selector(refreshed:) name:AGNotificationPlaneRefreshed object:nil];
        [notificationCenter addObserver:self selector:@selector(refreshed:) name:AGNotificationChainRefreshed object:nil];
        //collect
        [notificationCenter addObserver:self selector:@selector(collectedPlanes:) name:AGNotificationCollectedPlanes object:nil];
        [notificationCenter addObserver:self selector:@selector(collectedChains:) name:AGNotificationCollectedChains object:nil];
        [notificationCenter addObserver:self selector:@selector(getCollected:) name:AGNotificationGetCollected object:nil];
        //obtain planes
        [notificationCenter addObserver:self selector:@selector(obtainedPlanes:) name:AGNotificationObtainedPlanes object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainedChains:) name:AGNotificationObtainedChains object:nil];
        [notificationCenter addObserver:self selector:@selector(getObtained:) name:AGNotificationGetObtained object:nil];
        //unread messages changed
        [notificationCenter addObserver:self selector:@selector(unreadMessagesChanged:) name:AGNotificationUnreadMessagesChangedForPlane object:nil];
        [notificationCenter addObserver:self selector:@selector(unreadMessagesChanged:) name:AGNotificationUnreadChainMessagesChangedForChain object:nil];
        [notificationCenter addObserver:self selector:@selector(getUnreadMessagesCount:) name:AGNotificationGetUnreadMessagesCount object:nil];
        //
        [self startUpdateDate];
    }
    return self;
}

- (void) collectedPlanes:(NSNotification*) notification
{
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqual:@"one"]) {
        [self collected:notification.userInfo];
    }
    else{
        [self collectedContainPlanes:YES containChains:NO];
    }
}

- (void) collectedChains:(NSNotification*) notification
{
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqual:@"one"]) {
        [self collected:notification.userInfo];
    }
    else{
        [self collectedContainPlanes:NO containChains:YES];
    }
    
}

- (void) getCollected:(NSNotification*)notification
{
    NSString *containPlanes = [notification.userInfo objectForKey:@"planes"];
    NSString *containChains = [notification.userInfo objectForKey:@"chains"];
    
    [self collectedContainPlanes:containPlanes != nil containChains:containChains != nil];
}

- (void) collected:(NSDictionary*)dict
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollected object:self userInfo:dict];
}

- (void) collectedContainPlanes:(BOOL) containPlanes containChains:(BOOL)containChains
{
    if (containPlanes) {
        planesForCollect = [[AGControllerUtils controllerUtils].planeController getAllPlanesForCollect];
    }
    if (containChains) {
        chainsForCollect = [[AGControllerUtils controllerUtils].chainController getAllChainsForCollect];
    }
    NSArray *collects = [AGUtils mergeSortedArray:planesForCollect second:chainsForCollect usingBlock:^int(id obj1, id obj2) {
        AGPlane *plane = obj1;
        AGChain *chain = obj2;
        return [plane.updatedTime compare:chain.updatedTime];
    }];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:collects, @"collects", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationCollected object:self userInfo:dict];
}


- (void) obtainedPlanes:(NSNotification*) notification
{
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqual:@"one"]) {
        [self obtained:notification.userInfo];
#ifdef IS_DEBUG
        NSLog(@"obtainedPlanes(one)");
#endif
    }
    else if ([action isEqual:@"reorder"]){
#ifdef IS_DEBUG
        NSLog(@"obtainedPlanes(reorder)");
#endif
        NSNumber *planeId = [notification.userInfo objectForKey:@"planeId"];
        assert(planeId);
        [self reorderPlanesForChat:planeId];
        [self obtainedContainPlanes:NO containChains:NO];
    }
    else{
        [self obtainedContainPlanes:YES containChains:NO];
#ifdef IS_DEBUG
        NSLog(@"obtainedPlanes");
#endif
    }
    
}

- (void) reorderPlanesForChat:(NSNumber*)planeId
{
    int loc = -1;
    AGPlane *plane = nil;
    for (int i = 0; i < planesForChat.count; ++i) {
        AGPlane *pp = [planesForChat objectAtIndex:i];
        if ([pp.planeId isEqual:planeId]) {
            plane = pp;
            loc = i;
            break;
        }
    }
    if (loc != -1) {
        NSMutableArray *planes = [planesForChat mutableCopy];
        for (; loc > 0; --loc) {
            AGPlane *pp = [planes objectAtIndex:loc - 1];
            if ([pp.updatedTime compare:plane.updatedTime] < 0) {
                [planes replaceObjectAtIndex:loc withObject:pp];
                [planes replaceObjectAtIndex:loc - 1 withObject:plane];
            }
        }
        planesForChat = planes;
    }
}


- (void) obtainedChains:(NSNotification*) notification
{
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqual:@"one"]) {
        [self obtained:notification.userInfo];
#ifdef IS_DEBUG
        NSLog(@"obtainedChains(one)");
#endif
    }
    else{
        [self obtainedContainPlanes:NO containChains:YES];
#ifdef IS_DEBUG
        NSLog(@"obtainedChains");
#endif
    }
    
}

- (void) getObtained:(NSNotification*)notification
{
    NSString *containPlanes = [notification.userInfo objectForKey:@"planes"];
    NSString *containChains = [notification.userInfo objectForKey:@"chains"];
    
    [self obtainedContainPlanes:containPlanes != nil containChains:containChains != nil];
}

- (void) obtained:(NSDictionary*)dict
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtained object:self userInfo:dict];
}

- (void) obtainedContainPlanes:(BOOL) containPlanes containChains:(BOOL)containChains
{
    if (containPlanes) {
        planesForChat = [[AGControllerUtils controllerUtils].planeController getAllPlanesForChat];
    }
    if (containChains) {
        chainsForChat = [[AGControllerUtils controllerUtils].chainController getAllChainsForChat];
    }
    NSArray *chats = [AGUtils mergeSortedArray:planesForChat second:chainsForChat usingBlock:^int(id obj1, id obj2) {
        AGPlane *plane = obj1;
        AGChain *chain = obj2;
        return [plane.updatedTime compare:chain.updatedTime];
    }];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:chats, @"chats", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtained object:self userInfo:dict];
}

- (void) refresh:(NSNotification*)notification
{
    [self obtainPlanesAndChains];
}

- (void) refreshed:(NSNotification*)notification
{
    NSString *source = [notification.userInfo objectForKey:@"source"];
    if ([source isEqualToString:@"plane"]) {
        planeRefreshed = YES;
    }
    else if ([source isEqualToString:@"chain"]){
        chainRefreshed = YES;
    }
    if (planeRefreshed && chainRefreshed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationRefreshed object:self userInfo:nil];
    }
}

- (void) startUpdateDate
{
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(updateDateTick:) userInfo:nil repeats:YES];
}

- (void) updateDateTick:(NSTimer*)timer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationUpdateDate object:self];
}

- (void) obtainPlanesAndChains
{
    /*[[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainPlanes object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationReceivePlanes object:nil userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainChains object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationReceiveChains object:nil userInfo:nil];*/
    
    planeRefreshed = chainRefreshed = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetNeoPlanes object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetNeoChains object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainAccounts object:self userInfo:nil];
}

//should run once open the program
- (void) obtainMessages
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationObtainMessages object:self userInfo:dict];
    [notificationCenter postNotificationName:AGNotificationObtainChainMessages object:self userInfo:dict];
}

//should run once the program is active
- (void) resendMessages
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationSendMessages object:self userInfo:dict];
}

//should run once the program is active
- (void) viewedMessages
{
    NSDictionary *dict = [NSDictionary dictionary];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationViewMessages object:self userInfo:dict];
    [notificationCenter postNotificationName:AGNotificationViewChainMessages object:self userInfo:dict];
}

- (void)unreadMessagesChanged:(NSNotification*)notification
{
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    NSNumber *number = [NSNumber numberWithInt:accountStat.unreadMessagesCount.intValue + accountStat.unreadChainMessagesCount.intValue];
    NSMutableDictionary *dict = [notification.userInfo mutableCopy];
    [dict setObject:number forKey:@"count"];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationGotUnreadMessagesCount object:self userInfo:dict];
    //
    [dict setObject:@"reorder" forKey:@"action"];
    NSNumber *planeId = [dict objectForKey:@"planeId"];
    NSNumber *chainId = [dict objectForKey:@"chainId"];
    if (planeId) {
        [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
    }
    else if(chainId){
        NSString *noObtained = [dict objectForKey:@"NoObtained"];
        if (noObtained == nil) {
            [notificationCenter postNotificationName:AGNotificationObtainedChains object:self userInfo:dict];
        }
    
    }

}

- (void)getUnreadMessagesCount:(NSNotification*)notification
{
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    NSNumber *number = [NSNumber numberWithInt:accountStat.unreadMessagesCount.intValue + accountStat.unreadChainMessagesCount.intValue];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:number, @"count", nil];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:AGNotificationGotUnreadMessagesCount object:self userInfo:dict];
}

-(void)reset
{
    planesForChat = planesForCollect = chainsForChat = chainsForCollect = nil;
    [[AGAccountNotification accountNotification] reset];
    [[AGPlaneNotification planeNotification] reset];
    [[AGChainNotification chainNotification] reset];
    [[AGMessageNotification messageNotification] reset];
}

- (void) kickoff
{
    [self obtainPlanesAndChains];
    [self resendMessages];
    [self viewedMessages];
}


@end
