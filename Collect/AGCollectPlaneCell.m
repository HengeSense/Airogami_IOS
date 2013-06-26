//
//  AGCollectPlaneCell.m
//  Airogami
//
//  Created by Tianhu Yang on 6/25/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCollectPlaneCell.h"
#import "AGUIUtils.h"
#import "AYUIButton.h"

@interface AGCollectPlaneCell()



@end

@implementation AGCollectPlaneCell

@synthesize category;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self.aidedButton setBackgroundColor:self.aidedButton.backgroundColor forState:UIControlStateNormal];
    [self.aidedButton setBackgroundColor:[UIColor colorWithRed:220 / 255.0f green:236 / 255.0f blue:249 / 255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    
}


- (IBAction)aidedButtonTouched:(UIButton *)button {
    UITableView *tableView = (UITableView *) self.superview;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:button.tag inSection:0];
    [tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionNone];
    [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setCategory:(int)aCategory
{
    category = aCategory;
    self.planeImageView.image = [AGUIUtils planeImage:category];
    self.categoryImageView.image = [AGUIUtils categoryImage:category];
}

@end