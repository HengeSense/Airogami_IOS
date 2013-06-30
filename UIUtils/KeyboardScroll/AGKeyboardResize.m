//
//  AGKeyboardResize.m
//  Airogami
//
//  Created by Tianhu Yang on 6/20/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGKeyboardResize.h"

static UIScrollView *scrollView = nil;
static UIView *view = nil;
static AGKeyboardResize *keyboardResize = nil;
@implementation AGKeyboardResize
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification object:nil];
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
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGSize rootSize = view.bounds.size;
    CGPoint origin = [view convertRect:scrollView.bounds fromView:scrollView].origin;
    
    CGRect frame = scrollView.frame;
    frame.size.height = rootSize.height - origin.y - kbSize.height;
    scrollView.frame = frame;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardDidChangeFrame:(NSNotification*)aNotification
{

}

+ (void)initialize;
{
    keyboardResize = [[AGKeyboardResize alloc] init];
    //[keyboardScroll registerForKeyboardNotifications];
}
+ (void) clear
{
    scrollView = nil;
    view = nil;
    [keyboardResize unregisterForKeyboardNotifications];
}
+ (void) setScrollView:(UIScrollView*) aScrollView view:(UIView *)aView
{
    [keyboardResize registerForKeyboardNotifications];
    scrollView = aScrollView;
    view = aView;
}

@end
