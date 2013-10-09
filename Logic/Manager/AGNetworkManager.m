//
//  AGNetworkManager.m
//  Airogami
//
//  Created by Tianhu Yang on 10/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGNetworkManager.h"
#import "AGURLConnection.h"

@interface AGNetworkManager()
{
    NSMutableArray *connections;
}

@end

@implementation AGNetworkManager

-(id)init
{
    if (self = [super init]) {
        connections = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

-(void) addURLConnection:(AGURLConnection*)connection
{
    [connections addObject:connection];
}
-(void) removeURLConnection:(AGURLConnection*)connection
{
    [connections removeObject:connection];
}
-(void) cancelAllURLConnections
{
    [connections makeObjectsPerformSelector:@selector(cancel)];
    [connections removeAllObjects];
}

@end
