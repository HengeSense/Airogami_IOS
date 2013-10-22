//
//  AGPlaneController.h
//  Airogami
//
//  Created by Tianhu Yang on 8/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGCoreData.h"
#import "AGMessage.h"
#import "AGNeoPlane.h"

@interface AGPlaneController : NSObject

- (AGPlane*) savePlane:(NSDictionary*)planeJson;
- (void) markDeleted:(AGPlane*)plane;
- (NSMutableArray*) saveNeoPlanes:(NSArray*)jsonArray;
- (NSMutableArray*) savePlanes:(NSArray*)jsonArray;
- (NSMutableArray*) saveOldPlanes:(NSArray*)jsonArray;
- (NSArray*) getAllPlanesForCollect;
- (NSNumber*) recentUpdateInc;
-(void) increaseUpdateInc;
- (NSArray*) getAllPlanesForChat;
- (void) updateMessage:(AGPlane*)plane;
- (void) updateLike:(AGPlane*)plane createdTime:(NSDate*)createdTime;
- (AGMessage*) recentMessageForPlane:(NSNumber*)planeId;
- (NSArray*) getNeoPlanesForUpdate;
- (AGNeoPlane*) getNextNeoPlaneForMessages;
- (void) updateLastMsgId:(NSNumber*)lastMsgId plane:(AGPlane*) plane;
- (void) resetForSync;
- (void) deleteForSync;
//new means not obtained messages
- (AGNeoPlane*) getNextNeoPlaneForChat;
- (AGPlane*) getNextUnviewedPlane;
- (void) removeNeoPlane:(AGNeoPlane *)newPlane;
- (void) removeNeoPlanes:(NSArray *)newPlanes;

@end
