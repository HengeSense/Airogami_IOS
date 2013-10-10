//
//  AGChainMessageController.h
//  Airogami
//
//  Created by Tianhu Yang on 8/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGChainMessage.h"
#import "AGChain.h"

@interface AGChainMessageController : NSObject

- (AGChainMessage*) saveChainMessage:(NSDictionary*)jsonDictionary;
- (AGChainMessage*) saveChainMessage:(NSDictionary*)jsonDictionary forChain:(AGChain*)chain;
//update chain.collected
- (AGChainMessage*) updateChainMessage:(NSDictionary*)jsonDictionary forChain:(AGChain*)chain;
- (NSMutableArray*) saveChainMessages:(NSArray*)jsonArray chain:(AGChain*) chain;
//descending
- (NSDictionary*) getChainMessagesForChain:(NSNumber *)chainId startTime:(NSDate *)startTime;
- (NSArray*) getChainMessagesForChain:(NSNumber *)chainId;
- (AGChainMessage*) getChainMessageForChain:(NSNumber *)chainId;

- (int) getUnreadChainMessageCountForChain:(NSNumber *)chainId;
- (void) updateMineLastTime:(AGChainMessage*)chainMessage chain:(AGChain*)chain;
- (void) updateChainMessagesCount:(AGChainMessage*)chainMessage chain:(AGChain*)chain;
- (int) updateChainMessagesCountForChain:(AGChain*)chain;
- (NSDate*) viewedChainMessagesForChain:(AGChain*)chain;

@end
