//
//  AGCollectPlaneNumberView.h
//  Airogami
//
//  Created by Tianhu Yang on 7/3/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGCollectPlaneNumberView : UIView

@property(nonatomic, strong) UILabel *numberLabel;

+ (AGCollectPlaneNumberView*) numberView:(UIView*)superview;

@end
