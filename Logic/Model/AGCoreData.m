//
//  AGCoreData.m
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCoreData.h"
#import "AGFileManager.h"
#import "AGUtils.h"
#import "AGAppDelegate.h"

@interface AGCoreData()
{
    NSString *observedEntityName;
    NSString *observedEntityKey;
    NSMutableArray *changedEntities;
}

@end

@implementation AGCoreData

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;


+ (AGCoreData*) coreData
{
    static AGCoreData* coreData;
    if (coreData == nil) {
        coreData = [[AGCoreData alloc] init];
    }
    return coreData;
}

#pragma mark -
#pragma mark Core Data stack

-(id) init
{
    if (self = [super init]) {
        //[self managedObjectContext];
    }
    return self;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [NSManagedObjectContext new];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

- (void) resetPath
{
    managedObjectContext = nil;
    persistentStoreCoordinator = nil;
    [self managedObjectContext];
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSString *DBName = @"Database.sqlite";
	NSURL *storeUrl = [[AGFileManager fileManager] urlForDatabase];
    storeUrl = [storeUrl URLByAppendingPathComponent:DBName];
    if (storeUrl) {
        NSError *error;
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible
             * The schema for the persistent store is incompatible with current managed object model
             Check the error message to determine what the actual problem was.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef IS_DEBUG
            abort();
#endif
        }
    }
    
    return persistentStoreCoordinator;
}


/*- (NSDictionary*)dataStructureFromManagedObject:(NSManagedObject*)managedObject
{
    NSDictionary *attributesByName = [[managedObject entity] attributesByName];
    NSDictionary *relationshipsByName = [[managedObject entity] relationshipsByName];
    NSMutableDictionary *valuesDictionary = [[managedObject dictionaryWithValuesForKeys:[attributesByName allKeys]] mutableCopy];
    [valuesDictionary setObject:[[managedObject entity] name] forKey:@"ManagedObjectName"];
    for (NSString *relationshipName in [relationshipsByName allKeys]) {
        NSRelationshipDescription *description = [[[managedObject entity] relationshipsByName] objectForKey:relationshipName];
        if (![description isToMany]) {
            NSManagedObject *relationshipObject = [managedObject valueForKey:relationshipName];
            [valuesDictionary setObject:[self dataStructureForManagedObject:relationshipObject] forKey:relationshipName];
            continue;
        }
        NSSet *relationshipObjects = [managedObject objectForKey:relationshipName];
        NSMutableArray *relationshipArray = [[NSMutableArray alloc] init];
        for (NSManagedObject *relationshipObject in relationshipObjects) {
            [relationshipArray addObject:[self dataStructureForManagedObject:relationshipObject]];
        }
        [valuesDictionary setObject:relationshipArray forKey:relationshipName];
    }
    return [valuesDictionary autorelease];
}

- (NSArray*)dataStructuresFromManagedObjects:(NSArray*)managedObjects
{
    NSMutableArray *dataArray = [[NSArray alloc] init];
    for (NSManagedObject *managedObject in managedObjects) {
        [dataArray addObject:[self dataStructureForManagedObject:managedObject]];
    }
    return [dataArray autorelease];
}*

- (NSString*)jsonStructureFromManagedObjects:(NSArray*)managedObjects
{
    NSArray *objectsArray = [self dataStructuresFromManagedObjects:managedObjects];
    NSString *jsonString = [[CJSONSerializer serializer] serializeArray:objectsArray];
    return jsonString;
}



- (NSManagedObject*)managedObjectFromStructure:(NSDictionary*)structureDictionary withManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *objectName = [structureDictionary objectForKey:@"ManagedObjectName"];
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:objectName inManagedObjectContext:moc];
    
    [managedObject setValuesForKeysWithDictionary:structureDictionary];
    
    for (NSString *relationshipName in [[[managedObject entity] relationshipsByName] allKeys]) {
        NSRelationshipDescription *description = [relationshipsByName objectForKey:relationshipName];
        if (![description isToMany]) {
            NSDictionary *childStructureDictionary = [structureDictionary objectForKey:relationshipName];
            NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
            [managedObject setObject:childObject forKey:relationshipName];
            continue;
        }
        NSMutableSet *relationshipSet = [managedObject mutableSetForKey:relationshipName];
        NSArray *relationshipArray = [structureDictionary objectForKey:relationshipName];
        for (NSDictionary *childStructureDictionary in relationshipArray) {
            NSManagedObject *childObject = [self managedObjectFromStructure:childStructureDictionary withManagedObjectContext:moc];
            [relationshipSet addObject:childObject];
        }
    }
    return managedObject;
}

- (NSArray*)managedObjectsFromJSONStructure:(NSString*)json withManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSError *error = nil;
    NSArray *structureArray = [[CJSONDeserializer deserializer] deserializeAsArray:json error:&error];
    NSAssert2(error == nil, @"Failed to deserialize\n%@\n%@", [error localizedDescription], json);
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    for (NSDictionary *structureDictionary in structureArray) {
        [objectArray addObject:[self managedObjectFromStructure:structureDictionary withManagedObjectContext:moc]];
    }
    return [objectArray autorelease];
}*/

