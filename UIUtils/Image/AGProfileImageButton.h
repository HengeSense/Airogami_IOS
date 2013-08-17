//
//  AGProfileImageButton.h
//  Airogami
//
//  Created by Tianhu Yang on 6/10/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGImageButton.h"


@interface AGProfileImageButton : AGImageButton

@property(nonatomic, strong) NSURL *mediumUrl;

- (void) setImageWithAccountId:(NSNumber *)accountId;

@end
