//
//  AGHot.h
//  Airogami
//
//  Created by Tianhu Yang on 10/24/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount, AGNeoHot;

@interface AGHot : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSNumber * likesCount;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) AGAccount *account;
@property (nonatomic, retain) AGNeoHot *neoHot;

@end
