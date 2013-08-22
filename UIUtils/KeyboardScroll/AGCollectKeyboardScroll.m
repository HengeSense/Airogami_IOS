//
//  AGChatKeyboard.m
//  Airogami
//
//  Created by Tianhu Yang on 6/29/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCollectKeyboardScroll.h"

static UIView *view = nil;
static UIScrollView *scrollView = nil;
static AGCollectKeyboardScroll *collectKeyboardScroll = nil;
static CGSize contentSize;

@implementation AGCollectKeyboardScroll
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
    //scroll view
    CGSize size = contentSize;
    CGRect rect = [scrollView convertRect:scrollView.bounds toView:view.superview];;
    size.height = size.height + rect.origin.y - frame.origin.y;
    
    if (size.height > 0) {
        size.height += rect.size.height;
    }
    else{
        size.height = contentSize.height;
    }
    
    //
    [UIView beginAnimations:@"KeyboardShowAnimation" context:nil];
    [UIView setAnimationDuration:duration];
    view.frame = frame;
    scrollView.contentSize = size;
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
    scrollView.contentSize = contentSize;
    [UIView commitAnimations];
}

+ (void)initialize;
{
    collectKeyboardScroll = [[AGCollectKeyboardScroll alloc] init];
}
+ (void) clear
{
    view = nil;
    scrollView = nil;
    [collectKeyboardScroll unregisterForKeyboardNotifications];
}
+ (void) setView:(UIView *)aView scrollView:(UIScrollView *)aScrollView
{
    view = aView;
    scrollView = aScrollView;
    contentSize = scrollView.contentSize;
    [collectKeyboardScroll registerForKeyboardNotifications];
}


@end
