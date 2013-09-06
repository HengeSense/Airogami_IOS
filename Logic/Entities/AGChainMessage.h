//
//  AGChainMessage.h
//  Airogami
//
//  Created by Tianhu Yang on 9/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount, AGChain, AGChainMessageId;

@interface AGChainMessage : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * lastViewedTime;
@property (nonatomic, retain) AGAccount *account;
@property (nonatomic, retain) AGChain *chain;
@property (nonatomic, retain) AGChainMessageId *id;

@end
