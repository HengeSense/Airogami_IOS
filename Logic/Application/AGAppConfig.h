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
@property(nonatomic, readonly) NSString *guid;
@property(nonatomic, strong) AGAppAccount *appAccount;

- (void) save;
- (void) updateAccountId:(NSNumber*)accountId;
- (void) updateAppAccount:(AGAccount*)account password:(NSString*)password;
- (void) updatePassword:(NSString*)password;
- (void) resetAppAccount;
- (NSMutableDictionary*) autoSigninParams;

@end
