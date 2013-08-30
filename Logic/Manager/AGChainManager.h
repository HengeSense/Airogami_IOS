//
//  AGChainManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AGDefines.h"
#import "AGChainMessage.h"
#import "AGChain.h"

typedef void (^AGChainsBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *chains);

typedef void (^AGReplyChainFinishBlock)(NSError *error, id context, AGChainMessage *chainMessage, BOOL refresh);

@interface AGChainManager : NSObject

- (void) sendChain:(NSDictionary*) params context:(id)context block:(AGHttpDoneBlock)block;

- (void) replyChain:(NSDictionary*)params chain:(AGChain*)chain context:(id)context block:(AGHttpSucceedBlock)block;

- (void) obtainChainMessages:(NSDictionary *)params context:(id)context block:(AGHttpFinishBlock)block;

- (void) receiveChains:(NSDictionary*) params context:(id)context block:(AGChainsBlock)block;

- (void) obtainChains:(NSDictionary*) params context:(id)context block:(AGChainsBlock)block;

- (void) throwChain:(NSDictionary*) params chain:(AGChain*)chain context:(id)context block:(AGHttpSucceedBlock)block;

- (NSDictionary*)paramsForObtainChainMessages:(NSNumber*)chainId last:(NSDate*)last;

- (void) deleteChain:(NSDictionary*) params chain:(AGChain*)chain context:(id)context block:(AGHttpDoneBlock)block;

- (NSDictionary*)paramsForReplyChain:(NSNumber*)chainId content:(NSString*)content type:(int)type;

- (NSDictionary*)paramsForReceiveChains:(NSNumber*)start;

- (NSDictionary*)paramsForObtainChains:(NSNumber*)start;

- (NSDictionary*)paramsForThrowChain:(NSNumber*)chainId;

- (NSDictionary*)paramsForDeleteChain:(NSNumber*)chainId;

@end
