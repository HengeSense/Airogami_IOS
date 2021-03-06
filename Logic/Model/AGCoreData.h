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

+ (AGCoreData*) coreData;

//core data class
- (NSManagedObject*) saveOrUpdate:(NSDictionary*)jsonDictionary withEntityName:(NSString*)entityName;
- (NSMutableArray*) saveOrUpdateArray:(NSArray*)jsonArray withEntityName:(NSString*)entityName;
- (NSManagedObject*) update:(NSDictionary*)jsonDictionary withEntityName:(NSString*)entityName;
- (NSMutableArray*) updateArray:(NSArray*)jsonArray withEntityName:(NSString*)entityName;
- (BOOL) editAttributes:(NSDictionary*)attributeDictionary managedObject:(NSManagedObject*)managedObject;
- (NSManagedObject*) findById:(id)objectID withEntityName:(NSString*)entityName;
- (void) remove:(NSManagedObject*) managedObject;
- (void) removeAll:(NSArray *)array;
- (NSManagedObject*) create:(Class)class;
- (BOOL) save;
- (void) resetPath;

-(void) registerObserverForEntityName:(NSString*)entityName forKey:(NSString*)key count:(int) count;
-(NSArray*) unregisterObserver;

@end
