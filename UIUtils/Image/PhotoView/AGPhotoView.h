//
//  AGPhotoView.h
//  Airogami
//
//  Created by Tianhu Yang on 7/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPRadialProgressView.h"

@interface AGPhotoView : UIImageView <UIScrollViewDelegate>

- (void) preview:(UIImage*)image medium:(id)medium soure:(id)source;

- (void) preview:(UIImage*)sImage medium:(id)medium soure:(id)aSource text:(NSString*)text;

@end
