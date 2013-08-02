//
//  AGHttpHandler.h
//  Airogami
//
//  Created by Tianhu Yang on 8/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AGHttpJSONHandlerFinishBlock)(NSError* error, NSMutableDictionary* dict);

@interface AGJSONHttpHandler : NSObject

+ (AGJSONHttpHandler*) handler;

- (NSURLConnection*) start:(NSString*)path block:(AGHttpJSONHandlerFinishBlock)block;

@end
