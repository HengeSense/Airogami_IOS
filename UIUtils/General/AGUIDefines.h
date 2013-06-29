//
//  AGUIDefines.h
//  Airogami
//
//  Created by Tianhu Yang on 6/17/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const Normal_Done_Highlight;
extern NSString * const Navigation_Back_Button_Highlight;

extern NSString * const Navigation_Done_Button_Highlight;

@interface AGUIDefines : NSObject
+ (void) initialize;
+ (UIImage*) mainBackgroundImage;
+ (UIColor*) navigationBackHighlightColor;
+ (UIColor*) navigationDoneHighlightColor;
+ (void) setNavigationBackButton:(UIButton*)button;
+ (void) setNavigationDoneButton:(UIButton*)button;
+ (void) setNormalDoneButton:(UIButton*)button;

@end
