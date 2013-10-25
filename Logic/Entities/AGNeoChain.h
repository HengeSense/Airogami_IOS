//
//  AGNeoChain.h
//  Airogami
//
//  Created by Tianhu Yang on 10/24/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGChain;

@interface AGNeoChain : NSManagedObject

@property (nonatomic, retain) NSNumber * chainId;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) NSNumber * updateInc;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) AGChain *chain;

@end