- (NSManagedObject*) saveOrUpdate:(NSDictionary*)jsonDictionary withEntityName:(NSString*)entityName
{
    if (jsonDictionary == nil || [jsonDictionary isEqual:[NSNull null]]) {
        return nil;
    }
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    NSDictionary *attributesByName = [entityDescription attributesByName];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    
    NSString *idKey = [entityDescription.userInfo objectForKey:@"IdKey"];
    NSPredicate *predicate;
    if (idKey) {
        predicate = [NSPredicate predicateWithFormat:@"%K = %@", idKey, [jsonDictionary objectForKey:idKey]];
    }
    else{
        int idKeyCount = [[entityDescription.userInfo objectForKey:@"IdKeyCount"] intValue];
        NSMutableString *string = [NSMutableString stringWithCapacity:50];
        for (int i = 0; i < idKeyCount; ++i) {
            idKey = [entityDescription.userInfo objectForKey:[NSString stringWithFormat:@"IdKey%d", i + 1]];
            if (i > 0) {
                [string appendString:@" and "];
            }
            [string appendString:idKey];
            [string appendString:@" = "];
            [string appendFormat:@"%@",[jsonDictionary valueForKeyPath:idKey]];
            
        }
        assert(string.length);
        predicate = [NSPredicate predicateWithFormat:string];
    }
    
    
    [fetchRequest setPredicate:predicate];
    
    NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
#ifdef IS_DEBUG
    if (error) {
        NSLog(@"%@",error.userInfo);
    }
#endif
    NSManagedObject *managedObject;
    if (array.count) {//update
        managedObject = [array lastObject];
    }
    else{//insert
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjectContext];
    }
    BOOL shouldObserve = [observedEntityName isEqualToString:entityName];
    //set values
    for (NSString *key in attributesByName.allKeys) {
        NSAttributeDescription *attributeDescription  = [attributesByName objectForKey:key];
        id obj = [jsonDictionary objectForKey:key];
        if (obj) {
            if ([obj isEqual:[NSNull null]]) {
                obj = nil;
            }
            else if(attributeDescription.attributeType == NSDateAttributeType){
                if ([key isEqualToString:@"birthday"]) {
                    obj = [AGUtils stringToBirthday:(NSString*)obj];
                }
                else{
                    obj = [AGUtils stringToDate:(NSString*)obj];
                }
            }
            else if(attributeDescription.attributeType == NSInteger64AttributeType){
                obj = [NSNumber numberWithLongLong:((NSNumber*)obj).longLongValue];

            }
            
            if (shouldObserve && [observedEntityKey isEqualToString:key]) {
                id oldObj = [managedObject valueForKey:key];
                if ([oldObj isEqual:obj] == NO) {
                    [changedEntities addObject:managedObject];
                }
            }
            
            [managedObject setValue:obj forKey:key];//9223372036854775785
        }
        
    }
    
    //relationship
    NSDictionary *relationshipsByName = [entityDescription relationshipsByName];
    NSArray *relationshipsKeys = [relationshipsByName allKeys];
    for (NSString *relationshipName in relationshipsKeys) {
        NSRelationshipDescription *relationshipDescription = [relationshipsByName objectForKey:relationshipName];
        NSManagedObject *childObject;
        if ([relationshipDescription isToMany]) {
            NSArray *relationshipArray = [jsonDictionary objectForKey:relationshipName];
            if(relationshipArray != nil && [relationshipArray isEqual:[NSNull null]] == NO)
            {
                 NSMutableSet *relationshipSet = [managedObject mutableSetValueForKey:relationshipName];
                for (NSDictionary *childObjectDictionary in relationshipArray) {
                    childObject = [self saveOrUpdate:childObjectDictionary withEntityName:relationshipDescription.destinationEntity.name];
                    if (childObject) {
                        [relationshipSet addObject:childObject];
                    }
                    
                }
            }
            
        }
        else{
            NSDictionary *childJsonDictionary = [jsonDictionary objectForKey:relationshipName];
            childObject = [self saveOrUpdate:childJsonDictionary withEntityName:relationshipDescription.destinationEntity.name];
            if (childObject) {
                [managedObject setValue:childObject forKey:relationshipName];
            }
            
        }
       
    }
    return managedObject;
}

