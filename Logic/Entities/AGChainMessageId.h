//
//  AGChainMessageId.h
//  Airogami
//
//  Created by Tianhu Yang on 8/9/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGChainMessage;

@interface AGChainMessageId : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSNumber * chainId;
@property (nonatomic, retain) AGChainMessage *chainMessage;

@end
