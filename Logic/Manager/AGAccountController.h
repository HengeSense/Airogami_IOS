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
#import "AGNeoProfile.h"
#import "AGNeoHot.h"

@interface AGAccountController : NSObject

- (AGAccount*) saveAccount:(NSDictionary*)jsonDictionary;
- (AGAccountStat*) saveAccountStat:(NSDictionary*)jsonDictionary;
- (AGProfile *) saveProfile:(NSDictionary*)jsonDictionary;
- (AGHot *) saveHot:(NSDictionary*)jsonDictionary;
- (AGAccountStat*) findAccountStat:(NSNumber *)accountId;
- (AGAccount*) findAccount:(NSNumber*)accountId;
- (void) increaseLikesCount:(int)count;
- (void) addNeoProfiles:(NSArray*)accountIds;
- (void) addNeoHots:(NSArray*)accountIds;
- (AGNeoProfile*) getNextNeoProfile;
- (AGNeoHot*) getNextNeoHot;
- (void) removeNeoProfile:(AGNeoProfile *)neoProfile oldCount:(NSNumber*)count;
- (void) removeNeoHot:(AGNeoHot *)neoHot oldCount:(NSNumber*)count;
- (int) getUnreadMessagesCount;
- (void) setSynchronizing:(BOOL)sychronizing;

@end