- (NSMutableArray*) saveOrUpdateArray:(NSArray*)jsonArray withEntityName:(NSString*)entityName
{
    if (jsonArray == nil || [jsonArray isEqual:[NSNull null]] || jsonArray.count == 0) {
        return [NSMutableArray array];
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:jsonArray.count];
    for (NSDictionary *dict in jsonArray) {
        NSManagedObject * managedObject = [self saveOrUpdate:dict withEntityName:entityName];
        if (managedObject) {
            [array addObject:managedObject];
        }
    }
    return array;
}

- (NSManagedObject*) update:(NSDictionary*)jsonDictionary withEntityName:(NSString*)entityName
{
    if (jsonDictionary == nil || [jsonDictionary isEqual:[NSNull null]]) {
        return nil;
    }
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    NSDictionary *attributesByName = [entityDescription attributesByName];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    
    NSString *idKey = [entityDescription.userInfo objectForKey:@"IdKey"];
    NSPredicate *predicate;
    if (idKey) {
        predicate = [NSPredicate predicateWithFormat:@"%K = %@", idKey, [jsonDictionary objectForKey:idKey]];
    }
    else{
        int idKeyCount = [[entityDescription.userInfo objectForKey:@"IdKeyCount"] intValue];
        NSMutableString *string = [NSMutableString stringWithCapacity:50];
        for (int i = 0; i < idKeyCount; ++i) {
            idKey = [entityDescription.userInfo objectForKey:[NSString stringWithFormat:@"IdKey%d", i + 1]];
            if (i > 0) {
                [string appendString:@" and "];
            }
            [string appendString:idKey];
            [string appendString:@" = "];
            [string appendFormat:@"%@",[jsonDictionary valueForKeyPath:idKey]];
            
        }
        assert(string.length);
        predicate = [NSPredicate predicateWithFormat:string];
    }
    
    
    [fetchRequest setPredicate:predicate];
    
    NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
#ifdef IS_DEBUG
    if (error) {
        NSLog(@"%@",error.userInfo);
    }
#endif
    NSManagedObject *managedObject;
    if (array.count) {//update
        managedObject = [array lastObject];
        BOOL shouldObserve = [observedEntityName isEqualToString:entityName];
        //set values
        for (NSString *key in attributesByName.allKeys) {
            NSAttributeDescription *attributeDescription  = [attributesByName objectForKey:key];
            NSObject *obj = [jsonDictionary objectForKey:key];
            if (obj) {
                if ([obj isEqual:[NSNull null]]) {
                    obj = nil;
                }
                else if(attributeDescription.attributeType == NSDateAttributeType){
                    if ([key isEqualToString:@"birthday"]) {
                        obj = [AGUtils stringToBirthday:(NSString*)obj];
                    }
                    else{
                        obj = [AGUtils stringToDate:(NSString*)obj];
                    }
                    
                }
                if (shouldObserve && [observedEntityKey isEqualToString:key]) {
                    id oldObj = [managedObject valueForKey:key];
                    if ([oldObj isEqual:obj] == NO) {
                        [changedEntities addObject:managedObject];
                    }
                }
                
                [managedObject setValue:obj forKey:key];//9223372036854775785
            }
            
        }
        
        //relationship
        NSDictionary *relationshipsByName = [entityDescription relationshipsByName];
        NSArray *relationshipsKeys = [relationshipsByName allKeys];
        for (NSString *relationshipName in relationshipsKeys) {
            NSRelationshipDescription *relationshipDescription = [relationshipsByName objectForKey:relationshipName];
            NSManagedObject *childObject;
            if ([relationshipDescription isToMany]) {
                NSArray *relationshipArray = [jsonDictionary objectForKey:relationshipName];
                if(relationshipArray != nil && [relationshipArray isEqual:[NSNull null]] == NO)
                {
                    NSMutableSet *relationshipSet = [managedObject mutableSetValueForKey:relationshipName];
                    for (NSDictionary *childObjectDictionary in relationshipArray) {
                        childObject = [self saveOrUpdate:childObjectDictionary withEntityName:relationshipDescription.destinationEntity.name];
                        if (childObject) {
                            [relationshipSet addObject:childObject];
                        }
                        
                    }
                }
                
            }
            else{
                NSDictionary *childJsonDictionary = [jsonDictionary objectForKey:relationshipName];
                childObject = [self saveOrUpdate:childJsonDictionary withEntityName:relationshipDescription.destinationEntity.name];
                if (childObject) {
                    [managedObject setValue:childObject forKey:relationshipName];
                }
                
            }
            
        }
    }
    
    return managedObject;
}

