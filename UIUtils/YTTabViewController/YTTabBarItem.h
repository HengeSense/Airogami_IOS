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

@interface YTTabBarItem : UIView
{
    UIImage *selectedImage;
    UIImage *unselectedImage;
    UIColor *selectedColor;
    UIColor *unselectedColor;
    UIButton *button;
    UILabel *label;
    int index;
}

@property(nonatomic, assign) NSObject<YTTabBarItemDelegate> *delegate;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic, assign) NSString *text;

-(id) initWithFrame:(CGRect)frame index:(int)index;
-(void) setSelectedImage:(UIImage*)selectedImage unseletedImage:(UIImage*)unselectedImage;
-(void) setSelectedColor:(UIColor*)selectedColor unseletedColor:(UIColor*)unselectedColor;
@end
