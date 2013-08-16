//
//  AGChainManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChainManager.h"
#import "AGJSONHttpHandler.h"
#import "AGMessageUtils.h"

static NSString *SendChainPath = @"chain/sendChain.action?";

@implementation AGChainManager

- (void) sendChain:(NSDictionary *)params context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:SendChainPath prompt:@"" context:context block:^(NSError *error, id context, NSNumber *result) {
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

@end
