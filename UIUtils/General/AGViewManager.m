//
//  AGViewManager.m
//  Airogami
//
//  Created by Tianhu Yang on 9/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGViewManager.h"

@interface AGViewManager()
{
    NSMutableArray *views;
}

@end

@implementation AGViewManager

+(AGViewManager*)viewManager
{
    static AGViewManager *viewManager = nil;
    if (viewManager == nil) {
        viewManager = [[AGViewManager alloc] init];
    }
    return viewManager;
}

-(id)init
{
    if (self = [super init]) {
        views = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

-(void) registerView:(UIView*)view
{
    [views addObject:view];
}

-(void) unregisterView:(UIView*)view
{
    [views removeObject:view];
}

-(void) removeAllViews
{
    [views makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [views removeAllObjects];
}

@end
