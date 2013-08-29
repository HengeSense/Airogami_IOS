//
//  AGNewPlane.h
//  Airogami
//
//  Created by Tianhu Yang on 8/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGPlane;

@interface AGNewPlane : NSManagedObject

@property (nonatomic, retain) NSNumber * updateInc;
@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSNumber * planeId;
@property (nonatomic, retain) AGPlane *plane;

@end
