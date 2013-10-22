//
//  AGNeoPlane.h
//  Airogami
//
//  Created by Tianhu Yang on 10/20/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGPlane;

@interface AGNeoPlane : NSManagedObject

@property (nonatomic, retain) NSNumber * clearMsgId;
@property (nonatomic, retain) NSNumber * lastMsgId;
@property (nonatomic, retain) NSNumber * neoMsgId;
@property (nonatomic, retain) NSNumber * planeId;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) NSNumber * updateInc;
@property (nonatomic, retain) AGPlane *plane;

@end
