//
//  AGMessageController.h
//  Airogami
//
//  Created by Tianhu Yang on 8/16/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGMessage.h"

@class AGNeoPlane;

@interface AGMessageController : NSObject

- (NSMutableArray*) saveMessages:(NSArray*)jsonArray plane:(AGPlane*) plane;

- (AGMessage*) saveMessage:(NSDictionary*)jsonDictionary;

-(void) updateNeoMsgId:(AGNeoPlane*)neoPlane;

- (void) updateMessagesCount:(AGPlane*)plane;

- (int) updateMessagesCountForPlane:(AGPlane*)plane;

- (NSDictionary*) getMessagesForPlane:(NSNumber *)planeId startId:(NSNumber *)startId;

//messageId = -1
- (NSArray*) getUnsentMessagesForPlane:(NSNumber *)planeId;

- (AGMessage*) getNextUnsentMessage;

- (AGMessage*) getNextUnsentDataMessage;

- (int) getUnreadMessageCountForPlane:(NSNumber *)planeId;

- (NSNumber*) viewedMessagesForPlane:(AGPlane*)plane;

//return updated;
- (BOOL) clearPlane:(AGPlane*)plane clearMsgId:(NSNumber*)clearMsgId;

@end
