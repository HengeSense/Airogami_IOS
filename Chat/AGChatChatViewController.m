//
//  AGChatChatViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatChatViewController.h"
#import "UIBubbleTableView.h"
#import "AGUIErrorAnimation.h"
#import "AGChatKeyboardScroll.h"
#import "AGResignButton.h"
#import <QuartzCore/QuartzCore.h>

#define kAGChatChatMessageMaxLength 500
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
    UITextView *aidedTextView;
    
    NSMutableArray *bubbleData;
}

@end

@interface AGChatChatViewController ()

@end

@implementation AGChatChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initUI
{
    [AGUIDefines setNavigationBackButton:backButton];
    aidedTextView = [[UITextView alloc] initWithFrame:inputTextView.frame];
    aidedTextView.font = inputTextView.font;
    aidedTextView.hidden = YES;
    [textInputView addSubview:aidedTextView];
    //
    textInputView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.9f];
    aidedTextView.layer.cornerRadius = inputTextView.layer.cornerRadius = 5.0f;
    aidedTextView.layer.borderColor = inputTextView.layer.borderColor = [UIColor blackColor].CGColor;
    aidedTextView.layer.borderWidth = inputTextView.layer.borderWidth = 2.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
	
    NSBubbleData *heyBubble = [NSBubbleData dataWithText:@"Hey, halloween is soon" date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
    heyBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
    
    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:[UIImage imageNamed:@"halloween.jpg"] date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeSomeoneElse];
    photoBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
    
    NSBubbleData *replyBubble = [NSBubbleData dataWithText:@"Wow.. Really cool picture out there. iPhone 5 has really nice camera, yeah?" date:[NSDate dateWithTimeIntervalSinceNow:-5] type:BubbleTypeMine];
    replyBubble.avatar = nil;
    
    bubbleData = [[NSMutableArray alloc] initWithObjects:heyBubble, photoBubble, replyBubble, nil];
    
    
    bubbleTable.snapInterval = 120;
    
    
    bubbleTable.showAvatars = YES;
    
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    [bubbleTable reloadData];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    textInputView.autoresizingMask = UIViewAutoresizingNone;
    bubbleTable.autoresizingMask = UIViewAutoresizingNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - UIBubbleTableViewDelegate

- (void)bubbleTableView:(UIBubbleTableView *)tableView didSelectCellAtIndexPath:(NSIndexPath*) indexPath type:(UIBubbleTableViewCellSelectType) type
{
    
}

#pragma mark - logic

-(void) send
{
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:inputTextView.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
    sayBubble.state = BubbleCellStateReceivedUnliked;
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadToBottom];
}

- (void)viewDidUnload {
    resignButton = nil;
    [super viewDidUnload];
}
@end
