//
//  AGAccount.h
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AGAccountStat;

@interface AGProfile : NSObject
    
@property(nonatomic, strong) NSNumber *accountId;
    
@property(nonatomic, strong) NSString *fullName;
    
@property(nonatomic, strong) NSString *screenName;
    
@property(nonatomic, strong) NSNumber *sex;
    
@property(nonatomic, strong) NSString *icon;

@property(nonatomic, strong) NSString *shout;
    
@property(nonatomic, strong) NSNumber *longitude;
    
@property(nonatomic, strong) NSNumber *latitude;
    
@property(nonatomic, strong) NSNumber *status;
    
@property(nonatomic, strong) NSDate *createdTime;
    
@property(nonatomic, strong) NSString *city;
    
@property(nonatomic, strong) NSString *province;
    
@property(nonatomic, strong) NSString *country;
    
@property(nonatomic, strong) NSDate *birthday;
    
@property(nonatomic, strong) NSNumber *updateCount;
    
@property(nonatomic, strong) NSNumber *likesCount;
    
@property(nonatomic, strong) AGAccountStat *accountStat;

@end
