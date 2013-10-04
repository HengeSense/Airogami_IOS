//
//  AGPlaceholderTextView.m
//  Airogami
//
//  Created by Tianhu Yang on 10/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPlaceholderTextView.h"

@interface AGPlaceholderTextView()
{
    BOOL _shouldHavePlaceholder;
}

@end

@implementation AGPlaceholderTextView

@synthesize aidedTextView;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}


#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self _initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}

- (void) setFrame:(CGRect)frame_
{
    [super setFrame:frame_];
    aidedTextView.frame = frame_;
}


#pragma mark - Private

- (void)_initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textChanged:) name:UITextViewTextDidChangeNotification object:self];
    _shouldHavePlaceholder = YES;
}


- (void)_updateShouldHavePlaceholder {
    BOOL prev = _shouldHavePlaceholder;
    _shouldHavePlaceholder = self.text.length == 0 ;
    
    if (prev != _shouldHavePlaceholder) {
        //self.backgroundColor = _shouldHavePlaceholder ? [UIColor clearColor] : [UIColor whiteColor];
        aidedTextView.hidden = !_shouldHavePlaceholder;
    }
}


- (void)_textChanged:(NSNotification *)notificaiton {
    [self _updateShouldHavePlaceholder];
}

@end
