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
NSString *AGNotificationObtainAccount = @"notification.obtainAccount";
NSString *AGNotificationProfileChanged = @"notification.profileChanged";
NSString *AGNotificationGetPoints = @"notification.getpoints";
NSString *AGNotificationGotPoints = @"notification.gotpoints";

@interface AGAccountNotification()
{
    //chain messages
    BOOL moreAccounts;
    NSNumber *accountsMutex;
    BOOL obtainingAccounts;
}

@end

@implementation AGAccountNotification

- (id) init
{
    if (self = [super init]) {
        accountsMutex = [NSNumber numberWithBool:YES];
        //
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(obtainAccounts:) name:AGNotificationObtainAccounts object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainAccount:) name:AGNotificationObtainAccount object:nil];
        [notificationCenter addObserver:self selector:@selector(gotPoints) name:AGNotificationGetPoints object:nil];
    }
    return self;
}

-(void) reset
{
    moreAccounts = NO;
    obtainingAccounts = NO;
}

+(AGAccountNotification*) accountNotification
{
    static AGAccountNotification *accountNotification;
    if (accountNotification == nil) {
        accountNotification = [[AGAccountNotification alloc] init];
    }
    return accountNotification;
}

- (void) obtainAccount:(NSNotification*) notification
{
    AGAccount *account = [notification.userInfo objectForKey:@"account"];
    [[AGControllerUtils controllerUtils].accountController addNeoAccount:account];
    [self obtainAccounts:notification];
}

- (void) obtainAccounts:(NSNotification*) notification
{
    BOOL shouldObtain = NO;
    @synchronized(accountsMutex){
        if (obtainingAccounts) {
            moreAccounts = YES;
        }
        else{
            obtainingAccounts = YES;
            shouldObtain = YES;
        }
    }
    
    if (shouldObtain) {
        [self obtainAccounts];
    }
}


- (void) obtainAccounts
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGNeoAccount *neoAccount = [controllerUtils.accountController getNextNeoAccount];
    if (neoAccount) {
        [self obtainProfilesForAccount:neoAccount];
    }
    else{
        @synchronized(accountsMutex){
            moreAccounts = NO;
            obtainingAccounts = NO;
        }
    }
}

- (void) obtainProfilesForAccount:(AGNeoAccount*)neoAccount
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    NSNumber *oldUpdateCount = neoAccount.updateCount;
    AGProfile *profile = neoAccount.account.profile;
    NSNumber *updateCount = profile.updateCount;
    NSDictionary *params = [managerUtils.profileManager paramsForObtainProfile:neoAccount.accountId updateCount:updateCount];
    
    [managerUtils.profileManager obtainProfile:params context:nil block:^(NSError *error, id context, BOOL succeed) {
        if (error == nil) {
            NSNumber *accountId = neoAccount.accountId;
            [controllerUtils.accountController removeNeoAccount:neoAccount oldUpdateCount:oldUpdateCount];
            //
            if (succeed) {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:accountId forKey:@"accountId"];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AGNotificationObtainedPlanes object:self userInfo:dict];
                [notificationCenter postNotificationName:AGNotificationProfileChanged object:self userInfo:dict];
            }
            
            //
            [self obtainAccounts];
        }
        else{
            //should deal with server error
            @synchronized(accountsMutex){
                moreAccounts = NO;
                obtainingAccounts = NO;
            }
        }
    }];
}

-(void) gotPoints
{
    AGHot *hot = [AGAppDirector appDirector].account.hot;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:hot.likesCount forKey:@"likesCount"];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGotPoints object:self userInfo:dict];
}

-(void) increaseLikesCount:(int) count
{
    [[AGControllerUtils controllerUtils].accountController increaseCount:count];
    [self gotPoints];
}


@end
