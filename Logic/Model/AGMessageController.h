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

@end
