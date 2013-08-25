//
//  AGUIUtils.h
//  Airogami
//
//  Created by Tianhu Yang on 6/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGDefines.h"

#define AGLS(string) NSLocalizedString(string, string)

typedef enum  {
    AGThemeFontStyleMedium = 0,
    AGThemeFontStyleBlack = 1,
    AGThemeFontStyleHeavy = 2
} AGThemeFontStyle;

@interface AGUIUtils : NSObject
+ (void) initialize;
+ (void) buttonImageNormalToHighlight:(UIButton*)button;
+ (void) buttonBackgroundImageNormalToHighlight:(UIButton*)button;
+ (UIImage*) planeImage:(int) category;
+ (UIImage*) categoryImage:(AGPlaneCategoryEnum) category;
+ (UIImage*) collectTypeImage:(AGCollectType) type;
+ (UIFont*) themeFont:(AGThemeFontStyle) style size:(float)size;
+ (void) setBackButtonTitle:(UIViewController*)viewController;
+ (UIActionSheet*) actionSheetForPickImages:(id<UIActionSheetDelegate>)delegate view:(UIView*)view;

@end
