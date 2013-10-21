//
//  AGNewChain.h
//  Airogami
//
//  Created by Tianhu Yang on 9/25/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGChain;

@interface AGNeoChain : NSManagedObject

@property (nonatomic, retain) NSNumber * chainId;
@property (nonatomic, retain) NSNumber * updateInc;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) AGChain *chain;

@end
