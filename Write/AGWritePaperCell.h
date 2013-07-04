//
//  AGWritePaperCell.h
//  Airogami
//
//  Created by Tianhu Yang on 7/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AGWritePaperCellDelegate <NSObject>

@required

- (void) didSelectRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface AGWritePaperCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIButton *titleButton;
@property(nonatomic, weak) IBOutlet id<AGWritePaperCellDelegate> delegate;
@end
