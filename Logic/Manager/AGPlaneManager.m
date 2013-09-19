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
static NSString *DeletePlanePath = @"plane/deletePlane.action?";
static NSString *ReplyPlanePath = @"plane/replyPlane.action?";
static NSString *ThrowPlanePath = @"plane/throwPlane.action?";
static NSString *PickupPath = @"plane/pickup.action?";
static NSString *ReceivePlanesPath = @"plane/receivePlanes.action?";
static NSString *ObtainPlanesPath = @"plane/obtainPlanes.action?";
static NSString *ObtainMessagesPath = @"plane/obtainMessages.action?";
static NSString *ViewedMessagesPath = @"plane/viewedMessages.action?";


@implementation AGPlaneManager

- (void) sendPlane:(NSDictionary *)params context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:SendPlanePath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {//error,plane
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                error = [AGMessageUtils errorServer];
                [AGMessageUtils alertMessageWithError:error];
            }
            else{
                [AGMessageUtils alertMessageWithTitle:@"" message:NSLocalizedString(AGPlaneSendPlaneOK, AGPlaneSendPlaneOK)];
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
        BOOL refresh = NO;
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGCoreData coreData] remove:message.plane];
                }
                [[AGPlaneNotification planeNotification] obtainedPlanes];
                [AGMessageUtils alertMessagePlaneChanged];
                refresh = YES;
                //error = [AGMessageUtils errorClient];
            }
            else{
                //succeed
                //result = [result objectForKey:AGLogicJSONErrorKey];
                NSDictionary *dict = [result objectForKey:@"message"];
                remoteMessage = [[AGControllerUtils controllerUtils].messageController saveMessage:dict];
                [[AGControllerUtils controllerUtils].planeController increaseUpdateIncForChat:message.plane];
                message.plane.updatedTime = remoteMessage.createdTime;
                [[AGCoreData coreData] remove:message];
                [[AGPlaneNotification planeNotification] obtainedPlanes];
            }
            
        }
        if (block) {
            block(error, context, remoteMessage, refresh);
        }
        
    }];
}

- (void) firstReplyPlane:(NSDictionary*)params plane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block
{
    [AGJSONHttpHandler request:NO params:params path:ReplyPlanePath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        AGMessage *remoteMessage = nil;
        BOOL succeed = NO;
        if (error) {
            
        }
        else{
            succeed = YES;
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGCoreData coreData] remove:plane];
                }
                [[AGPlaneNotification planeNotification] collectedPlanes];
                [AGMessageUtils alertMessagePlaneChanged];
                //error = [AGMessageUtils errorClient];
            }
            else{
                //succeed
                NSDictionary *dict = [result objectForKey:@"message"];
                remoteMessage = [[AGControllerUtils controllerUtils].messageController saveMessage:dict];
                plane.status = [NSNumber numberWithInt:AGPlaneStatusReplied];
                plane.updatedTime = remoteMessage.createdTime;
                [[AGCoreData coreData] save];
                //
                [[AGControllerUtils controllerUtils].planeController increaseUpdateIncForChat:plane];
                [[AGPlaneNotification planeNotification] obtainedPlanes];
                [[AGPlaneNotification planeNotification] collectedPlanes];
            }
        }

        if (block) {
            block(error, context, succeed);
        }
        
    }];
}

- (void) throwPlane:(NSDictionary*) params plane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ThrowPlanePath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        BOOL succeed = NO;
        if (error) {
            
        }
        else{
            succeed = YES;
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGCoreData coreData] remove:plane];
                }
                NSDictionary *planeJson = [result objectForKey:@"plane"];
                //changed status, etc
                if (planeJson) {
                    [[AGControllerUtils controllerUtils].planeController savePlane:planeJson];
                    [AGMessageUtils alertMessagePlaneChanged];
                }
                [[AGPlaneNotification planeNotification] collectedPlanes];
                [[AGPlaneNotification planeNotification] obtainedPlanes];
                //error = [AGMessageUtils errorClient];
            }
            else{
                [[AGCoreData coreData] remove:plane];
                [[AGPlaneNotification planeNotification] collectedPlanes];
            }
            
        }
        if (block) {
            block(error, context, succeed);
        }
        
    }];
}

