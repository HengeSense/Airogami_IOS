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


@interface AGAccountController()
{
    AGCoreData *coreData;
    NSEntityDescription *neoAccountEntityDescription;
}

@end


@implementation AGAccountController


-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        neoAccountEntityDescription = [NSEntityDescription entityForName:@"AGNeoAccount" inManagedObjectContext:coreData. managedObjectContext];
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
        [coreData save];
    }
    
    return profile;
}

- (AGAccountStat*) findAccountStat:(NSNumber *)accountId
{
    return (AGAccountStat*)[coreData findById:accountId withEntityName:@"AGAccountStat"];
}

- (AGAccount*) findAccount:(NSNumber*)accountId
{
    return (AGAccount*)[coreData findById:accountId withEntityName:@"AGAccount"];
}

- (void) increaseCount:(int)count
{
    AGHot *hot = [AGAppDirector appDirector].account.hot;
    hot.likesCount = [NSNumber numberWithInt:hot.likesCount.intValue + count];
    [coreData save];
}

- (void) addNeoAccounts:(NSArray *)accounts
{
    for (AGAccount *account in accounts) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        [dict setObject:account.accountId forKey:@"accountId"];
        NSNumber *number = [NSNumber numberWithInt:account.updateCount.intValue - 1];
        [dict setObject:number forKey:@"updateCount"];
        AGNeoAccount *neoAccount = (AGNeoAccount *)[coreData saveOrUpdate:dict withEntityName:@"AGNeoAccount"];
        neoAccount.account = account;
    }
    [coreData save];
}

- (void) addNeoAccount:(AGAccount *)account
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setObject:account.accountId forKey:@"accountId"];
    [dict setObject:account.updateCount forKey:@"updateCount"];
    AGNeoAccount *neoAccount = (AGNeoAccount *)[coreData saveOrUpdate:dict withEntityName:@"AGNeoAccount"];
    neoAccount.account = account;
    [coreData save];
}

- (AGNeoAccount*) getNextNeoAccount
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:neoAccountEntityDescription];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"accountId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNeoAccount *neoAccount= nil;
    if (array.count) {
        neoAccount = [array lastObject];
    }
    return neoAccount;
}

- (void) removeNeoAccount:(AGNeoAccount *)neoAccount oldUpdateCount:(NSNumber*)updateCount
{
    if (neoAccount.updateCount.longLongValue == updateCount.longLongValue) {
        [coreData remove:neoAccount];
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
