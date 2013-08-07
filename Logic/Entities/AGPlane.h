//
//  AGPlane.h
//  Airogami
//
//  Created by Tianhu Yang on 8/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount, AGCategory, AGMessage;

@interface AGPlane : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSNumber * deletedByOwner;
@property (nonatomic, retain) NSNumber * deletedByTarget;
@property (nonatomic, retain) NSNumber * lastMsgIdOfOwner;
@property (nonatomic, retain) NSNumber * lastMsgIdOfTarget;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * likedByOwner;
@property (nonatomic, retain) NSNumber * likedByTarget;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * matchCount;
@property (nonatomic, retain) NSNumber * maxMatchCount;
@property (nonatomic, retain) NSNumber * planeId;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) AGAccount *accountByOwnerId;
@property (nonatomic, retain) AGAccount *accountByTargetId;
@property (nonatomic, retain) AGCategory *category;
@property (nonatomic, retain) NSSet *messages;
@end

@interface AGPlane (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(AGMessage *)value;
- (void)removeMessagesObject:(AGMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
