//
//  AGCoreDataManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGCoreData.h"
#import "AGAccount.h"
#import "AGProfile.h"
#import "AGPlane.h"

@interface AGAccountController : NSObject

- (AGAccount*) saveAccount:(NSDictionary*)jsonDictionary;
- (AGAccount*) findAccount:(NSNumber*)accountId;

@end
