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

@interface AGPlaneController : NSObject

- (AGPlane*) savePlane:(NSDictionary*)planeJson;
- (NSMutableArray*) savePlanes:(NSArray*)jsonArray;
- (NSNumber*) recentPlaneUpdateIncForCollect;
- (NSArray*) getAllPlanesForCollect;
- (NSNumber*) recentPlaneUpdateIncForChat;
- (void) increaseUpdateInc:(AGPlane*)plane;
- (NSArray*) getAllPlanesForChat;
- (AGMessage*) recentMessageForPlane:(NSNumber*)planeId;
//new means not obtained messages
- (NSArray*) getAllNewPlanesForChat;

@end
