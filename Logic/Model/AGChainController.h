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
- (NSMutableArray*) saveChains:(NSArray*)jsonArray forCollect:(BOOL)collected;
- (void) increaseUpdateIncForChat:(AGChain*)chain;
- (NSNumber*)recentChainUpdateIncForCollect;
- (NSNumber*)recentChainUpdateIncForChat;
- (AGChainMessage*) recentChainMessageForCollect:(NSNumber*)chainId;
- (AGChainMessage*) recentChainMessageForChat:(NSNumber*)chainId;
- (NSArray*) getAllChainsForCollect;
- (NSArray*) getAllChainsForChat;
//-1 = unknown; 0 = colleted; 1 = obtained; 2 = deleted
- (int) chainStatus:(NSNumber*)chainId;
//
- (AGNewChain*) getNextNewChain;
- (void) addNewChains:(NSArray*)chains;
- (void) removeNewChain:(AGNewChain*)chain oldUpdateInc:(NSNumber*)updateInc;
@end
