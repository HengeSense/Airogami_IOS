//
//  AGAccountManager.h
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGAccountManager : NSObject

- (void) signup:(NSMutableDictionary*) params image:(UIImage*)image;

- (void) signin:(NSMutableDictionary*) params isEmail:(BOOL)isEmail;

@end
