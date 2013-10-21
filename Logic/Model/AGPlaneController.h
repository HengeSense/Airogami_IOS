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
- (NSNumber*) recentPlaneUpdateIncForCollect;
- (NSArray*) getAllPlanesForCollect;
- (NSNumber*) recentUpdateInc;
- (NSNumber*) recentPlaneUpdateIncForChat;
-(void) increaseUpdateInc;
- (void) increaseUpdateIncForChat:(AGPlane*)plane;
- (NSArray*) getAllPlanesForChat;
- (void) updateMessage:(AGPlane*)plane;
- (AGMessage*) recentMessageForPlane:(NSNumber*)planeId;
- (NSArray*) getNeoPlanesForUpdate;
- (AGNeoPlane*) getNextNeoPlaneForMessages;
- (void) updateLastMsgId:(NSNumber*)lastMsgId plane:(AGPlane*) plane;
- (void) resetForSync;
- (void) deleteForSync;
//new means not obtained messages
- (AGNeoPlane*) getNextNeoPlaneForChat;
- (AGPlane*) getNextUnviewedPlane;
- (void) addNeoPlanesForChat:(NSArray*)planes;
- (void) removeNeoPlaneForChat:(AGNeoPlane*)plane oldUpdateInc:(NSNumber*)updateInc;
- (void) removeNeoPlane:(AGNeoPlane *)newPlane;
- (void) removeNeoPlanes:(NSArray *)newPlanes;

@end
