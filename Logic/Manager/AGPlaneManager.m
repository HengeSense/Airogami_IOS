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
#import "NSBubbleData.h"
#import "AGManagerUtils.h"
#import "AGNotificationCenter.h"

static NSString *SendPlanePath = @"plane/sendPlane.action?";
static NSString *ReplyPlanePath = @"plane/replyPlane.action?";
static NSString *ThrowPlanePath = @"plane/throwPlane.action?";
static NSString *PickupPath = @"plane/pickup.action?";
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

- (void) replyPlane:(AGMessage*) message context:(id)context block:(AGReplyPlaneFinishBlock)block
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:message.plane.planeId forKey:@"planeId"];
    [params setObject:message.content forKey:@"messageVO.content"];
    [params setObject:message.type forKey:@"messageVO.type"];
    [AGJSONHttpHandler request:NO params:params path:ReplyPlanePath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        AGMessage *remoteMessage = nil;
        if (error) {
            
        }
        else{
            //succeed
            NSDictionary *dict = [result objectForKey:@"message"];
            if ([dict isEqual:[NSNull null]] == NO) {
                remoteMessage = [[AGControllerUtils controllerUtils].messageController saveMessage:dict];
                
            }
            else{
                NSLog(@"replyPlane failed");
                abort();
            }
        }
        if (remoteMessage) {
            [[AGControllerUtils controllerUtils].planeController increaseUpdateInc:message.plane];
            [[AGCoreData coreData] remove:message];
            [[AGNotificationCenter notificationCenter] obtainedPlanes];
        }
        else{
            message.state = [NSNumber numberWithInt:BubbleCellStateSendFailed];
            [[AGCoreData coreData] save];
        }
        if (block) {
            block(error, context, remoteMessage);
        }
        
    }];
}

- (void) firstReplyPlane:(NSDictionary*)params plane:(AGPlane*)plane context:(id)context block:(AGReplyPlaneFinishBlock)block
{
    [AGJSONHttpHandler request:NO params:params path:ReplyPlanePath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        AGMessage *remoteMessage = nil;
        if (error) {
            
        }
        else{
            //succeed
            NSDictionary *dict = [result objectForKey:@"message"];
            if ([dict isEqual:[NSNull null]] == NO) {
                remoteMessage = [[AGControllerUtils controllerUtils].messageController saveMessage:dict];
                plane.status = [NSNumber numberWithInt:AGPlaneStatusReplied];
                [[AGCoreData coreData] save];
            }
            else{
                NSLog(@"firstReplyPlane failed");
                abort();
            }
        }
        if (remoteMessage) {
            [[AGControllerUtils controllerUtils].planeController increaseUpdateInc:plane];
            [[AGNotificationCenter notificationCenter] obtainedPlanes];
            [[AGNotificationCenter notificationCenter] collectedPlanes];
        }
        else{

        }
        if (block) {
            block(error, context, remoteMessage);
        }
        
    }];
}

- (void) throwPlane:(NSDictionary*) params plane:(AGPlane*)plane context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ThrowPlanePath prompt:@"" context:context block:^(NSError *error, id context, NSNumber *result) {
        if (error) {
            
        }
        else{
            if (result.boolValue) {
                //[AGMessageUtils alertMessageWithTitle:@"" message:NSLocalizedString(AGPlaneSendPlaneOK, AGPlaneSendPlaneOK)];
                [[AGCoreData coreData] remove:plane];
                [[AGNotificationCenter notificationCenter] collectedPlanes];
            }
            else{
                //failed
                abort();
            }
            
        }
        if (block) {
            block(error, context);
        }
        
    }];
}

- (void) pickupPlaneAndChain:(NSDictionary *)params context:(id)context block:(AGPickupPlaneAndChainFinishBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:PickupPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSNumber *count = [NSNumber numberWithInt:0];
        if (error) {
            
        }
        else{
            //succeed
            NSArray *planes = [[AGControllerUtils controllerUtils].planeController savePlanes:[result objectForKey:@"planes"]];
            if (planes.count) {
                [[AGNotificationCenter notificationCenter] collectedPlanes];
            }
            NSArray *chains = [[AGControllerUtils controllerUtils].chainController saveChains:[result objectForKey:@"chains"]];
            if (chains.count) {
                //add additional code here
            }
            count = [NSNumber numberWithInt:planes.count + chains.count];
        }
        if (block) {
            block(error, context, count);
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

- (NSDictionary*)paramsForThrowPlane:(NSNumber*)planeId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:planeId forKey:@"planeId"];
    return params;
}

- (NSDictionary*)paramsForReplyPlane:(NSNumber*)planeId content:(NSString*)content type:(int)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:planeId forKey:@"planeId"];
    [params setObject:content forKey:@"messageVO.content"];
    [params setObject:[NSNumber numberWithInteger:type] forKey:@"messageVO.type"];
    return params;
}

- (AGMessage*)messageForReplyPlane:(AGPlane*)plane content:(NSString*)content type:(int)type
{
    AGCoreData *coreData = [AGCoreData coreData];
    AGMessage *message = (AGMessage *)[coreData create:[AGMessage class]];
    message.account = [AGManagerUtils managerUtils].accountManager.account;
    message.messageId = [NSNumber numberWithInt:-1];
    message.createdTime = [NSDate dateWithTimeIntervalSinceNow:0];
    message.plane = plane;
    message.content = content;
    message.type = [NSNumber numberWithInt:type];
    message.state = [NSNumber numberWithInt:BubbleCellStateSending];
    [coreData save];
    return message;
}

@end
