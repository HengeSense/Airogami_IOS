//
//  AGDataManger.m
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGDataManger.h"
#import "AGDefines.h"
#import "AGUIDefines.h"


@implementation AGDataManger

- (NSURL*) accountIconUrl:(NSNumber*)accountId small:(BOOL) small
{
    NSString *suffix;
    if (small) {
        suffix = @"";
    }
    else{
        suffix = @"-medium";
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@accounts/%@/account/icon%@.jpg", AGDataServerUrl, accountId, suffix]];
}


@end
