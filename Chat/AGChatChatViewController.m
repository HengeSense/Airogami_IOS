//
//  AGChatChatViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatChatViewController.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "AGUIErrorAnimation.h"
#import "AGChatKeyboardScroll.h"
#import "AGResignButton.h"
#import "AGUIUtils.h"
#import "AGDefines.h"
#import "AGNotificationCenter.h"
#import "AGMessage.h"
#import "AGManagerUtils.h"
#import "AGCategory+Addition.h"
#import <QuartzCore/QuartzCore.h>

#define kAGChatChatMessageMaxLength AGAccountMessageContentMaxLength
#define kAGChatChatMaxSpacing 50

static float AGInputTextViewMaxHeight = 100;

@interface AGChatChatViewController()
{
    __weak IBOutlet UIBubbleTableView *bubbleTable;
    __weak IBOutlet UIView *textInputView;
    __weak IBOutlet UITextView *inputTextView;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIView *viewContainer;
    __weak IBOutlet AGResignButton *resignButton;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *categoryLabel;
    UITextView *aidedTextView;
    
    NSMutableArray *messagesData;
    
    NSBubbleData *selectedBubbleData;
    
    BOOL didInitialized;
}

@end

@implementation AGChatChatViewController

@synthesize airogami;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        messagesData = [NSMutableArray arrayWithCapacity:50];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    CGRect frame = bubbleTable.indicator.frame;
    frame.origin.x = bubbleTable.bounds.size.width / 2;
    bubbleTable.indicator.frame = frame;
    //bubbleTable.tableHeaderView = bubbleTable.indicator;
}

- (void) initUI
{
    [AGUIUtils setBackButtonTitle:self];
    [AGUIDefines setNavigationBackButton:backButton];
    //
    aidedTextView = [[UITextView alloc] initWithFrame:inputTextView.frame];
    aidedTextView.font = inputTextView.font;
    aidedTextView.hidden = YES;
    [textInputView addSubview:aidedTextView];
    //
    textInputView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.9f];
    aidedTextView.layer.cornerRadius = inputTextView.layer.cornerRadius = 5.0f;
    aidedTextView.layer.borderColor = inputTextView.layer.borderColor = [UIColor blackColor].CGColor;
    aidedTextView.layer.borderWidth = inputTextView.layer.borderWidth = 2.0f;
    //
    if ([airogami isKindOfClass:[AGChain class]]){
        textInputView.hidden = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
	
    /*NSBubbleData *heyBubble = [NSBubbleData dataWithText:@"Hey, halloween is soon" date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
    heyBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
    
    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:[UIImage imageNamed:@"halloween.jpg"] date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeSomeoneElse];
    photoBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
    
    NSBubbleData *replyBubble = [NSBubbleData dataWithText:@"Wow.. Really cool picture out there. iPhone 5 has really nice camera, yeah?" date:[NSDate dateWithTimeIntervalSinceNow:-5] type:BubbleTypeMine];
    replyBubble.avatar = nil;
    
    bubbleData = [[NSMutableArray alloc] initWithObjects:heyBubble, photoBubble, replyBubble, nil];
    */
    
    //bubbleTable.snapInterval = 120;
    bubbleTable.showAvatars = YES;
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    bubbleTable.refreshable = NO;
    
    [self initData];
}

