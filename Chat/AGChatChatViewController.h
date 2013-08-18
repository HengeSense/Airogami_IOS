//
//  AGChatChatViewController.h
//  Airogami
//
//  Created by Tianhu Yang on 6/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGPlane.h"
#import "UIBubbleTableViewDataSource.h"

@interface AGChatChatViewController : UIViewController<UIBubbleTableViewDataSource, UITextViewDelegate>

@property(nonatomic, strong) id airogami;

@end
