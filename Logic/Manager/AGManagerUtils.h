//
//  AGManagerUtils.h
//  Airogami
//
//  Created by Tianhu Yang on 8/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGAccountManager.h"
#import "AGProfileManager.h"
#import "AGDataManger.h"

@interface AGManagerUtils : NSObject

+ (AGManagerUtils*) managerUtils;

@property(nonatomic, strong) AGAccountManager *accountManager;
@property(nonatomic, strong) AGProfileManager *profileManager;
@property(nonatomic, strong) AGDataManger *dataManager;

@end
