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


@interface AGAccountController()
{
    AGCoreData *coreData;
    NSEntityDescription *newAccountEntityDescription;
}

@end


@implementation AGAccountController


-(id)init
{
    if (self = [super init]) {
        coreData = [AGCoreData coreData];
        newAccountEntityDescription = [NSEntityDescription entityForName:@"AGNewAccount" inManagedObjectContext:coreData. managedObjectContext];
    }
    return self;
}

- (AGAccount *) saveAccount:(NSDictionary*)jsonDictionary
{
    AGAccount *account = (AGAccount *)[coreData saveOrUpdate:jsonDictionary withEntityName:@"AGAccount"];
    [coreData save];
    return account;
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

- (AGAccount*) findAccount:(NSNumber*)accountId
{
    return (AGAccount*)[coreData findById:accountId withEntityName:@"AGAccount"];
}

- (void) addNewAccounts:(NSArray *)accounts
{
    for (AGAccount *account in accounts) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        [dict setObject:account.accountId forKey:@"accountId"];
        NSNumber *number = [NSNumber numberWithLongLong:account.updateCount.longLongValue - 1];
        [dict setObject:number forKey:@"updateCount"];
        AGNewAccount *newAccount = (AGNewAccount *)[coreData saveOrUpdate:dict withEntityName:@"AGNewAccount"];
        newAccount.account = account;
    }
    [coreData save];
}

- (void) addNewAccount:(AGAccount *)account
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setObject:account.accountId forKey:@"accountId"];
    [dict setObject:account.updateCount forKey:@"updateCount"];
    AGNewAccount *newAccount = (AGNewAccount *)[coreData saveOrUpdate:dict withEntityName:@"AGNewAccount"];
    newAccount.account = account;
    [coreData save];
}

- (AGNewAccount*) getNextNewAccount
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:newAccountEntityDescription];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"accountId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setFetchLimit:1];
    NSError *error;
    NSArray *array = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    AGNewAccount *newAccount= nil;
    if (array.count) {
        newAccount = [array lastObject];
    }
    return newAccount;
}

- (void) removeNewAccount:(AGNewAccount *)newAccount oldUpdateCount:(NSNumber*)updateCount
{
    if (newAccount.updateCount.longLongValue == updateCount.longLongValue) {
        [coreData remove:newAccount];
    }
    
}

- (int) getUnreadMessagesCount
{
    AGAccountStat *accountStat = [AGManagerUtils managerUtils].accountManager.account.accountStat;
    return accountStat.unreadMessagesCount.intValue + accountStat.unreadChainMessagesCount.intValue;
}


@end
