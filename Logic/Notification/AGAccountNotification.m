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

NSString *AGNotificationObtainAccounts = @"notification.obtainAccounts";
NSString *AGNotificationObtainAccount = @"notification.obtainAccount";
NSString *AGNotificationProfileChanged = @"notification.profileChanged";

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
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(obtainAccounts:) name:AGNotificationObtainAccounts object:nil];
        [notificationCenter addObserver:self selector:@selector(obtainAccount:) name:AGNotificationObtainAccount object:nil];
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
    [[AGControllerUtils controllerUtils].accountController addNewAccount:account];
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
    AGNewAccount *newAccount = [controllerUtils.accountController getNextNewAccount];
    if (newAccount) {
        [self obtainProfilesForAccount:newAccount];
    }
    else{
        @synchronized(accountsMutex){
            moreAccounts = NO;
            obtainingAccounts = NO;
        }
    }
}

- (void) obtainProfilesForAccount:(AGNewAccount*)newAccount
{
    AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    NSNumber *oldUpdateCount = newAccount.updateCount;
    NSNumber *updateCount = newAccount.account.profile.updateCount;
    NSDictionary *params = [managerUtils.profileManager paramsForObtainProfile:newAccount.accountId updateCount:updateCount];
    
    [managerUtils.profileManager obtainProfile:params context:nil block:^(NSError *error, id context, BOOL succeed) {
        if (error == nil) {
            NSNumber *accountId = newAccount.accountId;
            [controllerUtils.accountController removeNewAccount:newAccount oldUpdateCount:oldUpdateCount];
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



@end
