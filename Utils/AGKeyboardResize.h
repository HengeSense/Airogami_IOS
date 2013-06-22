//
//  AGKeyboardResize.h
//  Airogami
//
//  Created by Tianhu Yang on 6/20/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGKeyboardResize : NSObject
+ (void)initialize;
+ (void) clear;
+ (void) setScrollView:(UIScrollView*) scrollView view:(UIView *)rootView;
@end
