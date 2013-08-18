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
static NSString *ReplyPlanePath = @"plane/replyPlane.action?";
static NSString *ReceivePlanesPath = @"plane/receivePlanes.action?";
static NSString *ObtainPlanesPath = @"plane/obtainPlanes.action?";
static NSString *ObtainMessagesPath = @"plane/obtainMessages.action?";


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

- (void) replyPlane:(NSDictionary*) params context:(id)context block:(AGReplyPlaneFinishBlock)block
{
    [AGJSONHttpHandler request:NO params:params path:ReplyPlanePath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        AGMessage *message = nil;
        if (error) {
            
        }
        else{
            //succeed
            NSDictionary *dict = [result objectForKey:@"message"];
            if ([dict isEqual:[NSNull null]] == NO) {
                message = [[AGControllerUtils controllerUtils].messageController saveMessage:dict];
            }
            else{
                NSLog(@"replyPlane failed");
                abort();
            }
        
        }
        if (block) {
            block(error, context, message);
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
            NSArray *planes = [[AGControllerUtils controllerUtils].planeController savePlanes:[result objectForKey:@"planes"]];
            for (AGPlane *plane in planes) {
                plane.isNew = [NSNumber numberWithBool:YES];
            }
        }
        if (block) {
            block(error, context, result);
        }
        
    }];
}

- (void) obtainMessages:(NSDictionary *)params context:(id)context block:(AGHttpFinishBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ObtainMessagesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
            //succeed
        }
        if (block) {
            block(error, context, result);
        }
        
    }];
}

- (NSDictionary*)paramsForReplyPlane:(NSNumber*)planeId content:(NSString*)content type:(int)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:planeId forKey:@"planeId"];
    [params setObject:content forKey:@"messageVO.content"];
    [params setObject:[NSNumber numberWithInteger:type] forKey:@"messageVO.type"];
    return params;
}

@end
