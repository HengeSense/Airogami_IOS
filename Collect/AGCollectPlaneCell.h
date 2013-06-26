//
//  AGCollectPlaneCell.h
//  Airogami
//
//  Created by Tianhu Yang on 6/25/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AYUIButton;
@interface AGCollectPlaneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *planeImageView;

@property (weak, nonatomic) IBOutlet UIImageView *collectTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet AYUIButton *aidedButton;

@property (nonatomic, assign) int category;

@end
