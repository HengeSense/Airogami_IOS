//
//  AGPlaneController.h
//  Airogami
//
//  Created by Tianhu Yang on 8/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGCoreData.h"

@interface AGPlaneController : NSObject

- (NSMutableArray*) savePlanes:(NSArray*)jsonArray;
- (NSNumber*) recentPlaneUpdateIncForCollect;

@end
