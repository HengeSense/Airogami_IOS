//
//  AGAccountStat.h
//  Airogami
//
//  Created by Tianhu Yang on 9/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount;

@interface AGAccountStat : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSNumber * signinUuid;
@property (nonatomic, retain) NSNumber * unreadMessagesCount;
@property (nonatomic, retain) NSNumber * unreadChainMessagesCount;
@property (nonatomic, retain) AGAccount *account;

@end
