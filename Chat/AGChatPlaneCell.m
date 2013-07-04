//
//  AGChatPlaneCell.m
//  Airogami
//
//  Created by Tianhu Yang on 7/3/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatPlaneCell.h"

@implementation AGChatPlaneCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:220 / 255.0f green:236 / 255.0f blue:249 / 255.0f alpha:1.0f];
    self.selectedBackgroundView = selectionColor;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initialize];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
