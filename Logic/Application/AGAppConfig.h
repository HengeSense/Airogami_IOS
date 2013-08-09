//
//  AGAppConfig.h
//  Airogami
//
//  Created by Tianhu Yang on 8/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGAppAccount.h"

@interface AGAppConfig : NSObject

+ (AGAppConfig*)appConfig;

@property(nonatomic, assign) BOOL once;
@property(nonatomic, strong) NSString *appVersion;
@property(nonatomic, strong) AGAppAccount *appAccount;

@end
