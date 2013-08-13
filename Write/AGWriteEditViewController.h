//
//  AGComposeEditViewController.h
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGLocation;

@interface AGWriteEditViewController : UIViewController<UITextViewDelegate>
@property(nonatomic, strong) AGLocation *location;
@property(nonatomic, strong) NSNumber *categoryId;
@end
