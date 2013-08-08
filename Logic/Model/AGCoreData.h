//
//  AGCoreData.h
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AGCoreData : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//core data class
- (NSManagedObject*) saveOrUpdate:(NSDictionary*)jsonDictionary withEntityName:(NSString*)entityName;

- (BOOL) save;

@end
