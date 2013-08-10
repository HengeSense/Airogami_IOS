//
//  AGAccountManager.h
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGAccount.h"
#import "AGProfile.h"

typedef void (^AGAccountSigninDoneBlock)(NSError *error, BOOL succeed);
typedef void (^AGAccountSignupDoneBlock)(BOOL succeed);

@interface AGAccountManager : NSObject

@property(nonatomic, strong) AGAccount *account;

- (void) signup:(NSMutableDictionary*) params image:(UIImage*)image block:(AGAccountSignupDoneBlock)block;

- (void) signin:(NSMutableDictionary*) params automatic:(BOOL)yes animated:(BOOL)animated context:(id)context block:(AGAccountSigninDoneBlock)block;

- (void) signout;

- (void) autoSignin;

@end
