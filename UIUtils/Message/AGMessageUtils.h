//
//  AGMessageUtils.h
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGMessageUtils : NSObject

+ (void) alertMessageWithTitle:(NSString *)title message:(NSString *)msg;
+ (void) alertMessageWithTitle:(NSString *)title error:(NSError *)error;
+ (void) errorMessgeWithTitle:(NSString*) title view:(UIView*)view;
+ (void) modifiedAlertMessage:(id<UIAlertViewDelegate>)delegate;
+ (void) updatedAlertMessage;
+ (void) errorMessageHttpRequest:(NSError*)error;
+ (void) errorMessageServer;
+ (NSError*) errorServer:(int)code key:(NSString*)key;
@end
