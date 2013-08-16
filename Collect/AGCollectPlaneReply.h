//
//  AGCollectPlaneReplyView.h
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGProfileImageButton.h"

@interface AGCollectPlaneReply : NSObject

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;


@property (strong, nonatomic) IBOutlet UIView *replyView;

@property (weak, nonatomic) IBOutlet AGProfileImageButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (void) show:(id)object;

+ (id) reply;

@end
