//
//  AGPlaneManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPlaneManager.h"
#import "AGJSONHttpHandler.h"
#import "AGMessageUtils.h"
#import "AGControllerUtils.h"

static NSString *SendPlanePath = @"plane/sendPlane.action?";
static NSString *ReceivePlanesPath = @"plane/receivePlanes.action?";
static NSString *ObtainPlanesPath = @"plane/obtainPlanes.action?";

@implementation AGPlaneManager

- (void) sendPlane:(NSDictionary *)params context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:SendPlanePath prompt:@"" context:context block:^(NSError *error, id context, NSNumber *result) {
        if (error) {
            
        }
        else{
            if (result.boolValue) {
                 [AGMessageUtils alertMessageWithTitle:@"" message:NSLocalizedString(AGPlaneSendPlaneOK, AGPlaneSendPlaneOK)];
            }
            else{
                //failed
            }
        
        }
        if (block) {
            block(error, context);
        }
        
    }];
}

- (void) receivePlanes:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ReceivePlanesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
            //succeed
            [[AGControllerUtils controllerUtils].planeController savePlanes:[result objectForKey:@"planes"]];
        }
        if (block) {
            block(error, context, result);
        }
        
    }];
}

- (void) obtainPlanes:(NSDictionary*) params context:(id)context block:(AGHttpFinishBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ObtainPlanesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
            //succeed
            [[AGControllerUtils controllerUtils].planeController savePlanes:[result objectForKey:@"planes"]];
        }
        if (block) {
            block(error, context, result);
        }
        
    }];
}

@end
