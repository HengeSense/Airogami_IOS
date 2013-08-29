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
#import "AGNewPlane.h"

@interface AGPlaneController : NSObject

- (AGPlane*) savePlane:(NSDictionary*)planeJson;
- (NSMutableArray*) savePlanes:(NSArray*)jsonArray;
- (NSNumber*) recentPlaneUpdateIncForCollect;
- (NSArray*) getAllPlanesForCollect;
- (NSNumber*) recentPlaneUpdateIncForChat;
- (void) increaseUpdateIncForChat:(AGPlane*)plane;
- (NSArray*) getAllPlanesForChat;
- (AGMessage*) recentMessageForPlane:(NSNumber*)planeId;
//new means not obtained messages
- (AGNewPlane*) getNextNewPlaneForChat;
- (void) addNewPlanesForChat:(NSArray*)planes;
- (void) removeNewPlaneForChat:(AGNewPlane*)plane oldUpdateInc:(NSNumber*)updateInc;

@end
