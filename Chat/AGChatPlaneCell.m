//
//  AGChatPlaneCell.m
//  Airogami
//
//  Created by Tianhu Yang on 7/3/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatPlaneCell.h"
#import "CustomBadge.h"

@interface AGChatPlaneCell()
{
    CustomBadge *customBadge;
}
@end

@implementation AGChatPlaneCell

@synthesize badge;

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

- (void) setBadge:(NSString *)aBadge
{
    badge = aBadge;
    if (customBadge == nil) {
        customBadge = [CustomBadge customBadgeWithString:badge
                                         withStringColor:[UIColor whiteColor]
                                          withInsetColor:[UIColor redColor]
                                          withBadgeFrame:YES
                                     withBadgeFrameColor:[UIColor whiteColor]
                                               withScale:.8f
                                             withShining:YES];
        [self addSubview:customBadge];
    }
    else{
        customBadge.badgeText = badge;
    }
    
    if (badge.length == 0) {
        customBadge.hidden = YES;
    }
    else
    {
        customBadge.hidden = NO;
        CGRect frame = customBadge.frame;
        CGRect outer = self.profileImageView.frame;
        frame.origin.y = outer.origin.y - 5;
        frame.origin.x = outer.origin.x + outer.size.width - frame.size.width + 5;
        customBadge.frame = frame;
    }
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
