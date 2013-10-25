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
#import "AGUIUtils.h"
#import "AGUtils.h"
#import "AGAppDirector.h"

static NSString *SendPlanePath = @"plane/sendPlane.action?";
static NSString *DeletePlanePath = @"plane/deletePlane.action?";
static NSString *ReplyPlanePath = @"plane/replyPlane.action?";
static NSString *LikePlanePath = @"plane/likePlane.action?";
static NSString *ClearPlanePath = @"plane/clearPlane.action?";
static NSString *ThrowPlanePath = @"plane/throwPlane.action?";
static NSString *PickupPath = @"plane/pickup.action?";
static NSString *GetNeoPlanesPath = @"plane/getNeoPlanes.action?";
static NSString *GetPlanesPath = @"plane/getPlanes.action?";
static NSString *GetOldPlanesPath = @"plane/getOldPlanes.action?";
static NSString *ObtainMessagesPath = @"plane/obtainMessages.action?";
static NSString *ViewedMessagesPath = @"plane/viewedMessages.action?";

static NSString *AGPlanePickupLimit = @"message.plane.pickup.limit";

@implementation AGPlaneManager

- (void) sendPlane:(NSDictionary *)params context:(id)context block:(AGHttpDoneBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:SendPlanePath prompt:@"" context:context block:^(NSError *error, id context, NSMutableDictionary *result) {//error,plane
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                error = [AGMessageUtils errorClient];
                if ([errorString isEqualToString:@"limit"]) {
                    [AGMessageUtils alertMessageWithTitle:@"" message:AGPlaneSendPlaneLimit];
                }
                else{
                    [AGMessageUtils alertMessageWithError:error];
                }
                
            }
            else{
                [AGMessageUtils alertMessageWithTitle:@"" message:AGPlaneSendPlaneOK];
            }
            
            NSDictionary *accountStatJson = [result objectForKey:AGLogicJSONAccountStatLeftKey];
            [[AGControllerUtils controllerUtils].accountController saveAccountStat:accountStatJson];
        
        }
        if (block) {
            block(error, context);
        }
        
    }];
}

- (void) replyPlane:(AGMessage*) message context:(id)context block:(AGReplyPlaneFinishBlock)block
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    BOOL byOwner = [message.plane.accountByOwnerId.accountId isEqual:[AGAppDirector appDirector].account.accountId];
    [params setObject:message.plane.planeId forKey:@"planeId"];
    [params setObject:[NSNumber numberWithBool:byOwner] forKey:@"byOwner"];
    [params setObject:message.content forKey:@"messageVO.content"];
    [params setObject:message.type forKey:@"messageVO.type"];
    [AGJSONHttpHandler request:NO params:params path:ReplyPlanePath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        AGMessage *remoteMessage = nil;
        BOOL removed = NO;
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGPlaneNotification planeNotification] deletePlane:message.plane];
                    removed = YES;
                }
                NSDictionary *planeJson = [result objectForKey:@"plane"];
                //changed status, etc
                if (planeJson) {
                    [[AGControllerUtils controllerUtils].planeController savePlane:planeJson];
                }
                [[AGPlaneNotification planeNotification] obtainedPlanes];
                
                //error = [AGMessageUtils errorClient];
            }
            else{
                //succeed
                //result = [result objectForKey:AGLogicJSONErrorKey];
                NSDictionary *dict = [result objectForKey:@"message"];
                remoteMessage = [[AGControllerUtils controllerUtils].messageController saveMessage:dict];
                message.plane.updatedTime = remoteMessage.createdTime;
                [[AGControllerUtils controllerUtils].planeController updateMessage:message.plane];
                [[AGCoreData coreData] remove:message];
                //update plane order
                [[AGPlaneNotification planeNotification] obtainedPlanesReorder:remoteMessage.plane];
            }
            
        }
        if (block) {
            block(error, context, remoteMessage, removed);
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
                [[AGControllerUtils controllerUtils].planeController updateMessage:plane];
                //[[AGControllerUtils controllerUtils].planeController increaseUpdateInc];
                [[AGPlaneNotification planeNotification] obtainedPlanes];
                [[AGPlaneNotification planeNotification] collectedPlanes];
            }
        }

        if (block) {
            block(error, context, succeed);
        }
        
    }];
}

