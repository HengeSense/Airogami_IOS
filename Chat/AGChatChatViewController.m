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
#import "AGAppDirector.h"
#import "AGMessageUtils.h"
#import "AGLikeButton.h"
#import "AGPlane+Addition.h"
#import "AGImagePicker.h"
#import <QuartzCore/QuartzCore.h>

#define kAGChatChatMessageMaxLength AGAccountMessageContentMaxLength
#define kAGChatChatMaxSpacing 50

static float AGInputTextViewMaxHeight = 100;
static NSString * ClearConfirm = @"message.ui.clear.confirm";
static NSString * OK = @"message.general.ok";
static NSString * Cancel = @"message.general.cancel";
static NSString * ResendConfirm = @"title.ui.chat.resend.confirm";

static NSString * LikedByOthersImage = @"chat_chat_liked_others.png";
static NSString * LikedByMeImage = @"chat_chat_liked_mine.png";
static int ResendTag = 1;

@interface AGChatChatViewController()<UIAlertViewDelegate, UIActionSheetDelegate, AGImagePickerDelegate>
{
    __weak IBOutlet UIBubbleTableView *bubbleTable;
    __weak IBOutlet UIView *textInputView;
    __weak IBOutlet UITextView *inputTextView;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIView *viewContainer;
    __weak IBOutlet AGResignButton *resignButton;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *categoryLabel;
    __weak IBOutlet UIButton *clearButton;
    __weak IBOutlet AGLikeButton *likeButton;
    UITextView *aidedTextView;
    
    NSMutableArray *messagesData;
    
    NSBubbleData *selectedBubbleData;
    
    BOOL didInitialized;
    AGImagePicker *imagePicker;
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
    textInputView.backgroundColor = [UIColor colorWithRed:0 green:16 / 255.0f  blue:22 / 255.0f alpha:.9f];
    aidedTextView.layer.cornerRadius = inputTextView.layer.cornerRadius = 5.0f;
    //aidedTextView.layer.borderColor = inputTextView.layer.borderColor = [UIColor blackColor].CGColor;
    //aidedTextView.layer.borderWidth = inputTextView.layer.borderWidth = 2.0f;
    //
    if ([airogami isKindOfClass:[AGChain class]]){
        textInputView.hidden = YES;
    }
    else{
        aidedTextView.text = @"test";
        //
        CGRect frame = inputTextView.frame;
        CGSize size = [aidedTextView sizeThatFits:frame.size];
        frame.size.height = size.height;
        inputTextView.frame = frame;
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
        AGAccount *account = [AGAppDirector appDirector].account;
        if ([account.accountId isEqual:plane.accountByOwnerId.accountId]) {
            nameLabel.text = plane.accountByTargetId.profile.fullName;
        }
        else{
            nameLabel.text = plane.accountByOwnerId.profile.fullName;
        }
        categoryLabel.text = [AGCategory title:plane.category.categoryId];
        likeButton.liked = [plane hasLiked];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotMessagesForPlane:) name:AGNotificationGotMessagesForPlane object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentMessage:) name:AGNotificationSentMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readMessagesForPlane:) name:AGNotificationReadMessagesForPlane object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(planeRemoved:) name:AGNotificationPlaneRemoved object:nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:plane forKey:@"plane"];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewedMessagesForPlane object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewingMessagesForPlane object:nil userInfo:dict];
    }
    else if ([airogami isKindOfClass:[AGChain class]]){
        AGChain *chain = airogami;
        nameLabel.text = chain.account.profile.fullName;
        categoryLabel.text = [AGCategory title:[NSNumber numberWithInt:AGCategoryChain]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotChainMessagesForChain:) name:AGNotificationGotChainMessagesForChain object:nil];
        //
        NSDictionary *dict = [NSDictionary dictionaryWithObject:chain forKey:@"chain"];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewingChainMessagesForChain object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewedChainMessagesForChain object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewingChainMessagesForChain object:nil userInfo:dict];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidUnload {
    resignButton = nil;
    nameLabel = nil;
    categoryLabel = nil;
    [super viewDidUnload];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([airogami isKindOfClass:[AGPlane class]]) {
        NSDictionary *dict = [NSDictionary dictionary];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewingMessagesForPlane object:nil userInfo:dict];
    }
    else if([airogami isKindOfClass:[AGChain class]]){
        NSDictionary *dict = [NSDictionary dictionary];
        [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewingChainMessagesForChain object:nil userInfo:dict];
    }
}

