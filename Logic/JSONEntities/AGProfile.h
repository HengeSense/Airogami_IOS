//
//  AGProfile.h
//  Airogami
//
//  Created by Tianhu Yang on 8/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONModel.h"

@class AGAccount;

@interface AGProfileJSON : JSONModel

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * likesCount;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * shout;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) AGAccount *account;

@end
