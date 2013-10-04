//
//  UIActionSheet+ButtonEnable.m
//  Airogami
//
//  Created by Tianhu Yang on 8/24/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "UIActionSheet+ButtonEnable.h"

@implementation UIActionSheet (ButtonEnable)

- (void)setButton:(NSInteger)buttonIndex enabled:(BOOL)enabled {
    for (UIView* view in self.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            if (buttonIndex == 0) {
                if ([view respondsToSelector:@selector(setEnabled:)])
                {
                    UIButton* button = (UIButton*)view;
                    button.enabled = enabled;
                }
            }
            buttonIndex--;
        }
    }
}

@end
