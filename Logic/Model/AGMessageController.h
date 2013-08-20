//
//  AGMessageController.h
//  Airogami
//
//  Created by Tianhu Yang on 8/16/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGMessage.h"

@interface AGMessageController : NSObject

- (NSMutableArray*) saveMessages:(NSArray*)jsonArray plane:(AGPlane*) plane;

- (AGMessage*) saveMessage:(NSDictionary*)jsonDictionary;

- (NSArray*) getMessagesForPlane:(NSNumber *)planeId startId:(NSNumber *)startId;

//messageId = -1
- (NSArray*) getUnsentMessagesForPlane:(NSNumber *)planeId;


@end
