//
//  AGChatKeyboard.h
//  Airogami
//
//  Created by Tianhu Yang on 6/29/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGCollectKeyboardScroll : NSObject
+ (void)initialize;
+ (void) clear;
+ (void) setView:(UIView *)aView scrollView:(UIScrollView*)scrollView;
@end
