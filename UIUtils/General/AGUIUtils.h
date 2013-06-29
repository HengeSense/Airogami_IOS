//
//  AGUIUtils.h
//  Airogami
//
//  Created by Tianhu Yang on 6/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGDefines.h"

@interface AGUIUtils : NSObject
+ (void) alertMessageWithTitle:(NSString *)title message:(NSString *)msg;
+ (void) alertMessageWithTitle:(NSString *)title error:(NSError *)error;
+ (void) errorMessgeWithTitle:(NSString*) title view:(UIView*)view;
+ (void) buttonImageNormalToHighlight:(UIButton*)button;
+ (void) buttonBackgroundImageNormalToHighlight:(UIButton*)button;
+ (UIImage*) planeImage:(int) category;
+ (UIImage*) categoryImage:(AGCategory) category;
+ (UIImage*) collectTypeImage:(AGCollectType) type;
@end
