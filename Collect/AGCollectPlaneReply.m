//
//  AGCollectPlaneReplyView.m
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCollectPlaneReply.h"
#import <QuartzCore/QuartzCore.h>
#import "AGPlane.h"
#import "AGChain.h"
#import "AGMessage.h"
#import "AGCategory+Addition.h"
#import "AGProfile.h"
#import "AGUtils.h"
#import "AGAccount.h"
#import "AGManagerUtils.h"
#import "AGUIDefines.h"
#import "AGDefines.h"
#import "AGResignButton.h"
#import "AGCollectKeyboardScroll.h"
#import "AGControllerUtils.h"

#define kAGChatChatMessageMaxLength AGAccountMessageContentMaxLength
#define kAGChatChatMaxSpacing 50

static float AGInputTextViewMaxHeight = 80;

@interface AGCollectPlaneReply ()
{
    UITextView *aidedTextView;
    CGSize contentSize;
    __weak id airogami;
}

@property (weak, nonatomic) IBOutlet UIView *contentContainer;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *inputViewContainer;

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@property (weak, nonatomic) IBOutlet AGResignButton *resignButton;

@end

@implementation AGCollectPlaneReply

- (void) layout
{
    CGRect frame = self.descriptionTextView.frame;
    frame.size.height = self.descriptionTextView.contentSize.height;
    if (frame.size.height < 64) {
        frame.size.height = 64;
    }
    self.descriptionTextView.frame = frame;
    //
    CGPoint point;
    point.y = frame.size.height;
    point = [self.descriptionTextView convertPoint:point toView:self.scrollView];
    frame = self.contentTextView.frame;
    frame.size.height = self.contentTextView.contentSize.height;
    self.contentTextView.frame = frame;
    //
    frame = self.contentContainer.frame;
    frame.origin.y = point.y;
    point.y = self.contentTextView.frame.size.height;
    point = [self.contentTextView convertPoint:point toView:self.contentContainer];
    frame.size.height = point.y;
    self.contentContainer.frame = frame;
    //
    point.y = frame.size.height;
    point = [self.contentContainer convertPoint:point toView:self.scrollView];
    frame.size = self.scrollView.contentSize;
    frame.size.height = point.y;
    contentSize = self.scrollView.contentSize = frame.size;
}

-(void) show:(id)object
{
    [self initData: airogami = object];
    [self layout];
    self.inputTextView.text = @"";
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.replyView.alpha = 0.0f;
    [window addSubview:self.replyView];
    [UIView beginAnimations:@"ShowAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.3f];
    self.replyView.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void) initData:(id) object
{
    AGProfile *profile;
    if ([object isKindOfClass:[AGPlane class]]) {
        AGPlane *plane = object;
        profile = plane.accountByOwnerId.profile;
        self.categoryLabel.text = [AGCategory title:plane.category.categoryId];
        //
        AGMessage *message = plane.messages.objectEnumerator.nextObject;
        self.contentTextView.text = message.content;
    }
    else if ([object isKindOfClass:[AGChain class]]) {
        AGChain *chain = object;
        profile = chain.account.profile;
        self.categoryLabel.text = [AGCategory title:[NSNumber numberWithInt:AGCategoryChain]];
        NSMutableString *text = [NSMutableString stringWithCapacity:2048];
        NSArray *chainMessages = [[AGControllerUtils controllerUtils].chainMessageController getChainMessagesForChain:chain.chainId];
        for (AGChainMessage *chainMessage in chainMessages) {
            [text appendString:chainMessage.account.profile.fullName];
            [text appendString:@":\n"];
            [text appendString:chainMessage.content];
            [text appendString:@"\n\n"];
            
        }
        self.contentTextView.text = text;
    }
    self.ageLabel.text = [AGUtils birthdayToAge:profile.birthday];
    self.sexImageView.image = [AGUIDefines sexSymbolImage:profile.sex.intValue == AGAccountSexTypeMale];
    //
    [self.profileImageButton setImageWithAccountId:profile.accountId];
    //
    self.nameLabel.text = profile.fullName;
    if(profile.shout.length){
        self.descriptionTextView.text = profile.shout;
    }
    else{
        self.descriptionTextView.text = NSLocalizedString(AGAccountShoutNothing, ShoutNothing);
    }
}

- (void) dismiss
{
    [UIView beginAnimations:@"ShowAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:.3f];
    self.replyView.alpha = 0.0f;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.replyView removeFromSuperview];
}

- (IBAction)tossBack:(UIButton *)sender {
    [self throw];
}


- (IBAction)reply:(UIButton *)sender {
    //[self dismiss];
    [self.inputTextView becomeFirstResponder];
}

- (void) throw
{
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    
    if ([airogami isKindOfClass:[AGPlane class]]) {
        AGPlane *plane = airogami;
        NSDictionary *params = [managerUtils.planeManager paramsForThrowPlane:plane.planeId];
        [managerUtils.planeManager throwPlane:params plane:plane context:nil block:^(NSError *error, id context, BOOL succeed) {
            if (succeed) {
                [self dismiss];
            }
        }];
    }
    else if ([airogami isKindOfClass:[AGChain class]]) {
        AGChain *chain = airogami;
        NSDictionary *params = [managerUtils.chainManager paramsForThrowChain:chain.chainId];
        [managerUtils.chainManager throwChain:params chain:chain context:nil block:^(NSError *error, id context, BOOL succeed) {
            if (succeed) {
                [self dismiss];
            }
        }];
    }
    
}


- (void) send
{
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    
    if ([airogami isKindOfClass:[AGPlane class]]) {
        AGPlane *plane = airogami;
        NSDictionary *params = [managerUtils.planeManager paramsForReplyPlane:plane.planeId content:self.inputTextView.text type:AGMessageTypeText];
        //
        [managerUtils.planeManager firstReplyPlane:params plane:plane context:nil block:^(NSError *error, id context, BOOL succeed) {
            if (succeed) {
                [self dismiss];
            }
        }];
    }
    else if ([airogami isKindOfClass:[AGChain class]]) {
        AGChain *chain = airogami;
        NSDictionary *params = [managerUtils.chainManager paramsForReplyChain:chain.chainId content:self.inputTextView.text type:AGMessageTypeText];
        //
        [managerUtils.chainManager replyChain:params chain:chain context:nil block:^(NSError *error, id context, BOOL succeed) {
            if (succeed) {
                [self dismiss];
            }
        }];
    }
    
}

- (id)init
{
    if (self = [super init]) {
        [self initialize];
        //
        //dself.inputTextView.inputAccessoryView = self.inputViewContainer;
        aidedTextView = [[UITextView alloc] initWithFrame:self.inputTextView.frame];
        aidedTextView.font = self.inputTextView.font;
        aidedTextView.hidden = YES;
        [self.inputViewContainer addSubview:aidedTextView];
        //
        self.inputViewContainer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.9f];
        aidedTextView.layer.cornerRadius = self.inputTextView.layer.cornerRadius = 5.0f;
        aidedTextView.layer.borderColor = self.inputTextView.layer.borderColor = [UIColor blackColor].CGColor;
        aidedTextView.layer.borderWidth = self.inputTextView.layer.borderWidth = 2.0f;
    }
    return self;
}


