//
//  AGAppConfig.h
//  Airogami
//
//  Created by Tianhu Yang on 8/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGAppAccount.h"
#import "AGObject.h"
#import "AGAccount.h"

@interface AGAppConfig : AGObject

+ (AGAppConfig*)appConfig;

@property(nonatomic, assign) BOOL once;
@property(nonatomic, strong) NSString *appVersion;
@property(nonatomic, strong) AGAppAccount *appAccount;
@property(nonatomic, strong) NSNumber *signinUuid;

- (void) save;
- (void) updateAppAccount:(AGAccount*)account password:(NSString*)password;
- (void) resetAppAccount;
- (BOOL) needSignin;
- (BOOL) accountUpdated:(AGAccount*)account;
- (AGAccount*) obtainAccount;
- (void) signin;
- (void) signout;
- (NSMutableDictionary*) siginParams;

@end
