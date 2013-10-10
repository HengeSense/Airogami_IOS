//
//  AGChain.h
//  Airogami
//
//  Created by Tianhu Yang on 10/9/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount, AGChainMessage, AGNewChain;

@interface AGChain : NSManagedObject

@property (nonatomic, retain) NSDate * birthdayLower;
@property (nonatomic, retain) NSDate * birthdayUpper;
@property (nonatomic, retain) NSNumber * chainId;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * collected;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * matchCount;
@property (nonatomic, retain) NSNumber * maxMatchCount;
@property (nonatomic, retain) NSNumber * maxPassCount;
@property (nonatomic, retain) NSNumber * passCount;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) AGAccount *account;
@property (nonatomic, retain) AGChainMessage *chainMessage;
@property (nonatomic, retain) NSSet *chainMessages;
@property (nonatomic, retain) AGNewChain *newChain;
@end

@interface AGChain (CoreDataGeneratedAccessors)

- (void)addChainMessagesObject:(AGChainMessage *)value;
- (void)removeChainMessagesObject:(AGChainMessage *)value;
- (void)addChainMessages:(NSSet *)values;
- (void)removeChainMessages:(NSSet *)values;

@end
