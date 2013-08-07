//
//  AGChainMessage.h
//  Airogami
//
//  Created by Tianhu Yang on 8/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONModel.h"

@class AGAccount, AGChain, AGChainMessageId;

@interface AGChainMessageJSON : JSONModel

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) AGAccount *account;
@property (nonatomic, retain) AGChain *chain;
@property (nonatomic, retain) AGChainMessageId *id;

@end
