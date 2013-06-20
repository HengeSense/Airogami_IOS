//
//  YTTabBarItem.h
//  Airogami
//
//  Created by Tianhu Yang on 6/17/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YTTabBarItemDelegate <NSObject>

- (void) onSelected:(int)index;

@end

@interface YTTabBarItem : UIButton
{
    int index;
}

@property(nonatomic, assign) NSObject<YTTabBarItemDelegate> *delegate;
@property(nonatomic, assign) NSString *text;

-(id) initWithFrame:(CGRect)frame index:(int)index;
-(void) setSelectedImage:(UIImage*)selectedImage unseletedImage:(UIImage*)unselectedImage;
-(void) setSelectedColor:(UIColor*)selectedColor unseletedColor:(UIColor*)unselectedColor;
@end
