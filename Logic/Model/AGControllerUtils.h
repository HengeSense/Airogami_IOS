//
//  AGControllerUtils.h
//  Airogami
//
//  Created by Tianhu Yang on 8/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGAccountController.h"
#import "AGPlaneController.h"
#import "AGMessageController.h"
#import "AGChainController.h"
#import "AGChainMessageController.h"

@interface AGControllerUtils : NSObject

@property(nonatomic, strong) AGAccountController *accountController;
@property(nonatomic, strong) AGPlaneController *planeController;
@property(nonatomic, strong) AGMessageController *messageController;
@property(nonatomic, strong) AGChainController *chainController;
@property(nonatomic, strong) AGChainMessageController *chainMessageController;

+ (AGControllerUtils*) controllerUtils;

@end
