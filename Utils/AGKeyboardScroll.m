//
//  AGKeyboardScroll.m
//  Airogami
//
//  Created by Tianhu Yang on 6/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGKeyboardScroll.h"

#define kAGKeyboardTextFieldGap 20

static UIScrollView *scrollView = nil;
static UIView *view = nil;
static UITextField *activeField = nil;
static AGKeyboardScroll *keyboardScroll = nil;
static CGSize kbSize;;

@implementation AGKeyboardScroll
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if(scrollView == nil)
        return;
    NSDictionary* info = [aNotification userInfo];
    kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(scrollView == nil)
        return;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGSize size = scrollView.bounds.size;
    size.height -= kbSize.height;
    [UIView beginAnimations:@"KeyboardHideAnimation" context:nil];
    scrollView.contentSize = size;
    [UIView commitAnimations];
}

+ (void)initialize;
{
    keyboardScroll = [[AGKeyboardScroll alloc] init];
    //[keyboardScroll registerForKeyboardNotifications];
}
+ (void) clear
{
      scrollView = nil;
      view = nil;
      activeField = nil;
    [keyboardScroll unregisterForKeyboardNotifications];
}
+ (void) setScrollView:(UIScrollView*) aScrollView view:(UIView *)aView  activeField:(UITextField *)anActiveField
{
    [keyboardScroll registerForKeyboardNotifications];
    scrollView = aScrollView;
    view = aView;
    activeField = anActiveField;
    
    //chang loaction 
    CGSize size = scrollView.bounds.size;
    size.height += kbSize.height;
    scrollView.contentSize = size;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = activeField.frame.origin;
    origin.y += activeField.frame.size.height;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, origin.y - aRect.size.height + kAGKeyboardTextFieldGap);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}
@end
