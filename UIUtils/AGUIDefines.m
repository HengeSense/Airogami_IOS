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

@implementation AGUIDefines

+ (void) initialize
{
    NavigationDoneHighlightColor = [UIColor colorWithRed:15 / 255.0f green:147 / 255.0f  blue:68 / 255.0f  alpha:1.0f];
    NavigationBackHighlightColor = [UIColor colorWithRed:2 / 255.0f green:113 / 255.0f  blue:196 / 255.0f  alpha:1.0f];
}

+ (UIColor*) navigationBackHighlightColor
{
    return NavigationBackHighlightColor;
}

+ (UIColor*) navigationDoneHighlightColor
{
    return NavigationDoneHighlightColor;
}
@end
