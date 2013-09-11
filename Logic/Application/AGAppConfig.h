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
@property(nonatomic, assign) int appVersion;
@property(nonatomic, strong) AGAppAccount *appAccount;

- (void) save;
- (void) updateAppAccount:(AGAccount*)account password:(NSString*)password;
- (void) updatePassword:(NSString*)password;
- (void) resetAppAccount;
- (BOOL) needSignin;
- (BOOL) accountUpdated:(AGAccount*)account;
- (void) gotoMain;
- (void) gotoSign;
- (NSMutableDictionary*) siginParams;

@end
