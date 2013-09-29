//
//  AGAccountStat.h
//  Airogami
//
//  Created by Tianhu Yang on 9/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount;

@interface AGAccountStat : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSNumber * chainUpdateInc;
@property (nonatomic, retain) NSNumber * planeUpdateInc;
@property (nonatomic, retain) NSNumber * signinCount;
@property (nonatomic, retain) NSNumber * unreadChainMessagesCount;
@property (nonatomic, retain) NSNumber * unreadMessagesCount;
@property (nonatomic, retain) NSNumber * synchronizing;
@property (nonatomic, retain) AGAccount *account;

@end
