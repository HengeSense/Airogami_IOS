//
//  AGLikeButton.h
//  Airogami
//
//  Created by Tianhu Yang on 10/22/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGLikeButton : UIButton

@property(nonatomic, assign) BOOL liked;

- (void) likeAnimate;

@end
