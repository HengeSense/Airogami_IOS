//
//  AGWriteEditViewAnimation.h
//  Airogami
//
//  Created by Tianhu Yang on 6/24/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGWriteEditViewAnimation : NSObject
- (id) initWithView:(UIView*) view;
- (void) expand:(CGPoint)point;
- (void) fold:(CGPoint)point;
- (void) toggle:(CGPoint)point;
@end
