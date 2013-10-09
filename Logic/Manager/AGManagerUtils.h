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
#import "AGPlaneManager.h"
#import "AGChainManager.h"
#import "AGAudioManager.h"
#import "AGNetworkManager.h"

@interface AGManagerUtils : NSObject

+ (AGManagerUtils*) managerUtils;

@property(nonatomic, strong) AGAccountManager *accountManager;
@property(nonatomic, strong) AGProfileManager *profileManager;
@property(nonatomic, strong) AGDataManger *dataManager;
@property(nonatomic, strong) AGPlaneManager *planeManager;
@property(nonatomic, strong) AGChainManager *chainManager;
@property(nonatomic, strong) AGAudioManager *audioManager;
@property(nonatomic, strong) AGNetworkManager *networkManager;

@end
