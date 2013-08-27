//
//  AGChainNotification.h
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGChainNotification : NSObject

+(AGChainNotification*) chainNotification;
- (void) obtainedChains;
- (void) collectedChains;

@end
