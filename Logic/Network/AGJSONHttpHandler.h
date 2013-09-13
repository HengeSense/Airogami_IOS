//
//  AGHttpHandler.h
//  Airogami
//
//  Created by Tianhu Yang on 8/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGURLConnection.h"

typedef void (^AGHttpJSONHandlerFinishBlock)(NSError* error, id context, NSMutableDictionary* dict);
typedef void (^AGHttpJSONHandlerRequestFinishBlock)(NSError *error, id context, id result);

@interface AGJSONHttpHandler : NSObject

+ (AGJSONHttpHandler*) handler;

//get or post (no device)
+ (AGURLConnection*) request:(BOOL)get params:(NSDictionary*)params path:(NSString*)path prompt:(NSString*)prompt context:(id)context  block:(AGHttpJSONHandlerRequestFinishBlock)block;

//GET or POST
- (AGURLConnection*) start:(NSString*)path params:(NSDictionary*)dict device:(BOOL)device context:(id)context block:(AGHttpJSONHandlerFinishBlock)block;
//GET (no device)
- (AGURLConnection*) start:(NSString*)path context:(id)context block:(AGHttpJSONHandlerFinishBlock)block;
+ (AGURLConnection*) start:(NSDictionary*)dict;

@end
