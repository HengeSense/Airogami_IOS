//
//  AGNetworkManager.h
//  Airogami
//
//  Created by Tianhu Yang on 10/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AGURLConnection;

@interface AGNetworkManager : NSObject

-(void) addURLConnection:(AGURLConnection*)connection;
-(void) removeURLConnection:(AGURLConnection*)connection;
-(void) cancelAllURLConnections;

@end
