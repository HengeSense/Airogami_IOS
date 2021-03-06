//
//  AGChainNotification.h
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *AGNotificationGetNeoChains;
extern NSString *AGNotificationGetChains;
extern NSString *AGNotificationChainRefreshed;

extern NSString *AGNotificationCollectedChains;
extern NSString *AGNotificationGetCollectedChains;

extern NSString *AGNotificationObtainedChains;
extern NSString *AGNotificationGetObtainedChains;

extern NSString *AGNotificationObtainedChainMessagesForChain;
extern NSString *AGNotificationObtainChainMessages;
extern NSString *AGNotificationGetObtainedChainMessages;

extern NSString *AGNotificationGetChainMessagesForChain;
extern NSString *AGNotificationGotChainMessagesForChain;

extern NSString *AGNotificationViewChainMessages;
extern NSString *AGNotificationViewedChainMessagesForChain;
extern NSString *AGNotificationUnreadChainMessagesChangedForChain;
extern NSString *AGNotificationViewingChainMessagesForChain;

@interface AGChainNotification : NSObject

+(AGChainNotification*) chainNotification;
- (void) obtainedChains;
- (void) collectedChains;
- (void) reset;
@end
