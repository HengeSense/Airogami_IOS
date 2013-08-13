//
//  AGHttpHandler.h
//  Airogami
//
//  Created by Tianhu Yang on 8/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AGHttpJSONHandlerFinishBlock)(NSError* error, id context, NSMutableDictionary* dict);
typedef void (^AGHttpJSONHandlerRequestFinishBlock)(NSError *error, id context, id result);

@interface AGJSONHttpHandler : NSObject

+ (AGJSONHttpHandler*) handler;

+ (void) request:(NSDictionary*) params path:(NSString*)path prompt:(NSString*)prompt context:(id)context  block:(AGHttpJSONHandlerRequestFinishBlock)block;

- (NSURLConnection*) start:(NSString*)path context:(id)context block:(AGHttpJSONHandlerFinishBlock)block;

@end
