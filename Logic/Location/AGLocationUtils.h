//
//  AGLocationUtils.h
//  Airogami
//
//  Created by Tianhu Yang on 6/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGLocation.h"

typedef void (^AGLocationUtilsResultBlock)(AGLocation *location, NSError *error);

@interface AGLocationUtils : NSObject
-(void) getCurrentLocation:(AGLocationUtilsResultBlock)block;
+ (void) transformLocation:(CLLocation *)location completion:(AGLocationUtilsResultBlock)block;
@end
