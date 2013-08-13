//
//  AGCategory.h
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGPlane;

@interface AGCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * categoryId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *planes;
@end

@interface AGCategory (CoreDataGeneratedAccessors)

- (void)addPlanesObject:(AGPlane *)value;
- (void)removePlanesObject:(AGPlane *)value;
- (void)addPlanes:(NSSet *)values;
- (void)removePlanes:(NSSet *)values;

@end
