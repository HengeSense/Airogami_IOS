//
//  AGHot.h
//  Airogami
//
//  Created by Tianhu Yang on 10/23/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount;

@interface AGHot : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) NSNumber * likesCount;
@property (nonatomic, retain) AGAccount *account;

@end
