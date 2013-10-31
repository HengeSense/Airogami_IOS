//
//  AGNeoProfile.h
//  Airogami
//
//  Created by Tianhu Yang on 10/24/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGProfile;

@interface AGNeoProfile : NSManagedObject

@property (nonatomic, retain) NSNumber * accountId;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) AGProfile *profile;

@end
