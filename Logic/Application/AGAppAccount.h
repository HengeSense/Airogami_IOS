//
//  AGAppAccount.h
//  Airogami
//
//  Created by Tianhu Yang on 8/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGAppAccount : NSObject

@property(nonatomic, strong) NSNumber *accountId;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *lastSigninTime;

@end
