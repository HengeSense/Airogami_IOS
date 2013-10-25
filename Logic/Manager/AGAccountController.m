//
//  AGCoreDataManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAccountController.h"
#import "AGAppDelegate.h"
#import "AGAccountStat.h"
#import "AGManagerUtils.h"
#import "AGAppDirector.h"
#import "AGNeoProfile.h"
#import "AGNeoHot.h"


@interface AGAccountController()
{
    AGCoreData *coreData;
    NSEntityDescription *neoAccountEntityDescription;
    NSEntityDescription *neoProfileEntityDescription;
    NSEntityDescription *neoHotEntityDescription;
}

@end


@implementation AGAccountController


-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        neoAccountEntityDescription = [NSEntityDescription entityForName:@"AGNeoAccount" inManagedObjectContext:coreData. managedObjectContext];
        neoProfileEntityDescription = [NSEntityDescription entityForName:@"AGNeoProfile" inManagedObjectContext:coreData. managedObjectContext];
        neoHotEntityDescription = [NSEntityDescription entityForName:@"AGNeoHot" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}

- (AGAccount *) saveAccount:(NSDictionary*)jsonDictionary
{
    AGAccount *account = (AGAccount *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGAccount"];
    [coreData save];
    return account;
}

- (AGAccountStat *) saveAccountStat:(NSDictionary*)jsonDictionary
{
    NSMutableDictionary *dict = [jsonDictionary mutableCopy];
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    AGAccountStat *accountStat = nil;
    if (accountId) {
        [dict setObject:accountId forKey:@"accountId"];
        accountStat = (AGAccountStat *)[coreData saveOrUpdate:dict withEntityName:@"AGAccountStat"];
        [coreData save];
    }
    
    return accountStat;
}


- (AGProfile *) saveProfile:(NSDictionary*)jsonDictionary
{
    AGProfile *profile = nil;
    if (jsonDictionary == nil || [jsonDictionary isEqual:[NSNull null]]) {
        return profile;
    }
    NSNumber *accountId = [jsonDictionary objectForKey:@"accountId"];
    AGAccount *account = [self findAccount:accountId];
    if (account) {
        profile = (AGProfile *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGProfile"];
        profile.account = account;
        //
        AGNeoProfile *neoProfile = (AGNeoProfile *)[coreData findById:accountId withEntityName:@"AGNeoProfile"];
        if (neoProfile) {
            profile.neoProfile = neoProfile;
        }
        [coreData save];
    }
    
    return profile;
}

- (AGHot *) saveHot:(NSDictionary*)jsonDictionary
{
    AGHot *hot = nil;
    if (jsonDictionary == nil || [jsonDictionary isEqual:[NSNull null]]) {
        return hot;
    }
    NSNumber *accountId = [jsonDictionary objectForKey:@"accountId"];
    AGAccount *account = [self findAccount:accountId];
    if (account) {
        hot = (AGHot *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGHot"];
        hot.account = account;
        //
        AGNeoHot *neoHot = (AGNeoHot *)[coreData findById:accountId withEntityName:@"AGNeoHot"];
        if (neoHot) {
            hot.neoHot = neoHot;
        }
        [coreData save];
    }
    
    return hot;
}

- (AGAccountStat*) findAccountStat:(NSNumber *)accountId
{
    return (AGAccountStat*)[coreData findById:accountId withEntityName:@"AGAccountStat"];
}

- (AGAccount*) findAccount:(NSNumber*)accountId
{
    return (AGAccount*)[coreData findById:accountId withEntityName:@"AGAccount"];
}

- (void) increaseLikesCount:(int)count
{
    AGHot *hot = [AGAppDirector appDirector].account.hot;
    hot.likesCount = [NSNumber numberWithInt:hot.likesCount.intValue + count];
    [coreData save];
}

-(void) addNeoProfiles:(NSArray*)accountIds
{
    for (NSNumber *accountId in accountIds) {
        AGNeoProfile *neoProfile = (AGNeoProfile *)[coreData findById:accountId withEntityName:@"AGNeoProfile"];
        if (neoProfile) {
            neoProfile.count = [NSNumber numberWithInt:neoProfile.count.intValue + 1];
        }
        else{
            neoProfile = (AGNeoProfile *)[coreData create:[AGNeoProfile class]];
            neoProfile.accountId = accountId;
            
            //
            AGProfile *profile = (AGProfile *)[coreData findById:accountId withEntityName:@"AGProfile"];
            if (profile) {
                neoProfile.profile = profile;
            }
        }
    }
    [coreData save];
}

-(void) addNeoHots:(NSArray*)accountIds
{
    for (NSNumber *accountId in accountIds) {
        AGNeoHot *neoHot = (AGNeoHot *)[coreData findById:accountId withEntityName:@"AGNeoHot"];
        if (neoHot) {
            neoHot.count = [NSNumber numberWithInt:neoHot.count.intValue + 1];
        }
        else{
            neoHot = (AGNeoHot *)[coreData create:[AGNeoHot class]];
            neoHot.accountId = accountId;
            //
            AGHot *hot = (AGHot *)[coreData findById:accountId withEntityName:@"AGHot"];
            if (hot) {
                neoHot.hot = hot;
            }
        }
    }
    [coreData save];
}


- (AGNeoProfile*) getNextNeoProfile
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:neoProfileEntityDescription];
    //
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"accountId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNeoProfile *neoProfile= array.lastObject;
    return neoProfile;
}

- (AGNeoHot*) getNextNeoHot
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:neoHotEntityDescription];
    //
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"accountId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    //
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNeoHot *neoHot= array.lastObject;
    return neoHot;
}

- (void) removeNeoProfile:(AGNeoProfile *)neoProfile oldCount:(NSNumber*)count
{
    if (neoProfile.count.longLongValue == count.longLongValue) {
        [coreData remove:neoProfile];
    }
    
}

- (void) removeNeoHot:(AGNeoHot *)neoHot oldCount:(NSNumber*)count
{
    if (neoHot.count.longLongValue == count.longLongValue) {
        [coreData remove:neoHot];
    }
    
}

- (int) getUnreadMessagesCount
{
    AGAccountStat *accountStat = [AGAppDirector appDirector].account.accountStat;
    return accountStat.unreadMessagesCount.intValue + accountStat.unreadChainMessagesCount.intValue;
}

-(void) setSynchronizing:(BOOL)sychronizing
{
    AGAccount *account = [AGAppDirector appDirector].account;
    account.accountStat.synchronizing = [NSNumber numberWithBool:sychronizing];
    [coreData save];
}


@end
