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

@interface AGPlaneManager : NSObject

- (void) sendPlane:(NSDictionary*) params context:(id)context block:(AGHttpDoneBlock)block;

- (void) replyPlane:(AGMessage*) message context:(id)context block:(AGReplyPlaneFinishBlock)block;

- (void) receivePlanes:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (void) obtainPlanes:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (void) obtainMessages:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block;

- (NSDictionary*)paramsForReplyPlane:(NSNumber*)planeId content:(NSString*)content type:(int)type;

- (AGMessage*)messageForReplyPlane:(AGPlane*)plane content:(NSString*)content type:(int)type;

@end
