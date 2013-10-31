//
//  AGAccountManager.h
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGAccount.h"
#import "AGAccount+Addition.h"
#import "AGProfile.h"
#import "AGDefines.h"


typedef void (^AGAccountSigninDoneBlock)(NSError *error, BOOL succeed);
typedef void (^AGAccountSignupDoneBlock)(BOOL succeed);

@interface AGAccountManager : NSObject

- (void) signup:(NSDictionary*) params image:(UIImage*)image block:(AGAccountSignupDoneBlock)block;

- (void) signin:(NSDictionary*) params automatic:(BOOL)yes animated:(BOOL)animated context:(id)context block:(AGAccountSigninDoneBlock)block;

- (void) obtainTokens:(NSDictionary *)params context:(id)context block:(AGHttpFinishBlock)block;

- (void) changePassword:(NSDictionary *)params context:(id)context block:(AGHttpSucceedBlock)block;

- (void) changeScreenName:(NSDictionary *)params context:(id)context block:(AGHttpSucceedBlock)block;

- (NSDictionary*) paramsForChangePassword:(NSString*)oldPassword newPassword:(NSString*)newPassword;

- (NSDictionary*) paramsForChangeScreenName:(NSString*)screenName;

-(void) signout:(id)context block:(AGHttpDoneBlock)block ;

- (void) updateDevice;
//Kickoff autoSignin
- (void) autoSignin:(id)context block:(AGHttpDoneBlock)block;
- (void) autoSignin:(NSDictionary*)reqDict;

@end
