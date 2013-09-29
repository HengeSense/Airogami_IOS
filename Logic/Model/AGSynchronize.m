//
//  AGSynchronize.m
//  Airogami
//
//  Created by Tianhu Yang on 9/27/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGSynchronize.h"
#import "AGControllerUtils.h"
#import "AGManagerUtils.h"
#import "AGWaitUtils.h"
#import "AGAccountStat.h"

static NSString *Title = @"message.synchronize.title";

@interface AGSynchronize()
{
    NSNumber *planeId;
    NSNumber *chainId;
    BOOL planeDone, chainDone, failure;
}

@end

@implementation AGSynchronize

@synthesize delegate;

-(BOOL) shouldSynchronize
{
    return [AGManagerUtils managerUtils].accountManager.account.accountStat.synchronizing.boolValue;
}

-(void) synchronize
{
    planeId = chainId = nil;
    failure = planeDone = chainDone = NO;
    //
    [[AGControllerUtils controllerUtils].planeController resetForSync];
    [[AGControllerUtils controllerUtils].chainController resetForSync];
    [AGWaitUtils startWait:Title];
    [self synchronizePlanes];
    [self synchronizeChains];
}

- (void) synchronizePlanes
{
    AGPlaneManager *planeManager = [AGManagerUtils managerUtils].planeManager;
    NSDictionary *params = [planeManager paramsForGetOldPlanes:planeId end:nil limit:nil];
    [planeManager getOldPlanes:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *oldPlanes) {
        if (error == nil) {
            NSArray *oldPlanesJson = [result objectForKey:@"oldPlanes"];
            NSDictionary *oldPlaneJson = oldPlanesJson.lastObject;
            planeId = [oldPlaneJson objectForKey:@"planeId"];
            //
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue && failure == NO) {
                [self synchronizePlanes];
            }
            else{
                planeDone = YES;
                if (chainDone) {
                    [self finish:YES];
                }
            }
        }
        else{
            //should deal with server error
            if (failure == NO) {
                failure = YES;
                [self finish:NO];
            }
        }
    }];
}

- (void) synchronizeChains
{
    AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
    NSDictionary *params = [chainManager paramsForGetOldChains:chainId end:nil limit:nil];
    [chainManager getOldChains:params context:nil block:^(NSError *error, id context, NSMutableDictionary *result, NSArray *oldChains) {
        if (error == nil) {
            NSArray *oldChainsJson = [result objectForKey:@"oldChains"];
            NSDictionary *oldChainJson = oldChainsJson.lastObject;
            chainId = [oldChainJson objectForKey:@"chainId"];
            //
            NSNumber *more = [result objectForKey:@"more"];
            if (more.boolValue && failure == NO) {
                [self synchronizeChains];
            }
            else{
                chainDone = YES;
                if (planeDone) {
                    [self finish:YES];
                }
            }
        }
        else{
            //should deal with server error
            if (failure == NO) {
                failure = YES;
                [self finish:NO];
            }
            
        }
    }];
}

- (void) finish:(BOOL)succeed
{
    if (succeed) {
        [[AGControllerUtils controllerUtils].planeController deleteForSync];
        [[AGControllerUtils controllerUtils].chainController deleteForSync];
        [[AGControllerUtils controllerUtils].accountController setSynchronizing:NO];
    }
    [AGWaitUtils startWait:nil];
    [delegate didFinish:succeed];
}

@end
