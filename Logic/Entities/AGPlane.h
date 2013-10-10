//
//  AGPlane.h
//  Airogami
//
//  Created by Tianhu Yang on 10/9/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount, AGCategory, AGMessage, AGNewPlane;

@interface AGPlane : NSManagedObject

@property (nonatomic, retain) NSDate * birthdayLower;
@property (nonatomic, retain) NSDate * birthdayUpper;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * deletedByO;
@property (nonatomic, retain) NSNumber * deletedByT;
@property (nonatomic, retain) NSNumber * lastMsgIdOfO;
@property (nonatomic, retain) NSNumber * lastMsgIdOfT;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * likedByO;
@property (nonatomic, retain) NSNumber * likedByT;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * matchCount;
@property (nonatomic, retain) NSNumber * maxMatchCount;
@property (nonatomic, retain) NSNumber * ownerViewedMsgId;
@property (nonatomic, retain) NSNumber * planeId;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * source;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * targetViewedMsgId;
@property (nonatomic, retain) NSNumber * unreadMessagesCount;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) NSNumber * ownerInc;
@property (nonatomic, retain) NSNumber * targetInc;
@property (nonatomic, retain) AGAccount *accountByOwnerId;
@property (nonatomic, retain) AGAccount *accountByTargetId;
@property (nonatomic, retain) AGCategory *category;
@property (nonatomic, retain) AGMessage *message;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) AGNewPlane *newPlane;
@end

@interface AGPlane (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(AGMessage *)value;
- (void)removeMessagesObject:(AGMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
