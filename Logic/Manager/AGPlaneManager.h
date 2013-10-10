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

typedef void (^AGReplyPlaneFinishBlock)(NSError *error, id context, AGMessage *message, BOOL refresh);
typedef void (^AGPickupPlaneAndChainFinishBlock)(NSError *error, id context, NSNumber *count);
typedef void (^AGObtainPlanesBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *planes);
typedef void (^AGGetNewPlanesBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *newPlanes);
typedef void (^AGGetOldPlanesBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *oldPlanes);
typedef void (^AGGetPlanesBlock)(NSError *error, id context, NSMutableDictionary *result, NSArray *planes);

@interface AGPlaneManager : NSObject

- (void) sendPlane:(NSDictionary*) params context:(id)context block:(AGHttpDoneBlock)block;

- (void) replyPlane:(AGMessage*) message context:(id)context block:(AGReplyPlaneFinishBlock)block;

- (void) firstReplyPlane:(NSDictionary*)params plane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block;

- (void) throwPlane:(NSDictionary*) params plane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block;

- (void) deletePlane:(NSDictionary*) params plane:(AGPlane*)plane context:(id)context block:(AGHttpDoneBlock)block;

- (void) pickupPlaneAndChain:(NSDictionary*) params context:(id)context block:(AGPickupPlaneAndChainFinishBlock)block;

- (void) receivePlanes:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (void) getNewPlanes:(NSDictionary*) params context:(id)context block:(AGGetNewPlanesBlock)block;

- (void) getPlanes:(NSDictionary*) params context:(id)context block:(AGGetPlanesBlock)block;

- (void) getOldPlanes:(NSDictionary*) params context:(id)context block:(AGGetOldPlanesBlock)block;

- (void) obtainPlanes:(NSDictionary*) params context:(id)context block:(AGObtainPlanesBlock)block;

- (void) obtainMessages:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (void) viewedMessages:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (NSDictionary*)paramsForGetNewPlane:(NSNumber*)start end:(NSNumber*)end limit:(NSNumber*)limit;

- (NSDictionary*)paramsForGetPlanes:(NSArray*)planeIds;

- (NSDictionary*)paramsForGetOldPlanes:(NSNumber*)start end:(NSNumber*)end limit:(NSNumber*)limit;

- (NSDictionary*)paramsForReplyPlane:(AGPlane*)plane content:(NSString*)content type:(int)type;

- (NSDictionary*)paramsForThrowPlane:(NSNumber*)planeId;

- (NSDictionary*)paramsForDeletePlane:(AGPlane*)plane;

- (NSDictionary*)paramsForViewedMessages:(AGPlane*)plane lastMsgId:(NSNumber*)lastMsgId;

- (AGMessage*)messageForReplyPlane:(AGPlane*)plane content:(NSString*)content type:(int)type;

@end