- (void) deletePlane:(NSDictionary*) params plane:(AGPlane*)plane context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:DeletePlanePath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGCoreData coreData] remove:plane];
                }
                NSDictionary *planeJson = [result objectForKey:@"plane"];
                //changed status, etc
                if (planeJson) {
                    [[AGControllerUtils controllerUtils].planeController savePlane:planeJson];
                    [AGMessageUtils alertMessagePlaneChanged];
                }
                //error = [AGMessageUtils errorClient];
            }
            else{
                //viewedMessagesForPlane
                NSDictionary *dict = [NSDictionary dictionaryWithObject:plane forKey:@"plane"];
                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationViewedMessagesForPlane object:nil userInfo:dict];
                //
                [[AGCoreData coreData] remove:plane];
            }
            
            [[AGPlaneNotification planeNotification] obtainedPlanes];
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
                for(AGPlane *plane in planes){
                    AGMessage *message = plane.messages.objectEnumerator.nextObject;
                    plane.targetViewedMsgId = message.messageId;
                }
                [[AGCoreData coreData] save];
                //
                [[AGPlaneNotification planeNotification] collectedPlanes];
            }
            NSArray *chains = [[AGControllerUtils controllerUtils].chainController saveChains:[result objectForKey:@"chains"] forCollect:YES];
            if (chains.count) {
                [[AGControllerUtils controllerUtils].chainController addNewChains:chains];
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AGNotificationObtainChainMessages object:self userInfo:nil];
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
            NSArray *planes = [[AGControllerUtils controllerUtils].planeController savePlanes:[result objectForKey:@"planes"]];
            for(AGPlane *plane in planes){
                AGMessage *message = plane.messages.objectEnumerator.nextObject;
                plane.targetViewedMsgId = message.messageId;
            }
            [[AGCoreData coreData] save];
        }
        if (block) {
            block(error, context, result);
        }
        
    }];
}

- (void) obtainPlanes:(NSDictionary*) params context:(id)context block:(AGObtainPlanesBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ObtainPlanesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *planes = [NSArray array];
        if (error) {
            
        }
        else{
            //succeed
            NSArray *planesJson = [result objectForKey:@"planes"];
            AGCoreData *coreData = [AGCoreData coreData];
            [coreData registerObserverForEntityName:@"AGAccount" forKey:@"updateCount" count:planesJson.count];
            planes = [[AGControllerUtils controllerUtils].planeController savePlanes:planesJson];
            NSArray *changedAccounts = [coreData unregisterObserver];
            if (changedAccounts.count) {
                AGAccountController *accountController = [AGControllerUtils controllerUtils].accountController;
                [accountController addNewAccounts:changedAccounts];
                NSDictionary *dict = [NSDictionary dictionary];
                [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainAccounts object:self userInfo:dict];
            }
        }
        if (block) {
            block(error, context, result, planes);
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

- (void) viewedMessages:(NSDictionary *)params context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ViewedMessagesPath prompt:nil context:context block:^(NSError *error, id context, NSNumber *result) {
        if (error) {
            
        }
        else{
#ifdef IS_DEBUG
            NSLog(@"PlaneManager.viewedMessages: result = %@", result);
#endif
        }
        if (block) {
            block(error, context);
        }
        
    }];
}

- (NSDictionary*)paramsForThrowPlane:(NSNumber*)planeId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:planeId forKey:@"planeId"];
    return params;
}

- (NSDictionary*)paramsForDeletePlane:(AGPlane*)plane
{
    BOOL byOwner = [plane.accountByOwnerId.accountId isEqual:[AGManagerUtils managerUtils].accountManager.account.accountId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:plane.planeId forKey:@"planeId"];
    [params setObject:[NSNumber numberWithBool:byOwner] forKey:@"byOwner"];
    return params;
}

- (NSDictionary*)paramsForViewedMessages:(AGPlane*)plane lastMsgId:(NSNumber*)lastMsgId
{
    BOOL byOwner = [plane.accountByOwnerId.accountId isEqual:[AGManagerUtils managerUtils].accountManager.account.accountId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:plane.planeId forKey:@"planeId"];
    [params setObject:[NSNumber numberWithBool:byOwner] forKey:@"byOwner"];
    [params setObject:lastMsgId forKey:@"lastMsgId"];
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