- (NSMutableArray*) updateArray:(NSArray*)jsonArray withEntityName:(NSString*)entityName
{
    if (jsonArray == nil || [jsonArray isEqual:[NSNull null]] || jsonArray.count == 0) {
        return [NSMutableArray array];
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:jsonArray.count];
    for (NSDictionary *dict in jsonArray) {
        NSManagedObject * managedObject = [self update:dict withEntityName:entityName];
        if (managedObject) {
            [array addObject:managedObject];
        }
    }
    return array;
}


- (BOOL)save
{
    NSError *error;
    BOOL succeed = [managedObjectContext save:&error];
    if (succeed == NO) {
        [managedObjectContext.undoManager undo];
    }
#ifdef IS_DEBUG
    if (succeed == NO) {
        NSLog(@"AGCoreDate.save: %@",error.userInfo);
    }
#endif
    return succeed;
}

- (void) remove:(NSManagedObject *)managedObject
{
    if (managedObject) {
        [managedObjectContext deleteObject:managedObject];
        [self save];
    }
}

- (void) removeAll:(NSArray *)array
{
    for (NSManagedObject *managedObject in array) {
         [managedObjectContext deleteObject:managedObject];
    }
    [self save];
}

- (NSManagedObject*) create:(Class)class
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(class) inManagedObjectContext:managedObjectContext];
}

- (NSManagedObject*) findById:(id)objectID withEntityName:(NSString*)entityName
{
    NSManagedObject *managedObject = nil;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSString *idKey = [entityDescription.userInfo objectForKey:@"IdKey"];
    NSPredicate *predicate;
    if (idKey) {
        predicate = [NSPredicate predicateWithFormat:@"%K = %@", idKey, objectID];
    }
    else{
        int idKeyCount = [[entityDescription.userInfo objectForKey:@"IdKeyCount"] intValue];
        NSMutableString *string = [NSMutableString stringWithCapacity:50];
        for (int i = 0; i < idKeyCount; ++i) {
            idKey = [entityDescription.userInfo objectForKey:[NSString stringWithFormat:@"IdKey%d", i + 1]];
            if (i > 0) {
                [string appendString:@" and "];
            }
            [string appendString:idKey];
            [string appendString:@" = "];
            [string appendFormat:@"%@",[objectID valueForKeyPath:idKey]];
            
        }
        assert(string.length);
        predicate = [NSPredicate predicateWithFormat:string];
    }
    
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
#ifdef IS_DEBUG
    if (error) {
        NSLog(@"%@", error.userInfo);
    }
#endif
    if (array.count) {
        managedObject = [array lastObject];
    }
    return managedObject;
}

- (BOOL) editAttributes:(NSDictionary*)attributeDictionary managedObject:(NSManagedObject *)managedObject
{
    [attributeDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [managedObject setValue:obj forKey:key];
    }];
    return [self save];
}

-(void) registerObserverForEntityName:(NSString*)entityName forKey:(NSString*)key count:(int) count
{
    observedEntityName = entityName;
    observedEntityKey = key;
    changedEntities = [NSMutableArray arrayWithCapacity:count];
}


- (NSArray*)unregisterObserver
{
    observedEntityName = observedEntityKey = nil;
    NSArray* array = changedEntities;
    changedEntities = nil;
    return array;
}

@end
