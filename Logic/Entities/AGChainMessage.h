//
//  AGChainMessage.h
//  Airogami
//
//  Created by Tianhu Yang on 10/21/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount, AGChain, AGChainMessageId;

@interface AGChainMessage : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSDate * lastViewedTime;
@property (nonatomic, retain) NSDate * mineLastTime;
@property (nonatomic, retain) NSNumber * source;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * unreadChainMessagesCount;
@property (nonatomic, retain) NSNumber * updateInc;
@property (nonatomic, retain) AGAccount *account;
@property (nonatomic, retain) AGChain *chain;
@property (nonatomic, retain) AGChainMessageId *id;
@property (nonatomic, retain) AGChain *onChain;

@end
