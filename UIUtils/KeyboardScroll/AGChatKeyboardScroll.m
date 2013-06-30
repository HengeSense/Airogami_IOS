//
//  AGChatKeyboard.m
//  Airogami
//
//  Created by Tianhu Yang on 6/29/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatKeyboardScroll.h"

static UIView *view = nil;
static AGChatKeyboardScroll *chatKeyboardScroll = nil;

@implementation AGChatKeyboardScroll
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    if(view == nil)
        return;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double duration = [number doubleValue];
    CGRect frame = view.frame;
    frame.origin.y = view.superview.bounds.size.height - frame.size.height - kbSize.height;
    [UIView beginAnimations:@"KeyboardShowAnimation" context:nil];
    [UIView setAnimationDuration:duration];
    view.frame = frame;
    [UIView commitAnimations];
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(view == nil)
        return;
    NSDictionary* info = [aNotification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double duration = [number doubleValue];
    CGRect frame = view.frame;
    frame.origin.y = view.superview.bounds.size.height - frame.size.height;
    [UIView beginAnimations:@"KeyboardHideAnimation" context:nil];
    [UIView setAnimationDuration:duration];
    view.frame = frame;
    [UIView commitAnimations];
}

+ (void)initialize;
{
    chatKeyboardScroll = [[AGChatKeyboardScroll alloc] init];
}
+ (void) clear
{
    view = nil;
    [chatKeyboardScroll unregisterForKeyboardNotifications];
}
+ (void) setView:(UIView *)aView
{
    [chatKeyboardScroll registerForKeyboardNotifications];
    view = aView;
}

@end