- (void) likePlane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    BOOL byOwner = [plane.accountByOwnerId.accountId isEqual:[AGAppDirector appDirector].account.accountId];
    [params setObject:plane.planeId forKey:@"planeId"];
    [params setObject:[NSNumber numberWithBool:byOwner] forKey:@"byOwner"];
    //
    [AGJSONHttpHandler request:NO params:params path:LikePlanePath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        BOOL succeed = NO;
        if (error) {
            
        }
        else{
            AGControllerUtils *controllerUtils = [AGControllerUtils controllerUtils];
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGPlaneNotification planeNotification] deletePlane:plane];
                    [[AGPlaneNotification planeNotification] obtainedPlanes];
                }
                NSDictionary *planeJson = [result objectForKey:@"plane"];
                //changed status, etc
                if (planeJson) {
                    [controllerUtils.planeController savePlane:planeJson];
                }
                
                error = [AGMessageUtils errorClient];
            }
            else{
                //succeed
                succeed = YES;
                NSDictionary *dict = [result objectForKey:@"message"];
                AGMessage *message = [controllerUtils.messageController saveMessage:dict];
                [controllerUtils.planeController updateLike:plane];
                //update plane order
                [[AGPlaneNotification planeNotification] obtainedPlanesReorder:plane];
                //append messages
                [[AGPlaneNotification planeNotification] appendMessages:[NSArray arrayWithObject:message] forPlane:plane];
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

- (void) clearPlane:(AGPlane*)plane context:(id)context block:(AGHttpSucceedBlock)block
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:plane.planeId forKey:@"planeId"];
    //
    [AGJSONHttpHandler request:NO params:params path:ClearPlanePath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        BOOL succeed = NO;
        if (error) {
            
        }
        else{
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGPlaneNotification planeNotification] deletePlane:plane];
                    [[AGPlaneNotification planeNotification] obtainedPlanes];
                }
                NSDictionary *planeJson = [result objectForKey:@"plane"];
                //changed status, etc
                if (planeJson) {
                    [[AGControllerUtils controllerUtils].planeController savePlane:planeJson];
                }
                
                error = [AGMessageUtils errorClient];
            }
            else{
                //succeed
                succeed = YES;
                NSNumber *clearMsgId = [result objectForKey:@"clearMsgId"];
                [[AGPlaneNotification planeNotification] clearPlane:plane clearMsgId:clearMsgId];
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
            AGPlaneController *planeController = [AGControllerUtils controllerUtils].planeController;
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                // not exist
                if ([errorString isEqual:AGLogicJSONNoneValue]) {
                    [[AGPlaneNotification planeNotification] deletePlane:plane];
                }
                NSDictionary *planeJson = [result objectForKey:@"plane"];
                //changed status, etc
                if (planeJson) {
                    [planeController savePlane:planeJson];
                    [AGMessageUtils alertMessagePlaneChanged];
                }
                //error = [AGMessageUtils errorClient];
            }
            else{
                [[AGPlaneNotification planeNotification] deletePlane:plane];
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
            [AGMessageUtils alertMessageWithFilteredError:error];
        }
        else{
            
            //succeed
            NSString *errorString = [result objectForKey:AGLogicJSONErrorKey];
            if (errorString) {
                error = [AGMessageUtils errorClient];
                if ([errorString isEqualToString:@"limit"]) {
                    [AGMessageUtils alertMessageWithTitle:@"" message:AGPlanePickupLimit];
                }
                else{
                    [AGMessageUtils alertMessageWithError:error];
                }
            }
            else{
                NSArray *planes = [[AGControllerUtils controllerUtils].planeController savePlanes:[result objectForKey:@"planes"]];
                if (planes.count) {
                    for(AGPlane *plane in planes){
                        AGMessage *message = plane.messages.objectEnumerator.nextObject;
                        //plane.targetViewedMsgId = plane.lastMsgIdOfT;
                        plane.message = message;
                    }
                    [[AGCoreData coreData] save];
                    //
                    [[AGPlaneNotification planeNotification] collectedPlanes];
                }
                NSArray *chains = [[AGControllerUtils controllerUtils].chainController saveChainsForCollect:[result objectForKey:@"chains"]];
                if (chains.count) {
                    [[AGControllerUtils controllerUtils].chainController addNeoChains:chains];
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:AGNotificationObtainChainMessages object:self userInfo:nil];
                }
                count = [NSNumber numberWithInt:planes.count + chains.count];
            }
            //update accountStat
            NSDictionary *accountStatJson = [result objectForKey:AGLogicJSONAccountStatLeftKey];
            [[AGControllerUtils controllerUtils].accountController saveAccountStat:accountStatJson];
            
        }
        if (block) {
            block(error, context, count);
        }
        
    }];
}

- (void) getNeoPlanes:(NSDictionary*) params context:(id)context block:(AGGetNeoPlanesBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:GetNeoPlanesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *neoPlanes = nil;
        if (error) {
            
        }
        else{
            //succeed
            neoPlanes = [[AGControllerUtils controllerUtils].planeController saveNeoPlanes:[result objectForKey:@"neoPlanes"]];
            /*for(AGPlane *plane in planes){
                AGMessage *message = plane.messages.objectEnumerator.nextObject;
                plane.targetViewedMsgId = message.messageId;
            }*/
        }
        if (block) {
            block(error, context, result, neoPlanes);
        }
        
    }];
}

