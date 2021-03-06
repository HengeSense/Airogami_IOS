//
//  AGMessageUtils.h
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

#define alertMessageChainChanged alertMessagePlaneChanged

@interface AGMessageUtils : NSObject

+ (void) alertMessageWithTitle:(NSString *)title message:(NSString *)msg;
+ (void) alertMessageWithTitle:(NSString *)title error:(NSError *)error;
+ (void) alertMessageWithError:(NSError *)error;
+ (void) alertMessageWithFilteredError:(NSError *)error;
+ (void) errorMessgeWithTitle:(NSString*) title view:(UIView*)view;
+ (void) alertMessageModified:(id<UIAlertViewDelegate>)delegate;
+ (void) alertMessageUpdated;
+ (void) alertMessagePlaneChanged;
+ (NSError*) errorCancel;
+ (NSError*) errorServer:(NSNumber*)code titleKey:(NSString*)titleKey msgKey:(NSString*)key;
+ (NSError*) errorServer;//unknown error
+ (NSError*) errorClient:(NSNumber*)number titleKey:(NSString*)titleKey msgKey:(NSString*)msgKey;
+ (NSError*) errorClient;
+ (NSError*) errorNotSignin;
@end
