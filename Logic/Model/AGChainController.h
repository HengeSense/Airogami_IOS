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

@interface AGChainController : NSObject

- (NSMutableArray*) saveChains:(NSArray*)jsonArray;
- (void) increaseUpdateInc:(AGChain*)chain;
@end
