//
//  AGControllerUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 8/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGControllerUtils.h"

@implementation AGControllerUtils

@synthesize accountController;
@synthesize planeController;

+ (AGControllerUtils*) controllerUtils
{
    static AGControllerUtils *controllerUtils;
    if (controllerUtils == nil) {
        controllerUtils =[[AGControllerUtils alloc] init];
    }
    return controllerUtils;
}

-(id)init
{
    if (self = [super init]) {
        accountController = [[AGAccountController alloc] init];
        planeController = [[AGPlaneController alloc] init];
    }
    return self;
}

@end
