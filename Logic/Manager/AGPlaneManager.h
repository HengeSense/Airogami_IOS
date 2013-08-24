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

typedef void (^AGReplyPlaneFinishBlock)(NSError *error, id context, AGMessage *result);
typedef void (^AGPickupPlaneAndChainFinishBlock)(NSError *error, id context, NSNumber *count);

@interface AGPlaneManager : NSObject

- (void) sendPlane:(NSDictionary*) params context:(id)context block:(AGHttpDoneBlock)block;

- (void) replyPlane:(AGMessage*) message context:(id)context block:(AGReplyPlaneFinishBlock)block;

- (void) firstReplyPlane:(NSDictionary*)params plane:(AGPlane*)plane context:(id)context block:(AGReplyPlaneFinishBlock)block;

- (void) throwPlane:(NSDictionary*) params plane:(AGPlane*)plane context:(id)context block:(AGHttpDoneBlock)block;

- (void) deletePlane:(NSDictionary*) params plane:(AGPlane*)plane context:(id)context block:(AGHttpDoneBlock)block;

- (void) pickupPlaneAndChain:(NSDictionary*) params context:(id)context block:(AGPickupPlaneAndChainFinishBlock)block;

- (void) receivePlanes:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (void) obtainPlanes:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (void) obtainMessages:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (void) viewedMessages:(NSDictionary*) params context:(id)context block:(AGHttpDoneBlock)block;

- (NSDictionary*)paramsForReplyPlane:(NSNumber*)planeId content:(NSString*)content type:(int)type;

- (NSDictionary*)paramsForThrowPlane:(NSNumber*)planeId;

- (NSDictionary*)paramsForDeletePlane:(AGPlane*)plane;

- (NSDictionary*)paramsForViewedMessages:(AGPlane*)plane lastMsgId:(NSNumber*)lastMsgId;

- (AGMessage*)messageForReplyPlane:(AGPlane*)plane content:(NSString*)content type:(int)type;

@end
