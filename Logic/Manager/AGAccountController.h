//
//  AGCoreDataManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGCoreData.h"
#import "AGAccount.h"
#import "AGProfile.h"
#import "AGPlane.h"
#import "AGNewAccount.h"

@interface AGAccountController : NSObject

- (AGAccount*) saveAccount:(NSDictionary*)jsonDictionary;
- (AGAccountStat*) saveAccountStat:(NSDictionary*)jsonDictionary;
- (AGProfile *) saveProfile:(NSDictionary*)jsonDictionary;
- (AGAccountStat*) findAccountStat:(NSNumber *)accountId;
- (AGAccount*) findAccount:(NSNumber*)accountId;
- (void) addNewAccounts:(NSArray *)accounts;
- (void) addNewAccount:(AGAccount *)account;
- (AGNewAccount*) getNextNewAccount;
- (void) removeNewAccount:(AGNewAccount *)newAccount oldUpdateCount:(NSNumber*)updateCount;
- (int) getUnreadMessagesCount;
- (void) setSynchronizing:(BOOL)sychronizing;

@end
