//
//  AGMessage.h
//  Airogami
//
//  Created by Tianhu Yang on 8/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONModel.h"

@class AGAccount, AGPlane;

@interface AGMessageJSON : JSONModel

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) AGAccount *account;
@property (nonatomic, retain) AGPlane *plane;

@end
