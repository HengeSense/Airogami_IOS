//
//  AGUIUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 6/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGUIUtils.h"
#import "AGUIErrorAnimation.h"
#import "AGKeyboardScroll.h"
#import "AGKeyboardResize.h"
#import "AGChatKeyboardScroll.h"

#define kAGAlertMessageOK @"OK"

static NSString *planeImages[] = {@"plane_random.png", @"plane_question.png", @"plane_confession.png", @"plane_relationship.png", @"plane_localinfo.png", @"plane_feeling.png", @"plane_chain.png"};

static NSString *categoryImages[] = {@"plane_random_icon.png", @"plane_question_icon.png", @"plane_confession_icon.png", @"plane_relationship_icon.png", @"plane_localinfo_icon.png", @"plane_feeling_icon.png", @"plane_chain_icon.png"};

static NSString *collectTypeImages[] = {@"collect_receive_tag.png", @"collect_found_tag.png"};

@implementation AGUIUtils

+ (void) initialize
{
    [AGKeyboardScroll initialize];
    [AGKeyboardResize initialize];
    [AGChatKeyboardScroll initialize];
    [AGUIDefines initialize];
}

+ (void) alertMessageWithTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = NSLocalizedString(title, title);
    alert.message = NSLocalizedString(msg, msg);
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
    [alert show];
}

+ (void) alertMessageWithTitle:(NSString *)title error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = NSLocalizedString(title, title);
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
    [alert show];
}

+ (void) errorMessgeWithTitle:(NSString*) title view:(UIView *)view
{
    [AGUIErrorAnimation startWithTitle:NSLocalizedString(title, title) view:view];
    
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
    if (category > AGCategoryChain) {
        category = AGCategoryRandom;
    }
    return [UIImage imageNamed:planeImages[category]];
}
+ (UIImage*) categoryImage:(AGCategory) category
{
    if (category > AGCategoryChain) {
        category = AGCategoryRandom;
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

@end
