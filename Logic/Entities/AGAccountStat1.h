//
//  AGAccountStat.h
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AGProfile1;

@interface AGAccountStat1 : NSObject

@property(nonatomic, strong) NSNumber *accountId;

@property(nonatomic, strong) AGProfile1 *account;

@property(nonatomic, strong) NSDate *lastSigninTime;

@end
