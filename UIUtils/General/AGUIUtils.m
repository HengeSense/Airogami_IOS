//
//  AGUIUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 6/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGUIUtils.h"
#import "AGKeyboardScroll.h"
#import "AGKeyboardResize.h"
#import "AGChatKeyboardScroll.h"
#import "AGCollectKeyboardScroll.h"
#import "UIActionSheet+ButtonEnable.h"

#define kAGAlertMessageOK @"OK"

static NSString *planeImages[] = {@"plane_chain.png", @"plane_random.png", @"plane_question.png", @"plane_confession.png", @"plane_relationship.png", @"plane_localinfo.png", @"plane_feeling.png", @"plane_random.png"};

static NSString *categoryImages[] = { @"plane_chain_icon.png", @"plane_random_icon.png", @"plane_question_icon.png", @"plane_confession_icon.png", @"plane_relationship_icon.png", @"plane_localinfo_icon.png", @"plane_feeling_icon.png", @"plane_unknown_icon.png"};

static NSString *collectTypeImages[] = {@"collect_receive_tag.png", @"collect_found_tag.png"};
static NSString * themeFontNames[] = {@"Avenir-Medium", @"Avenir-Black", @"Avenir-Heavy"};

@implementation AGUIUtils

+ (void) initialize
{
    [AGKeyboardScroll initialize];
    [AGKeyboardResize initialize];
    [AGChatKeyboardScroll initialize];
    [AGUIDefines initialize];
    [AGCollectKeyboardScroll initialize];
}

+ (void) buttonImageNormalToHighlight:(UIButton *)button
{
    UIImage *image = [button imageForState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateHighlighted];
}

+ (void) buttonBackgroundImageNormalToHighlight:(UIButton *)button
{
    UIImage *image = [button backgroundImageForState:UIControlStateNormal];
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
}

+ (UIImage*) planeImage:(int) category
{
    if (category > AGCategoryUnknown) {
        category = AGCategoryUnknown;
    }
    return [UIImage imageNamed:planeImages[category]];
}
+ (UIImage*) categoryImage:(AGPlaneCategoryEnum) category
{
    if (category > AGCategoryUnknown) {
        category = AGCategoryUnknown;
    }
    return [UIImage imageNamed:categoryImages[category]];
}

+ (UIImage*) collectTypeImage:(AGCollectType) type
{
    if (type > AGCollectTypePickuped) {
        type = AGCollectTypeReceived;
    }
    return [UIImage imageNamed:collectTypeImages[type]];
}

+ (UIFont*) themeFont:(AGThemeFontStyle)style size:(float)size
{
    UIFont *font = [UIFont fontWithName:themeFontNames[style] size:size];
    if (font == nil) {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}

+ (void) setBackButtonTitle:(UIViewController*)viewController
{
    NSArray *array = viewController.navigationController.childViewControllers;
    int index = array.count > 1 ? array.count - 2 : array.count - 1;
    UIViewController *vc = [array objectAtIndex:index];
    UIButton *button = (UIButton *)viewController.navigationItem.leftBarButtonItem.customView;
    [button setTitle:vc.title forState:UIControlStateNormal];
}

+(UIActionSheet*) actionSheetForPickImages:(id<UIActionSheetDelegate>)delegate view:(UIView*)view
{
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"Add Profile Picture" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Take Photo", @"Choose From Library", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    BOOL available = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    [sheet setButton:0 enabled:available];
    available = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    [sheet setButton:1 enabled:available];
    [sheet showInView:view];
    return sheet;
}


@end
