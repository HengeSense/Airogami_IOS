//
//  AGURLConnection.h
//  Airogami
//
//  Created by Tianhu Yang on 8/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AGURLConnectionFinishBlock)(NSError *error, id context, id result);

@interface AGURLConnection : NSURLConnection

@end
