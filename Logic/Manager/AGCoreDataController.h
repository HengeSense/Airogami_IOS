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

@interface AGCoreDataController : NSObject

@property(nonatomic, strong) AGCoreData * coreData;

- (AGAccount*) saveAccount:(NSMutableDictionary*)jsonDictionary;

@end
