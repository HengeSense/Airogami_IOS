//
//  AGBubbleTableViewDelegate.h
//  Airogami
//
//  Created by Tianhu Yang on 7/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    UIBubbleCellSelectAvatar,
    UIBubbleCellSelectSendFailed,
    UIBubbleCellSelectReceivedLike
}UIBubbleTableViewCellSelectType;

@class UIBubbleTableView;

@protocol AGBubbleTableViewDelegate <NSObject>

- (void)bubbleTableView:(UIBubbleTableView *)tableView didSelectCellAtIndexPath:(NSIndexPath*) indexPath type:(UIBubbleTableViewCellSelectType) type;

@end