- (void) initData
{
    if ([airogami isKindOfClass:[AGPlane class]]) {
        AGPlane *plane = airogami;
        AGAccount *account = [AGManagerUtils managerUtils].accountManager.account;
        if ([account.accountId isEqual:plane.accountByOwnerId.accountId]) {
            nameLabel.text = plane.accountByTargetId.profile.fullName;
        }
        else{
            nameLabel.text = plane.accountByOwnerId.profile.fullName;
        }
        categoryLabel.text = [AGCategory title:plane.category.categoryId];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotMessagesForPlane:) name:AGNotificationGotMessagesForPlane object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentMessage:) name:AGNotificationSentMessage object:nil];
    }
    else if ([airogami isKindOfClass:[AGChain class]]){
        AGChain *chain = airogami;
        nameLabel.text = chain.account.profile.fullName;
        categoryLabel.text = [AGCategory title:[NSNumber numberWithInt:AGCategoryChain]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotChainMessagesForChain:) name:AGNotificationGotChainMessagesForChain object:nil];
    }
    
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (didInitialized == NO) {
        textInputView.autoresizingMask = UIViewAutoresizingNone;
        bubbleTable.autoresizingMask = UIViewAutoresizingNone;
        //notifications
        if ([airogami isKindOfClass:[AGPlane class]]) {
            AGPlane *plane = airogami;
            NSDictionary *dict = [NSDictionary dictionaryWithObject:plane.planeId forKey:@"planeId"];
            [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetMessagesForPlane object:nil userInfo:dict];
        }
        else if([airogami isKindOfClass:[AGChain class]]){
            AGChain *chain = airogami;
            NSDictionary *dict = [NSDictionary dictionaryWithObject:chain.chainId forKey:@"chainId"];
            [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetChainMessagesForChain object:nil userInfo:dict];
        }
        didInitialized = YES;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refresh
{
    if ([airogami isKindOfClass:[AGPlane class]]) {
        AGPlane *plane = airogami;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        AGMessage *message = nil;
        if (messagesData.count) {
            NSBubbleData *bubbleData = [messagesData objectAtIndex:0];
            message = bubbleData.obj;
        }
        [dict setObject:plane.planeId forKey:@"planeId"];
        if (message.messageId > 0) {
            [dict setObject:message.messageId forKey:@"startId"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetMessagesForPlane object:nil userInfo:dict];
    }
    else if ([airogami isKindOfClass:[AGChain class]]){
        AGChain *chain = airogami;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        AGChainMessage *chainMessage = nil;
        if (messagesData.count) {
            NSBubbleData *bubbleData = [messagesData objectAtIndex:0];
            chainMessage = bubbleData.obj;
        }
        [dict setObject:chain.chainId forKey:@"chainId"];
        if (chainMessage) {
            [dict setObject:chainMessage.createdTime forKey:@"startTime"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetChainMessagesForChain object:nil userInfo:dict];
    }
    
   
}

- (void) gotMessagesForPlane:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSNumber *planeId = [dict objectForKey:@"planeId"];
    AGPlane *plane = airogami;
    if ([planeId isEqual:plane.planeId] == NO) {
        return;
    }
    //
    NSString *action = [dict objectForKey:@"action"];
    NSAssert(action != nil, @"nil action!");
    
    NSArray *messages = [dict objectForKey:@"messages"];
    if (messages.count == 0) {
        return;
    }
    NSNumber *more = [dict objectForKey:@"more"];
    if (more) {
        bubbleTable.refreshable = more.boolValue;
    }
    
    int count = messages.count;
    if ([action isEqual:@"prepend"]) {
        count += messagesData.count;
    }
    AGAccount * account = [AGManagerUtils managerUtils].accountManager.account;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (AGMessage *message in messages) {
        NSBubbleType bubbleType = BubbleTypeMine;
        if (account != message.account) {
            bubbleType = BubbleTypeSomeoneElse;
        }
        NSBubbleData *bubbleData = [NSBubbleData dataWithText:message.content date:message.createdTime type:bubbleType];
        bubbleData.account = message.account;
        bubbleData.state = message.state.intValue;
        bubbleData.obj = message;
        [array addObject:bubbleData];
    }
    BOOL add = YES;
    if ([action isEqual:@"reset"]) {
        [messagesData removeAllObjects];
        
    }
    else if ([action isEqual:@"append"]){
        
    }
    else if ([action isEqual:@"prepend"]){
        add = NO;
    }
    if (add) {
        [messagesData addObjectsFromArray:array];
        [bubbleTable addData:add animated:didInitialized];
    }
    else{
        [array addObjectsFromArray:messagesData];
        messagesData = array;
        [bubbleTable addData:add animated:NO];

    }

}

- (void) gotChainMessagesForChain:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSNumber *chainId = [dict objectForKey:@"chainId"];
    AGChain *chain = airogami;
    if ([chainId isEqual:chain.chainId] == NO) {
        return;
    }
    //
    NSString *action = [dict objectForKey:@"action"];
    NSAssert(action != nil, @"nil action!");
    
    NSArray *chainMessages = [dict objectForKey:@"chainMessages"];
    if (chainMessages.count == 0) {
        return;
    }
    NSNumber *more = [dict objectForKey:@"more"];
    if (more) {
        bubbleTable.refreshable = more.boolValue;
    }
    
    int count = chainMessages.count;
    if ([action isEqual:@"prepend"]) {
        count += messagesData.count;
    }
    AGAccount * account = [AGManagerUtils managerUtils].accountManager.account;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (AGMessage *chainMessage in chainMessages) {
        NSBubbleType bubbleType = BubbleTypeMine;
        if (account != chainMessage.account) {
            bubbleType = BubbleTypeSomeoneElse;
        }
        NSBubbleData *bubbleData = [NSBubbleData dataWithText:chainMessage.content date:chainMessage.createdTime type:bubbleType];
        bubbleData.account = chainMessage.account;
        bubbleData.state = BubbleCellStateSent;
        bubbleData.obj = chainMessage;
        [array addObject:bubbleData];
    }
    BOOL add = YES;
    if ([action isEqual:@"reset"]) {
        [messagesData removeAllObjects];
        
    }
    else if ([action isEqual:@"append"]){
        
    }
    else if ([action isEqual:@"prepend"]){
        add = NO;
    }
    if (add) {
        [messagesData addObjectsFromArray:array];
        [bubbleTable addData:add animated:didInitialized];
    }
    else{
        [array addObjectsFromArray:messagesData];
        messagesData = array;
        [bubbleTable addData:add animated:NO];
        
    }
    
}

- (IBAction)backButton:(UIButton *)sender {
    [AGChatKeyboardScroll clear];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)aTextView
{
    resignButton.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)aTextView
{
    [AGChatKeyboardScroll clear];
     resignButton.hidden = YES;
    
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //send
    if ([text isEqualToString:@"\n"] && aTextView.text.length > 0) {
        [self send];
        aTextView.text = @"";
        [self relayout];
        //[aTextView resignFirstResponder];
        return NO;
    }

    return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    [AGChatKeyboardScroll setView:viewContainer];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (text.length > kAGChatChatMessageMaxLength) {
        text = [text substringToIndex:kAGChatChatMessageMaxLength];
    }
    if (text.length != textView.text.length) {
        textView.text = text;
    }
    [self relayout];
}

- (void) relayout
{
    CGRect textFrame = inputTextView.frame;
    CGRect frame = viewContainer.frame;
    float diff = textFrame.origin.y * 2;
    CGPoint point = CGPointZero;
    aidedTextView.text = inputTextView.text;
    CGSize size = aidedTextView.contentSize;
    //inputTextView max height
    //point.x = frame.size.height + frame.origin.y - kAGChatChatMaxSpacing - diff;
    if (size.height > AGInputTextViewMaxHeight) {
        size.height = AGInputTextViewMaxHeight;
    }
    
    point.x = size.height - textFrame.size.height;
    
    if (point.x != 0.0f) {
        [UIView beginAnimations:@"RelayoutAnimations" context:nil];
        //superview
        frame = inputTextView.superview.frame;
        frame.size.height = size.height + diff;
        inputTextView.superview.frame = frame;
        //viewContainer
        point = frame.origin;
        point.y += size.height + diff;
        frame = viewContainer.frame;
        frame.origin.y = frame.origin.y + frame.size.height - point.y;
        frame.size.height = point.y;
        viewContainer.frame = frame;
        //inputTextView
        textFrame.size = size;
        inputTextView.frame = textFrame;
        inputTextView.text = aidedTextView.text;
        [UIView commitAnimations];
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"ToProfile"]) {
        [segue.destinationViewController setValue:selectedBubbleData.account forKey:@"account"];
    }
}


