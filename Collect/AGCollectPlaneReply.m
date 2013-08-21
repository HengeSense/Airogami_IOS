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
#import "AGMessage.h"
#import "AGCategory+Addition.h"
#import "AGProfile.h"
#import "AGUtils.h"
#import "AGAccount.h"
#import "AGManagerUtils.h"
#import "AGUIDefines.h"
#import "AGDefines.h"
#import "AGResignButton.h"
#import "AGChatKeyboardScroll.h"

#define kAGChatChatMessageMaxLength AGAccountMessageContentMaxLength
#define kAGChatChatMaxSpacing 50

static float AGInputTextViewMaxHeight = 100;

@interface AGCollectPlaneReply ()
{
     UITextView *aidedTextView;
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
    self.scrollView.contentSize = frame.size;
}

-(void) show:(id)object
{
    [self initData:object];
    [self layout];
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
    if ([object isKindOfClass:[AGPlane class]]) {
        AGPlane *plane = object;
        AGProfile *profile = plane.accountByOwnerId.profile;
        self.categoryLabel.text = [AGCategory title:plane.category.categoryId];
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
        
        //
        AGMessage *message = plane.messages.objectEnumerator.nextObject;
        self.contentTextView.text = message.content;
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
    [self dismiss];
}


- (IBAction)reply:(UIButton *)sender {
    [self dismiss];
}


- (id)init
{
    if (self = [super init]) {
        [self initialize];
        //
        self.inputTextView.inputAccessoryView = self.inputViewContainer;
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
    self.containerView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 + 10);
}


#pragma mark - UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)aTextView
{
    self.resignButton.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)aTextView
{
    [AGChatKeyboardScroll clear];
    self.resignButton.hidden = YES;
    
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //send
    if ([text isEqualToString:@"\n"] && aTextView.text.length > 0) {
        //[self send];
        aTextView.text = @"";
        [self relayout];
        //[aTextView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    [AGChatKeyboardScroll setView:self.inputViewContainer];
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
        //superview
        frame = self.inputTextView.superview.frame;
        frame.size.height = size.height + diff;
        self.inputTextView.superview.frame = frame;
        //viewContainer
        /*point = frame.origin;
        point.y += size.height + diff;
        frame = viewContainer.frame;
        frame.origin.y = frame.origin.y + frame.size.height - point.y;
        frame.size.height = point.y;
        viewContainer.frame = frame;*/
        //inputTextView
        textFrame.size = size;
        self.inputTextView.frame = textFrame;
        self.inputTextView.text = aidedTextView.text;
        [UIView commitAnimations];
    }
}

+ (id) reply
{
    AGCollectPlaneReply *reply = [[AGCollectPlaneReply alloc] init];
    return reply;
}


@end
