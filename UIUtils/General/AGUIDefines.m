//
//  AGUIDefines.m
//  Airogami
//
//  Created by Tianhu Yang on 6/17/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGUIDefines.h"

static UIColor*  NavigationBackHighlightColor;
static UIColor*  NavigationDoneHighlightColor;

static NSString * Main_Background_Image = @"main_bgrd.png";
static NSString * SexButtonImageMale = @"write_edit_male_button.png";
static NSString * SexButtonImageFemale = @"write_edit_female_button.png";
static NSString * SexSymbolImageMale = @"male_symbol.png";
static NSString * SexSymbolImageFemale = @"female_symbol.png";
static NSString * ProfileDefaultImage = @"profile_image_default.png";

NSString * const Normal_Done_Highlight = @"normal_done_highlight.png";
NSString * const Navigation_Back_Button_Highlight = @"back_button_highlight.png";
NSString * const Navigation_Done_Button_Highlight = @"done_button_highlight.png";
NSString * AGLocationViewControllerLocationKey = @"location";
NSString * AGAccountUploadingIcons = @"message.account.operate.uploadingicons";

@implementation AGUIDefines

+ (void) initialize
{
    NavigationDoneHighlightColor = [UIColor colorWithRed:15 / 255.0f green:147 / 255.0f  blue:68 / 255.0f  alpha:1.0f];
    NavigationBackHighlightColor = [UIColor colorWithRed:2 / 255.0f green:113 / 255.0f  blue:196 / 255.0f  alpha:1.0f];
}

+ (UIImage*) mainBackgroundImage
{
    return [UIImage imageNamed:Main_Background_Image];
}

+ (UIColor*) navigationBackHighlightColor
{
    return NavigationBackHighlightColor;
}

+ (UIColor*) navigationDoneHighlightColor
{
    return NavigationDoneHighlightColor;
}

+ (void) setNavigationBackButton:(UIButton*)button
{
    [button setBackgroundImage:[UIImage imageNamed:Navigation_Back_Button_Highlight] forState:UIControlStateHighlighted];
    [button setTitleColor:NavigationBackHighlightColor forState:UIControlStateHighlighted];
    //button.titleLabel.adjustsFontSizeToFitWidth = YES;
}

+ (void) setNavigationDoneButton:(UIButton*)button
{
    [button setBackgroundImage:[UIImage imageNamed:Navigation_Done_Button_Highlight] forState:UIControlStateHighlighted];
    [button setTitleColor:NavigationDoneHighlightColor forState:UIControlStateHighlighted];
}

+ (void) setNormalDoneButton:(UIButton*)button
{
    [button setBackgroundImage:[UIImage imageNamed:Normal_Done_Highlight] forState:UIControlStateHighlighted];
    [button setTitleColor:NavigationDoneHighlightColor forState:UIControlStateHighlighted];
}

+ (UIImage*) sexButtonImage:(BOOL)male
{
    NSString *name;
    if (male) {
        name = SexButtonImageMale;
    }
    else{
        name = SexButtonImageFemale;
    }
    return [UIImage imageNamed:name];
}

+ (UIImage*) sexSymbolImage:(BOOL)male
{
    NSString *name;
    if (male) {
        name = SexSymbolImageMale;
    }
    else{
        name = SexSymbolImageFemale;
    }
    return [UIImage imageNamed:name];
}
+ (UIImage*) profileDefaultImage
{
    return [UIImage imageNamed:ProfileDefaultImage];
}

@end
