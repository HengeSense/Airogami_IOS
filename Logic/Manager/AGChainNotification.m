//
//  AGChainNotification.m
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChainNotification.h"

@implementation AGChainNotification

+(AGChainNotification*) chainNotification
{
    static AGChainNotification *chainNotification;
    if (chainNotification == nil) {
        chainNotification = [[AGChainNotification alloc] init];
    }
    return chainNotification;
}

- (void) obtainedChains
{
    
}

- (void) collectedChains
{
    
}
@end
