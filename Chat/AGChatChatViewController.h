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
#import "NSBubbleData.h"
#import "AGNotificationCenter.h"
#import "AGMessage.h"
#import "AGManagerUtils.h"
#import "AGPlane+Addition.h"
#import "UIBubbleTableView.h"
#import "AGAppDirector.h"
#import "AGCategory+Addition.h"
#import "AGMessageUtils.h"
#import "SDImageCache+Addition.h"

@interface AGChatChatViewController : UIViewController<UIBubbleTableViewDataSource, UITextViewDelegate>
{
    __weak IBOutlet UIBubbleTableView *bubbleTable;
    __weak IBOutlet UIButton *clearButton;
    __weak IBOutlet UITextView *inputTextView;
    id airogami;
    NSMutableArray *messagesData;
    BOOL didInitialized;
}
@property(nonatomic, strong) id airogami;

@end
