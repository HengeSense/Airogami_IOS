//
//  AGAccountStat.h
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount;

@interface AGAccountStat : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSDate * lastSigninTime;
@property (nonatomic, retain) AGAccount *account;

@end
