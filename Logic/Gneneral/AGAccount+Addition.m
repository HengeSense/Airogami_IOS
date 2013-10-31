//
//  AGAccount+Addition.m
//  Airogami
//
//  Created by Tianhu Yang on 10/29/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAccount+Addition.h"
#import "NSString+Addition.h"

@implementation AGAccount (Addition)

//accounts/reversed accountId/account/icon ...
- (NSURL*) accountIconUrl:(BOOL) small
{
    NSString *suffix;
    if (small) {
        suffix = @"";
    }
    else{
        suffix = @"-medium";
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@accounts/%@/account/icon%@.jpg", AGDataServerUrl, self.accountId.stringValue.reverseString, suffix]];
}

@end
