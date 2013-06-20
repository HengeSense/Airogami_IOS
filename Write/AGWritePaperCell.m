//
//  AGWritePaperCell.m
//  Airogami
//
//  Created by Tianhu Yang on 6/18/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGWritePaperCell.h"

static NSString *WritePaperCellHighlightImages[] = { @"write_paper_random_highlight",
    @"write_paper_question_highlight", @"write_paper_confession_highlight", @"write_paper_relationship_highlight", @"write_paper_feeling_highlight", @"write_paper_info_highlight",  @"write_paper_chain_highlight"
};


@implementation AGWritePaperCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setBackgroundImage:[UIImage imageNamed:WritePaperCellHighlightImages[button.tag]] forState:UIControlStateHighlighted];
            [button setTitleColor:[button titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(onButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
        }
    }
    
}

- (void) onButtonTouched:(UIButton *)button
{
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


@end
