//
//  AGChainController.h
//  Airogami
//
//  Created by Tianhu Yang on 8/21/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGChain.h"
#import "AGChainMessage.h"
#import "AGNeoChain.h"

@interface AGChainController : NSObject

- (AGChain*) saveChain:(NSDictionary*)chainJson;
- (NSMutableArray*) saveChains:(NSArray*)jsonArray;
- (NSMutableArray*) saveChainsForCollect:(NSArray*)jsonArray;
- (NSMutableArray*) saveChains:(NSArray*)jsonArray forCollect:(BOOL)collected;
- (NSMutableArray*) saveNeoChains:(NSArray*)jsonArray;
- (NSMutableArray*) saveOldChains:(NSArray*)jsonArray;
- (void) increaseUpdateInc;
- (void) increaseUpdateIncForChat:(AGChain*)chain;
- (void) updateLastViewedTime:(NSDate *)lastViewedTime chain:(AGChain*)chain;
- (NSNumber*)recentUpdateInc;
- (NSNumber*)recentChainUpdateIncForCollect;
- (NSNumber*)recentChainUpdateIncForChat;
- (void) updateChainMessage:(AGChain*)chain;
- (AGChainMessage*) recentChainMessage:(NSNumber*)chainId;
- (NSArray*) getAllChainsForCollect;
- (NSArray*) getAllChainsForChat;
//-1 = unknown; 0 = colleted; 1 = obtained; 2 = deleted
- (int) chainStatus:(NSNumber*)chainId;
//
- (NSArray*) getNeoChainIdsForUpdate;
- (AGNeoChain*) getNextNeoChainForChainMessage;
- (void) addNeoChains:(NSArray*)chains;
- (void) removeNeoChain:(AGNeoChain*)chain oldUpdateInc:(NSNumber*)updateInc;
//
- (void) resetForSync;
- (void) deleteForSync;
@end
