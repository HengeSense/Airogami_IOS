//
//  AGAccountManager.h
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AGAccountSignDoneBlock)();

@interface AGAccountManager : NSObject

- (void) signup:(NSMutableDictionary*) params image:(UIImage*)image block:(AGAccountSignDoneBlock)block;

- (void) signin:(NSMutableDictionary*) params isEmail:(BOOL)isEmail block:(AGAccountSignDoneBlock)block;

- (void) signout;

@end