- (void) getPlanes:(NSDictionary*) params context:(id)context block:(AGGetPlanesBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:GetPlanesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *planes = nil;
        if (error) {
            
        }
        else{
            //succeed
            NSArray *planesJson = [result objectForKey:@"planes"];
            AGCoreData *coreData = [AGCoreData coreData];
            [coreData registerObserverForEntityName:@"AGAccount" forKey:@"updateCount" count:planesJson.count];
            planes = [[AGControllerUtils controllerUtils].planeController savePlanes:planesJson];
            NSArray *changedAccounts = [coreData unregisterObserver];
            [[AGAccountNotification accountNotification] obtainAccountsForAccounts:changedAccounts];
            
            /*for(AGPlane *plane in planes){
                if (plane.status.intValue == AGPlaneStatusNew) {
                    AGMessage *message = plane.messages.objectEnumerator.nextObject;
                    plane.targetViewedMsgId = message.messageId;
                }
             }
            [[AGCoreData coreData] save];*/
        }
        if (block) {
            block(error, context, result, planes);
        }
        
    }];
}

- (void) getOldPlanes:(NSDictionary*) params context:(id)context block:(AGGetOldPlanesBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:GetOldPlanesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        NSArray *oldPlanes = nil;
        if (error) {
            [AGMessageUtils alertMessageWithFilteredError:error];
        }
        else{
            //succeed
            NSMutableArray *oldPlanesJson = [result objectForKey:@"oldPlanes"];
            oldPlanes = [[AGControllerUtils controllerUtils].planeController saveOldPlanes:oldPlanesJson];
        }
        if (block) {
            block(error, context, result, oldPlanes);
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

- (void) viewedMessages:(NSDictionary *)params context:(id)context block:(AGHttpFinishBlock)block
{
    [AGJSONHttpHandler request:YES params:params path:ViewedMessagesPath prompt:nil context:context block:^(NSError *error, id context, NSMutableDictionary *result) {
        if (error) {
            
        }
        else{
#ifdef IS_DEBUG
            NSLog(@"PlaneManager.viewedMessages: result = %@", result);
#endif
        }
        if (block) {
            block(error, context, result);
        }
        
    }];
}

- (NSDictionary*)paramsForGetNeoPlane:(NSNumber*)start end:(NSNumber*)end limit:(NSNumber*)limit
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    if (end) {
        [params setObject:end forKey:@"end"];
    }
    if (limit) {
        [params setObject:limit forKey:@"limit"];
    }
    
    return params;
}

- (NSDictionary*)paramsForGetPlanes:(NSArray*)planeIds updated:(BOOL)updated
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:planeIds forKey:@"planeIds"];
    [params setObject:[NSNumber numberWithBool:updated] forKey:@"updated"];
    
    return params;
}

- (NSDictionary*)paramsForGetOldPlanes:(NSNumber*)start end:(NSNumber*)end limit:(NSNumber*)limit
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    if (start) {
        [params setObject:start forKey:@"start"];
    }
    if (end) {
        [params setObject:end forKey:@"end"];
    }
    if (limit) {
        [params setObject:limit forKey:@"limit"];
    }
    
    return params;
}

- (NSDictionary*)paramsForThrowPlane:(NSNumber*)planeId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:planeId forKey:@"planeId"];
    return params;
}

- (NSDictionary*)paramsForDeletePlane:(AGPlane*)plane
{
    BOOL byOwner = [plane.accountByOwnerId.accountId isEqual:[AGAppDirector appDirector].account.accountId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:plane.planeId forKey:@"planeId"];
    [params setObject:[NSNumber numberWithBool:byOwner] forKey:@"byOwner"];
    return params;
}

- (NSDictionary*)paramsForViewedMessages:(AGPlane*)plane lastMsgId:(NSNumber*)lastMsgId
{
    BOOL byOwner = [plane.accountByOwnerId.accountId isEqual:[AGAppDirector appDirector].account.accountId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:plane.planeId forKey:@"planeId"];
    [params setObject:[NSNumber numberWithBool:byOwner] forKey:@"byOwner"];
    [params setObject:lastMsgId forKey:@"lastMsgId"];
    return params;
}

- (NSDictionary*)paramsForReplyPlane:(AGPlane*)plane content:(NSString*)content type:(int)type
{
    BOOL byOwner = [plane.accountByOwnerId.accountId isEqual:[AGAppDirector appDirector].account.accountId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:plane.planeId forKey:@"planeId"];
    [params setObject:content forKey:@"messageVO.content"];
    [params setObject:[NSNumber numberWithBool:byOwner] forKey:@"byOwner"];
    [params setObject:[NSNumber numberWithInteger:type] forKey:@"messageVO.type"];
    return params;
}

- (AGMessage*)messageForReplyPlane:(AGPlane*)plane content:(NSString*)content type:(int)type
{
    AGCoreData *coreData = [AGCoreData coreData];
    AGMessage *message = (AGMessage *)[coreData create:[AGMessage class]];
    message.account = [AGAppDirector appDirector].account;
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