- (void) loadMore
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

- (void) readMessagesForPlane:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSNumber *planeId = [dict objectForKey:@"planeId"];
    AGPlane *plane = airogami;
    if ([planeId isEqual:plane.planeId] == NO) {
        return;
    }
    //
    for (NSBubbleData *bubbleData in messagesData) {
        AGMessage *message = bubbleData.obj;
        if (message.state.intValue == AGSendStateSent) {
            if (message.messageId.longLongValue <= message.plane.lastMsgId.longLongValue) {
                bubbleData.state = AGSendStateRead;
            }
        }
        else{
            bubbleData.state = message.state.intValue;
        }
    }
    [bubbleTable refresh:[NSArray arrayWithObject:@"state"]];
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
    if (messages.count == 0 && [action isEqual:@"reset"] == NO) {
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
    AGAccount * account = [AGAppDirector appDirector].account;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (AGMessage *message in messages) {
        NSBubbleType bubbleType = BubbleTypeMine;
        if (account != message.account) {
            bubbleType = BubbleTypeSomeoneElse;
        }
        NSBubbleData *bubbleData = nil;
        if (message.type.intValue == AGMessageTypeLike) {
            NSString *name = bubbleType == BubbleTypeMine ? LikedByMeImage : LikedByOthersImage;
            bubbleData = [NSBubbleData dataWithImage:[UIImage imageNamed:name] date:message.createdTime type:bubbleType];
        }
        else{
            bubbleData = [NSBubbleData dataWithText:message.content date:message.createdTime type:bubbleType];
        }
        
        bubbleData.account = message.account;
        if (message.state.intValue == AGSendStateSent) {
            if (message.messageId.longLongValue <= message.plane.lastMsgId.longLongValue) {
                bubbleData.state = AGSendStateRead;
            }
        }
        else{
            bubbleData.state = message.state.intValue;
        }
        bubbleData.obj = message;
        [array addObject:bubbleData];
    }
    UIBubbleTableSetDataActionEnum setDataAction = UIBubbleTableSetDataActionReset;
    if ([action isEqual:@"reset"]) {
        [messagesData removeAllObjects];
        setDataAction = UIBubbleTableSetDataActionReset;
    }
    else if ([action isEqual:@"append"]){
        setDataAction = UIBubbleTableSetDataActionAppend;
    }
    else if ([action isEqual:@"prepend"]){
        setDataAction = UIBubbleTableSetDataActionPrepend;
    }
    if (setDataAction == UIBubbleTableSetDataActionAppend) {
        [messagesData addObjectsFromArray:array];
        [bubbleTable setData:setDataAction animated:didInitialized];
    }
    else{
        [array addObjectsFromArray:messagesData];
        messagesData = array;
        [bubbleTable setData:setDataAction animated:NO];
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
    AGAccount * account = [AGAppDirector appDirector].account;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (AGMessage *chainMessage in chainMessages) {
        NSBubbleType bubbleType = BubbleTypeMine;
        if (account != chainMessage.account) {
            bubbleType = BubbleTypeSomeoneElse;
        }
        NSBubbleData *bubbleData = [NSBubbleData dataWithText:chainMessage.content date:chainMessage.createdTime type:bubbleType];
        bubbleData.account = chainMessage.account;
        bubbleData.state = AGSendStateNone;
        bubbleData.obj = chainMessage;
        [array addObject:bubbleData];
    }
    UIBubbleTableSetDataActionEnum setDataAction = UIBubbleTableSetDataActionReset;
    if ([action isEqual:@"reset"]) {
        [messagesData removeAllObjects];
        setDataAction = UIBubbleTableSetDataActionReset;
    }
    else if ([action isEqual:@"append"]){
        setDataAction = UIBubbleTableSetDataActionAppend;
    }
    else if ([action isEqual:@"prepend"]){
        setDataAction = UIBubbleTableSetDataActionPrepend;
    }
    if (setDataAction == UIBubbleTableSetDataActionAppend) {
        [messagesData addObjectsFromArray:array];
        [bubbleTable setData:setDataAction animated:didInitialized];
    }
    else{
        [array addObjectsFromArray:messagesData];
        messagesData = array;
        [bubbleTable setData:setDataAction animated:NO];
        
    }
    
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
    CGRect frame;
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
        //[UIView beginAnimations:@"RelayoutAnimations" context:nil];
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
        //[UIView commitAnimations];
        //
        
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
    UIActionSheet *actionSheet = nil;
    switch (type) {
        case UIBubbleCellSelectAvatar:
            [self performSegueWithIdentifier:@"ToProfile" sender:self];
            break;
        case UIBubbleCellSelectSendFailed:
            //
            actionSheet = [[UIActionSheet alloc] initWithTitle:AGLS(ResendConfirm) delegate:self cancelButtonTitle:AGLS(Cancel) destructiveButtonTitle:nil otherButtonTitles:AGLS(OK), nil];
            actionSheet.tag = ResendTag;
            [actionSheet showInView:self.view];
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
    sayBubble.account = [AGAppDirector appDirector].account;
    sayBubble.state = message.state.intValue;
    sayBubble.obj = message;
    [messagesData addObject:sayBubble];
    [bubbleTable setData:UIBubbleTableSetDataActionAppend animated:didInitialized];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationSendMessages object:nil userInfo:nil];
    
}

-(void) planeRemoved:(NSNotification*)notification
{
    AGPlane *plane = [notification.userInfo objectForKey:@"plane"];
    if ([plane isEqual:airogami]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [AGMessageUtils alertMessagePlaneChanged];
    }
    
}

-(void) sentMessage:(NSNotification*)notification
{
    AGPlane *plane = [notification.userInfo objectForKey:@"plane"];
    if ([plane isEqual:airogami]) {
        AGMessage *message = [notification.userInfo objectForKey:@"message"];
        AGMessage *remoteMessage = [notification.userInfo objectForKey:@"remoteMessage"];
        
        if (message) {
            for (NSBubbleData *bubbleData in messagesData) {
                AGMessage *msg = bubbleData.obj;
                if ([msg isEqual:message]) {
                    if(remoteMessage){
                        bubbleData.state = remoteMessage.state.shortValue;
                        bubbleData.date = remoteMessage.createdTime;
                        bubbleData.obj = remoteMessage;
                        [bubbleTable setData:UIBubbleTableSetDataActionReset animated:NO];
                        //
                        [[AGManagerUtils managerUtils].audioManager playSentMessage];
                    }
                    else{
                        bubbleData.state = message.state.shortValue;
                        [bubbleTable refresh:[NSArray arrayWithObject:@"state"]];
                    }
                    
                    break;
                }
            }
        }
    }

}

//resend confirm and image picker
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ResendTag) {
        if (buttonIndex == 0) {
            [[AGMessageNotification messageNotification] resendMessage:selectedBubbleData.obj];
            selectedBubbleData.state = AGSendStateSending;
            [bubbleTable refresh:[NSArray arrayWithObject:@"state"]];
        }
    }
    else{
        imagePicker = [[AGImagePicker alloc] init];
        imagePicker.delegate = self;
        switch (buttonIndex) {
            case 0:
                [imagePicker pick:self type:AGImagePickerType_Camera];
                break;
            case 1:
                [imagePicker pick:self type:AGImagePickerType_Library];
                break;
            default:
                break;
        }
    }
   
}