#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [messagesData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [messagesData objectAtIndex:row];
}

#pragma mark - UIBubbleTableViewDelegate

- (void)bubbleTableView:(UIBubbleTableView *)tableView didSelectCellAtIndexPath:(NSIndexPath*)indexPath bubbleData:(NSBubbleData*)bubbleData type:(UIBubbleTableViewCellSelectType) type
{
    selectedBubbleData = bubbleData;
    switch (type) {
        case UIBubbleCellSelectAvatar:
            [self performSegueWithIdentifier:@"ToProfile" sender:self];
            break;
            
        default:
            break;
    }
}

#pragma mark - logic

-(void) send
{
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    
    AGPlane *plane = airogami;
    AGMessage *message = [managerUtils.planeManager messageForReplyPlane:plane content:inputTextView.text type:AGMessageTypeText];
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:message.content date:message.createdTime type:BubbleTypeMine];
    sayBubble.account = managerUtils.accountManager.account;
    sayBubble.state = message.state.intValue;
    sayBubble.obj = message;
    [messagesData addObject:sayBubble];
    [bubbleTable addData:YES animated:didInitialized];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSendMessages object:nil userInfo:nil];
    //
    /*[managerUtils.planeManager replyPlane:message context:nil block:^(NSError *error, id context, AGMessage *message,BOOL refresh) {
        if (message) {
            sayBubble.state = BubbleCellStateSent;
            sayBubble.date = message.createdTime;
            [bubbleTable reloadData];
        }
        if (refresh) {
            
        }
        
    }];*/
    
}

-(void) sentMessage:(NSNotification*)notification
{
    NSString *refresh = [notification.userInfo objectForKey:@"refresh"];
    if (refresh) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        AGPlane *plane = [notification.userInfo objectForKey:@"plane"];
        if ([plane isEqual:airogami]) {
            AGMessage *message = [notification.userInfo objectForKey:@"message"];
            AGMessage *remoteMessage = [notification.userInfo objectForKey:@"remoteMessage"];
            
            if (message) {
                for (NSBubbleData *bubbleData in messagesData) {
                    AGMessage *msg = bubbleData.obj;
                    if ([msg isEqual:message]) {
                        bubbleData.state = BubbleCellStateSent;
                        bubbleData.date = remoteMessage.createdTime;
                        [bubbleTable reloadData];
                        break;
                    }
                }
            }
        }
        
    }
    
}

- (void)viewWillUnload
{
    [super viewWillUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    resignButton = nil;
    nameLabel = nil;
    categoryLabel = nil;
    [super viewDidUnload];
}
@end
