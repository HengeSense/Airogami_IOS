//
//  AGChainMessageId.h
//  Airogami
//
//  Created by Tianhu Yang on 8/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONModel.h"

@class AGChainMessage;

@interface AGChainMessageIdJSON : JSONModel

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSNumber * chainId;
@property (nonatomic, retain) AGChainMessage *chainMessage;

@end