//clear confirm
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self clear];
    }
}

- (void) clear
{
    clearButton.enabled = NO;
    [[AGManagerUtils managerUtils].planeManager clearPlane:airogami context:nil block:^(NSError *error, id context, BOOL succeed) {
        clearButton.enabled = YES;
    }];
}

- (void) imagePicker:(AGImagePicker *)imagePicker_ didFinish:(BOOL)finished image:(UIImage *)image
{
    if (finished) {
        
    }
    imagePicker = nil;
}

#pragma mark - buttons

- (IBAction)backButton:(UIButton *)sender {
    [AGChatKeyboardScroll clear];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)likeButton:(AGLikeButton *)sender {
    [sender likeAnimate];
    sender.enabled = NO;
    [[AGManagerUtils managerUtils].planeManager likePlane:airogami context:nil block:^(NSError *error, id context, BOOL succeed) {
        sender.enabled = YES;
        AGPlane *plane = airogami;
        sender.liked = [plane hasLiked];
    }];
}

- (IBAction)clearButton:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:AGLS(ClearConfirm) delegate:self cancelButtonTitle:AGLS(Cancel) otherButtonTitles:AGLS(OK), nil];
    [alert show];
}

- (IBAction)addImage:(UIButton *)sender {
    [AGUIUtils actionSheetForPickImages:self view:self.view];
}

@end
