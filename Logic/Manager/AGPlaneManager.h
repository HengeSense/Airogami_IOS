//
//  AGPlaneManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGDefines.h"
#import "AGMessage.h"

typedef void (^AGReplyPlaneFinishBlock)(NSError *error, id context);
typedef void (^AGPickupPlaneAndChainFinishBlock)(NSError *error, id context, NSNumber *count);
typedef void (^AGGetNeoPlanesBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *neoPlanes);
typedef void (^AGGetOldPlanesBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *oldPlanes);
typedef void (^AGGetPlanesBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *planes);

@interface AGPlaneManager : NSObject

- (void) sendPlane:(NSDictionary*) params context:(id)context block:(AGHttpDoneBlock)block;

- (void) replyPlane:(AGMessage*) message context:(id)context block:(AGReplyPlaneFinishBlock)block;

- (void) firstReplyPlane:(NSDictionary*)params plane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block;

- (void) likePlane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block;

- (void) throwPlane:(NSDictionary*) params plane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block;

- (void) clearPlane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block;

- (void) deletePlane:(NSDictionary*) params plane:(AGPlane*)plane context:(id)context block:(AGHttpDoneBlock)block;

- (void) pickupPlaneAndChain:(NSDictionary*) params context:(id)context block:(AGPickupPlaneAndChainFinishBlock)block;

- (void) getNeoPlanes:(NSDictionary*) params context:(id)context block:(AGGetNeoPlanesBlock)block;

- (void) getPlanes:(NSDictionary*) params context:(id)context block:(AGGetPlanesBlock)block;

- (void) getOldPlanes:(NSDictionary*) params context:(id)context block:(AGGetOldPlanesBlock)block;

- (void) obtainMessages:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (void) viewedMessages:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (NSDictionary*)paramsForGetNeoPlane:(NSNumber*)start end:(NSNumber*)end limit:(NSNumber*)limit;

- (NSDictionary*)paramsForGetPlanes:(NSArray*)planeIds updated:(BOOL)updated;

- (NSDictionary*)paramsForGetOldPlanes:(NSNumber*)start end:(NSNumber*)end limit:(NSNumber*)limit;

- (NSDictionary*)paramsForReplyPlane:(AGPlane*)plane content:(NSString*)content type:(int)type;

- (NSDictionary*)paramsForThrowPlane:(NSNumber*)planeId;

- (NSDictionary*)paramsForDeletePlane:(AGPlane*)plane;

- (NSDictionary*)paramsForViewedMessages:(AGPlane*)plane lastMsgId:(NSNumber*)lastMsgId;

- (AGMessage*)messageForReplyPlane:(AGPlane*)plane content:(NSString*)content type:(int)type;

- (AGMessage*)messageForReplyPlane:(AGPlane*)plane content:(NSString*)content imageSize:(CGSize)size;

@end