- (void) initialize
{
    [[NSBundle mainBundle] loadNibNamed:@"AGCollectReplyView" owner:self options:nil];
    
    self.replyView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7f];
    CGRect frame = [UIScreen mainScreen].bounds;
    self.replyView.frame = frame;
    
    self.containerView.layer.cornerRadius = 5.0f;
    //self.containerView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 + 10);
}


#pragma mark - UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)aTextView
{
    self.resignButton.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)aTextView
{
    [AGCollectKeyboardScroll clear];
    self.resignButton.hidden = YES;
    self.inputViewContainer.hidden = YES;
    
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //send
    if ([text isEqualToString:@"\n"] && aTextView.text.length > 0) {
        [self send];
        //aTextView.text = @"";
        //[self relayout];
        return NO;
    }
    
    return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    [AGCollectKeyboardScroll setView:self.inputViewContainer scrollView:self.scrollView];
    self.inputViewContainer.hidden = NO;
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
    CGRect textFrame = self.inputTextView.frame;
    CGRect frame = self.contentContainer.frame;
    float diff = textFrame.origin.y * 2;
    CGPoint point = CGPointZero;
    aidedTextView.text = self.inputTextView.text;
    CGSize size = aidedTextView.contentSize;
    //inputTextView max height
    //point.x = frame.size.height + frame.origin.y - kAGChatChatMaxSpacing - diff;
    if (size.height > AGInputTextViewMaxHeight) {
        size.height = AGInputTextViewMaxHeight;
    }
    
    point.x = size.height - textFrame.size.height;
    
    if (point.x != 0.0f) {
        [UIView beginAnimations:@"RelayoutAnimations" context:nil];
        //viewContainer
        point.y = size.height + diff;
        frame = self.inputViewContainer.frame;
        frame.origin.y = frame.origin.y + frame.size.height - point.y;
        frame.size.height = point.y;
        self.inputViewContainer.frame = frame;
        //inputTextView
        textFrame.size = size;
        self.inputTextView.frame = textFrame;
        self.inputTextView.text = aidedTextView.text;
        //scroll view
        CGSize size = contentSize;
        CGRect rect = [self.scrollView convertRect:self.scrollView.bounds toView:self.inputViewContainer.superview];
        size.height = size.height + rect.origin.y - frame.origin.y;
        if (size.height > 0) {
            size.height += rect.size.height;
        }
        else{
            size.height = contentSize.height;
        }
        self.scrollView.contentSize = size;
        
        //
        [UIView commitAnimations];
    }
}

+ (id) reply
{
    AGCollectPlaneReply *reply = [[AGCollectPlaneReply alloc] init];
    return reply;
}


@end
