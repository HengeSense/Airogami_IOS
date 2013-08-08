//
//  AGImageButton.h
//  Airogami
//
//  Created by Tianhu Yang on 7/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGImageButton : UIButton

- (void) initialize;

- (void) setImageUrl:(NSURL*)url placeImage:(UIImage*)image;

@end
