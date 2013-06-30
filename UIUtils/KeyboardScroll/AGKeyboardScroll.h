//
//  AGKeyboardScroll.h
//  Airogami
//
//  Created by Tianhu Yang on 6/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGKeyboardScroll : NSObject
+ (void)initialize;
+ (void) clear;
+ (void) setScrollView:(UIScrollView*) aScrollView view:(UIView *)aView  activeField:(UITextField *)anActiveField;
@end
