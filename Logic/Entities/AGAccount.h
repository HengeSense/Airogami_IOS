//
//  AGAccount.h
//  Airogami
//
//  Created by Tianhu Yang on 8/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccountStat, AGAuthenticate, AGChain, AGChainMessage, AGMessage, AGPlane, AGProfile;

@interface AGAccount : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) AGAccountStat *accountStat;
@property (nonatomic, retain) AGAuthenticate *authenticate;
@property (nonatomic, retain) NSSet *chainMessages;
@property (nonatomic, retain) NSSet *chains;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSSet *planesForOwnerId;
@property (nonatomic, retain) NSSet *planesForTargetId;
@property (nonatomic, retain) AGProfile *profile;
@end

@interface AGAccount (CoreDataGeneratedAccessors)

- (void)addChainMessagesObject:(AGChainMessage *)value;
- (void)removeChainMessagesObject:(AGChainMessage *)value;
- (void)addChainMessages:(NSSet *)values;
- (void)removeChainMessages:(NSSet *)values;

- (void)addChainsObject:(AGChain *)value;
- (void)removeChainsObject:(AGChain *)value;
- (void)addChains:(NSSet *)values;
- (void)removeChains:(NSSet *)values;

- (void)addMessagesObject:(AGMessage *)value;
- (void)removeMessagesObject:(AGMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addPlanesForOwnerIdObject:(AGPlane *)value;
- (void)removePlanesForOwnerIdObject:(AGPlane *)value;
- (void)addPlanesForOwnerId:(NSSet *)values;
- (void)removePlanesForOwnerId:(NSSet *)values;

- (void)addPlanesForTargetIdObject:(AGPlane *)value;
- (void)removePlanesForTargetIdObject:(AGPlane *)value;
- (void)addPlanesForTargetId:(NSSet *)values;
- (void)removePlanesForTargetId:(NSSet *)values;

@end
