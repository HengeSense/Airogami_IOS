//
//  AGChainNotification.h
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *AGNotificationCollectedChains;
extern NSString *AGNotificationReceiveChains;
extern NSString *AGNotificationGetCollectedChains;

extern NSString *AGNotificationObtainedChains;
extern NSString *AGNotificationObtainChains;
extern NSString *AGNotificationGetObtainedChains;

extern NSString *AGNotificationObtainedChainMessagesForChain;
extern NSString *AGNotificationObtainChainMessages;
extern NSString *AGNotificationGetObtainedChainMessages;

extern NSString *AGNotificationGetChainMessagesForChain;
extern NSString *AGNotificationGotChainMessagesForChain;

@interface AGChainNotification : NSObject

+(AGChainNotification*) chainNotification;
- (void) obtainedChains;
- (void) collectedChains;

@end