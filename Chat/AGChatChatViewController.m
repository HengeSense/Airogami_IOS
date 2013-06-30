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

#define kAGChatChatMessageMaxLength 200

@interface AGChatChatViewController()
{
    __weak IBOutlet UIBubbleTableView *bubbleTable;
    __weak IBOutlet UIView *textInputView;
    __weak IBOutlet UITextView *inputTextView;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIView *viewContainer;
    __weak IBOutlet AGResignButton *resignButton;
    
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
    //UIButton *button = [[AGResignButton alloc] initWithFrame:viewContainer.frame];
    //[viewContainer addSubview:button];
    //viewContainer
    //bubbleTable.backgroundView = button;
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
    
    
    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    
    [bubbleTable reloadData];
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
    if ([text isEqualToString:@"\n"]) {
        [self send];
        aTextView.text = @"";
        [self relayout];
        [aTextView resignFirstResponder];
        return NO;
    }
    NSUInteger newLength = [aTextView.text length] + [text length] - range.length;
    BOOL should = newLength <= kAGChatChatMessageMaxLength;
    return should;
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
    if (text.length != textView.text.length) {
        textView.text = text;
    }
    
    [self relayout];
}

- (void) relayout
{
    CGRect textFrame = inputTextView.frame;
    CGRect frame;
    CGSize size = inputTextView.contentSize;
    float diff = size.height - textFrame.size.height;
    CGPoint point = CGPointZero;
    if (diff != 0.0f) {
        //viewContainer
        point = inputTextView.superview.frame.origin;
        point.y += size.height + textFrame.origin.y * 2;
        frame = viewContainer.frame;
        frame.origin.y = frame.origin.y + frame.size.height - point.y;
        frame.size.height = point.y;
        viewContainer.frame = frame;
        //superview
        frame = inputTextView.superview.frame;
        frame.size.height = size.height + textFrame.origin.y * 2;
        inputTextView.superview.frame = frame;
        //inputTextView
        textFrame.size = size;
        inputTextView.frame = textFrame;
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

#pragma mark - logic

-(void) send
{
    
}

- (void)viewDidUnload {
    resignButton = nil;
    [super viewDidUnload];
}
@end
