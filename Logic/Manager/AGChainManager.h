//
//  AGChainManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AGDefines.h"

@interface AGChainManager : NSObject

- (void) sendChain:(NSDictionary*) params context:(id)context block:(AGHttpDoneBlock)block;

@end
