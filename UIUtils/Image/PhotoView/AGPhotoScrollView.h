//
//  AGImageScrollView.h
//  Airogami
//
//  Created by Tianhu Yang on 10/31/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AGPhotoScrollViewDelegate <NSObject>

-(void) dismiss;

@end

@interface AGPhotoScrollView : UIScrollView

@property(nonatomic, weak) id<AGPhotoScrollViewDelegate> photoScrollViewDelegate;

@end
