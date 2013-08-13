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

static NSString *SendPlanePath = @"plane/sendPlane.action?";
static NSString *ReceivePlanesPath = @"plane/receivePlanes.action?";

@implementation AGPlaneManager

- (void) sendPlane:(NSDictionary *)params context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:params path:SendPlanePath prompt:@"" context:context block:^(NSError *error, id context, NSNumber *result) {
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
    [AGJSONHttpHandler request:params path:ReceivePlanesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
            
        }
        if (block) {
            block(error, context, result);
        }
        
    }];
}

@end
