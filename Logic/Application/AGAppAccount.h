//
//  AGAppAccount.h
//  Airogami
//
//  Created by Tianhu Yang on 8/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGObject.h"

@interface AGAppAccount : AGObject

@property(nonatomic, strong) NSNumber *accountId;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *screenName;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSNumber *signinCount;

@end
