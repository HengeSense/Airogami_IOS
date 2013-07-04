//
//  AGWaitView.h
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGWaitView : UIView

@property(nonatomic, weak) UIImageView *imageView;

- (id) initWithName:(NSString *) name count:(int) count;
- (void) show;
- (void) dismiss;
@end
