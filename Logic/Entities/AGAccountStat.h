//
//  AGAccountStat.h
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGAccount.h"

@interface AGAccountStat : NSObject

@property(nonatomic, strong) NSNumber *accountId;

@property(nonatomic, strong) AGAccount *account;

@property(nonatomic, strong) NSDate *lastSigninTime;

@end
