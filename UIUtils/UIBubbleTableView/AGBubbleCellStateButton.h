//
//  AGBubbleCellStateButton.h
//  Airogami
//
//  Created by Tianhu Yang on 7/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSBubbleData.h"

@interface AGBubbleCellStateButton : UIButton
@property(nonatomic, assign) NSBubbleCellState cellState;

- (void) likeReceived;
@end
