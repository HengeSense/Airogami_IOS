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

typedef void (^AGGetNewChainsBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *newChains);
typedef void (^AGGetChainsBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *chains);
typedef void (^AGGetOldChainsBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *oldChains);

typedef void (^AGChainsBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *chains);

typedef void (^AGReplyChainFinishBlock)(NSError *error, id context, AGChainMessage *chainMessage, BOOL refresh);

@interface AGChainManager : NSObject

- (void) sendChain:(NSDictionary*) params context:(id)context block:(AGHttpDoneBlock)block;

- (void) replyChain:(NSDictionary*)params chain:(AGChain*)chain context:(id)context block:(AGHttpSucceedBlock)block;

- (void) getNewChains:(NSDictionary*) params context:(id)context block:(AGGetNewChainsBlock)block;

- (void) getChains:(NSDictionary*) params context:(id)context block:(AGGetChainsBlock)block;

- (void) getOldChains:(NSDictionary*) params context:(id)context block:(AGGetOldChainsBlock)block;

- (void) obtainChainMessages:(NSDictionary *)params context:(id)context block:(AGHttpFinishBlock)block;

- (void) receiveChains:(NSDictionary*) params context:(id)context block:(AGChainsBlock)block;

- (void) obtainChains:(NSDictionary*) params context:(id)context block:(AGChainsBlock)block;

- (void) throwChain:(NSDictionary*) params chain:(AGChain*)chain context:(id)context block:(AGHttpSucceedBlock)block;

- (NSDictionary*)paramsForObtainChainMessages:(NSNumber*)chainId last:(NSDate*)last;

- (void) deleteChain:(NSDictionary*) params chain:(AGChain*)chain context:(id)context block:(AGHttpDoneBlock)block;

- (void) viewedChainMessages:(NSDictionary *)params context:(id)context block:(AGHttpFinishBlock)block;

- (NSDictionary*)paramsForReplyChain:(NSNumber*)chainId content:(NSString*)content type:(int)type;

- (NSDictionary*)paramsForGetNewChains:(NSNumber*)start;

- (NSDictionary*)paramsForGetOldChains:(NSNumber*)start end:(NSNumber*)end limit:(NSNumber*)limit;

- (NSDictionary*)paramsForGetChains:(NSArray*)chainIds;

- (NSDictionary*)paramsForReceiveChains:(NSNumber*)start;

- (NSDictionary*)paramsForObtainChains:(NSNumber*)start;

- (NSDictionary*)paramsForThrowChain:(NSNumber*)chainId;

- (NSDictionary*)paramsForDeleteChain:(NSNumber*)chainId;

- (NSDictionary*)paramsForViewedChainMessages:(NSNumber*)chainId last:(NSDate*)last;

@end
