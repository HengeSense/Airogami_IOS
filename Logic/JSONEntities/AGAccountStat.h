//
//  AGAccountStat.h
//  Airogami
//
//  Created by Tianhu Yang on 8/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONModel.h"

@class AGAccount;

@interface AGAccountStatJSON : JSONModel

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSDate * lastSigninTime;
@property (nonatomic, retain) AGAccount *account;

@end
