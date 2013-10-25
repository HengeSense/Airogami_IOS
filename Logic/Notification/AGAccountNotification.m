//
//  AGAccountNotification.m
//  Airogami
//
//  Created by Tianhu Yang on 9/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAccountNotification.h"
#import "AGControllerUtils.h"
#import "AGManagerUtils.h"
#import "AGPlaneNotification.h"
#import "AGAppDirector.h"

NSString *AGNotificationObtainAccounts = @"notification.obtainAccounts";
NSString *AGNotificationObtainProfiles = @"notification.obtainProfiles";
NSString *AGNotificationObtainHots = @"notification.obtainHots";
NSString *AGNotificationProfileChanged = @"notification.profileChanged";
NSString *AGNotificationHotChanged = @"notification.hotChanged";
NSString *AGNotificationGetPoints = @"notification.getpoints";
NSString *AGNotificationGotPoints = @"notification.gotpoints";

@interface AGAccountNotification()
{
    //hots
    NSNumber *hotsMutex;
    BOOL obtainingHots;
    //profiles
    NSNumber *profilesMutex;
    BOOL obtainingProfiles;
    //
}

@end

@implementation AGAccountNotification

- (id) init
{
    if (self = [super init]) {
        hotsMutex = [NSNumber numberWithBool:YES];
        profilesMutex = [NSNumber numberWithBool:YES];
        //
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(obtainAccounts:) name:AGNotificationObtainAccounts object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainProfiles:) name:AGNotificationObtainProfiles object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainHots:) name:AGNotificationObtainHots object:nil];
        [notificationCenter addObserver:self selector:@selector(gotPoints) name:AGNotificationGetPoints object:nil];
    }
    return self;
}

-(void) reset
{
    obtainingHots = NO;
    obtainingProfiles = NO;
}

+(AGAccountNotification*) accountNotification
{
    static AGAccountNotification *accountNotification;
    if (accountNotification == nil) {
        accountNotification = [[AGAccountNotification alloc] init];
    }
    return accountNotification;
}

- (void) obtainAccounts:(NSNotification*) notification
{
    [self obtainProfiles:notification];
    [self obtainHots:notification];
}

- (void) obtainAccountsForAccounts:(NSArray*)accounts
{
    if (accounts.count) {
        NSMutableArray *accountIds = [NSMutableArray arrayWithCapacity:accounts.count];
        for (AGAccount *account in accounts) {
            [accountIds addObject:account.accountId];
        }
        NSDictionary *dict = [NSDictionary dictionaryWithObject:accountIds forKey:@"accountIds"];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainAccounts object:self userInfo:dict];
    }
}

#pragma mark - profiles

- (void) obtainProfiles:(NSNotification*) notification
{
    NSArray *accountIds = [notification.userInfo objectForKey:@"accountIds"];
    AGAccountController *accountController = [AGControllerUtils controllerUtils].accountController;
    [accountController addNeoProfiles:accountIds];
    //
    BOOL shouldObtain = NO;
    @synchronized(profilesMutex){
        if (obtainingProfiles) {
        }
        else{
            obtainingProfiles = YES;
            shouldObtain = YES;
        }
    }
    
    if (shouldObtain) {
        [self obtainProfiles];
    }
}


- (void) obtainProfiles
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGNeoProfile *neoProfile = [controllerUtils.accountController getNextNeoProfile];
    if (neoProfile) {
        [self obtainProfile:neoProfile];
    }
    else{
        @synchronized(profilesMutex){
            obtainingProfiles = NO;
        }
    }
}

- (void) obtainProfile:(AGNeoProfile *)neoProfile
{
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    AGProfile *profile = neoProfile.profile;
    NSNumber *updateCount = profile.updateCount;
    NSNumber *oldCount = neoProfile.count;
    NSDictionary *params = [managerUtils.profileManager paramsForObtainProfile:neoProfile.accountId updateCount:updateCount];
    //
    [managerUtils.profileManager obtainProfile:params context:nil block:^(NSError *error, id context, BOOL succeed) {
        if (error == nil) {
            //
            if (succeed) {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:neoProfile.accountId forKey:@"accountId"];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
                [notificationCenter postNotificationName:AGNotificationProfileChanged object:self userInfo:dict];
            }
            //
            [[AGControllerUtils controllerUtils].accountController removeNeoProfile:neoProfile oldCount:oldCount];
            //
            [self obtainProfiles];
        }
        else{
            //should deal with server error
            @synchronized(profilesMutex){
                obtainingProfiles = NO;
            }
        }
    }];
}

#pragma mark - hots

- (void) obtainHots:(NSNotification*) notification
{
    NSArray *accountIds = [notification.userInfo objectForKey:@"accountIds"];
    AGAccountController *accountController = [AGControllerUtils controllerUtils].accountController;
    [accountController addNeoHots:accountIds];
    //
    BOOL shouldObtain = NO;
    @synchronized(hotsMutex){
        if (obtainingHots) {

        }
        else{
            obtainingHots = YES;
            shouldObtain = YES;
        }
    }
    
    if (shouldObtain) {
        [self obtainHots];
    }
}

- (void) obtainHots
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGNeoHot *neoHot = [controllerUtils.accountController getNextNeoHot];
    if (neoHot) {
        [self obtainHot:neoHot];
    }
    else{
        @synchronized(hotsMutex){
            obtainingHots = NO;
        }
    }
}

- (void) obtainHot:(AGNeoHot *)neoHot
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    AGHot *hot = neoHot.hot;
    NSNumber *updateCount = hot.updateCount;
    NSNumber *oldCount = neoHot.count;
    NSDictionary *params = [managerUtils.profileManager paramsForObtainHot:neoHot.accountId updateCount:updateCount];
    //
    [managerUtils.profileManager obtainHot:params context:nil block:^(NSError *error, id context, BOOL succeed) {
        if (error == nil) {
            //
            if (succeed) {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:neoHot.accountId forKey:@"accountId"];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AGNotificationHotChanged object:self userInfo:dict];
                AGAccount *account = [AGAppDirector appDirector].account;
                if ([neoHot.accountId isEqualToNumber:account.accountId]) {
                    [self gotPoints];
                }
            }
            //
            [controllerUtils.accountController removeNeoHot:neoHot oldCount:oldCount];
            //
            [self obtainHots];
        }
        else{
            //should deal with server error
            @synchronized(hotsMutex){
                obtainingHots = NO;
            }
        }
    }];
}

- (void) obtainHotForMe
{
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:accountId] forKey:@"accountIds"];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainHots object:self userInfo:dict];
}

#pragma mark - points
-(void) gotPoints
{
    AGHot *hot = [AGAppDirector appDirector].account.hot;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:hot.likesCount forKey:@"likesCount"];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGotPoints object:self userInfo:dict];
}

-(void) increaseLikesCount:(int) count
{
    [[AGControllerUtils controllerUtils].accountController increaseLikesCount:count];
    [self gotPoints];
}


@end
