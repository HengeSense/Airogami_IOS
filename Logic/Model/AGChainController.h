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
#import "AGNewChain.h"

@interface AGChainController : NSObject

- (AGChain*) saveChain:(NSDictionary*)chainJson;
- (NSMutableArray*) saveChains:(NSArray*)jsonArray;
- (NSMutableArray*) saveChains:(NSArray*)jsonArray forCollect:(BOOL)collected;
- (NSMutableArray*) saveNewChains:(NSArray*)jsonArray;
- (NSMutableArray*) saveOldChains:(NSArray*)jsonArray;
- (void) increaseUpdateIncForChat:(AGChain*)chain;
- (NSNumber*)recentUpdateInc;
- (NSNumber*)recentChainUpdateIncForCollect;
- (NSNumber*)recentChainUpdateIncForChat;
- (AGChainMessage*) recentChainMessageForCollect:(NSNumber*)chainId;
- (AGChainMessage*) recentChainMessageForChat:(NSNumber*)chainId;
- (NSArray*) getAllChainsForCollect;
- (NSArray*) getAllChainsForChat;
//-1 = unknown; 0 = colleted; 1 = obtained; 2 = deleted
- (int) chainStatus:(NSNumber*)chainId;
//
- (NSArray*) getNewChainIdsForUpdate;
- (AGNewChain*) getNextNewChainForChainMessage;
- (void) addNewChains:(NSArray*)chains;
- (void) removeNewChain:(AGNewChain*)chain oldUpdateInc:(NSNumber*)updateInc;
//
- (void) resetForSync;
- (void) deleteForSync;
@end
