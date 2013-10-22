//
//  AGMessage.h
//  Airogami
//
//  Created by Tianhu Yang on 10/21/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount, AGPlane;

@interface AGMessage : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) AGAccount *account;
@property (nonatomic, retain) AGPlane *plane;
@property (nonatomic, retain) AGPlane *onPlane;

@end
