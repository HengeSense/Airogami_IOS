//
//  NSString+Addition.m
//  Airogami
//
//  Created by Tianhu Yang on 6/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "NSString+Addition.h"

@implementation NSString (Addition)
- (BOOL) isValidEmail
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isNumeric{
    
    for (int i = 0; i < self.length; ++i) {
        unichar ch = [self characterAtIndex:i];
        if (ch < '0' || ch > '9') {
            return NO;
        }
    }
    return YES;
}

- (NSString*) encodeURIComponent
{
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(
                                                                        kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)(self),
                                                                        NULL,
                                                                        CFSTR(":/?#[]@!$&'()*+,;="),
                                                                        kCFStringEncodingUTF8);
    NSString *component = (__bridge NSString *)(encodedString);
    CFRelease(encodedString);
    return component;
}

- (NSString*) reverseString
{
    int len = self.length;
    
    // auto released string
    NSMutableString * reversedStr = [NSMutableString stringWithCapacity:len];
    
    // quick-and-dirty implementation
    while ( len > 0 )
    {
        [reversedStr appendString:[NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];
    }
    
    return reversedStr;
}

@end
