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

@interface AGControllerUtils : NSObject

@property(nonatomic, strong) AGAccountController *accountController;
@property(nonatomic, strong) AGPlaneController *planeController;
@property(nonatomic, strong) AGMessageController *messageController;

+ (AGControllerUtils*) controllerUtils;

@end
