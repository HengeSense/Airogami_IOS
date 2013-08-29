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

- (NSMutableArray*) saveChains:(NSArray*)jsonArray;
- (void) increaseUpdateIncForChat:(AGChain*)chain;
- (AGChainMessage*) recentChainMessageForCollect:(NSNumber*)chainId;
- (NSArray*) getAllChainsForCollect;
//
- (AGNewChain*) getNextNewChain;
- (void) addNewChains:(NSArray*)chains;
- (void) removeNewChain:(AGNewChain*)chain oldUpdateInc:(NSNumber*)updateInc;
@end
