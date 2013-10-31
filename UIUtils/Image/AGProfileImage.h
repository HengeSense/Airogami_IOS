//
//  SCNProfileImage.h
//  Scoutin
//
//  Created by Tianhu Yang on 5/7/13.
//  Copyright (c) 2013 Tianhu Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGAccount+Addition.h"

@interface AGProfileImage : UIImageView

- (void) setImageWithAccount:(AGAccount*)account;

@end
