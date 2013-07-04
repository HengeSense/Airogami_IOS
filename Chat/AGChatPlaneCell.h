//
//  AGChatPlaneCell.h
//  Airogami
//
//  Created by Tianhu Yang on 7/3/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGProfileImage.h"

@interface AGChatPlaneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AGProfileImage *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
