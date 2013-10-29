//
//  AGUploadHttpHandler.h
//  Airogami
//
//  Created by Tianhu Yang on 8/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AGHttpUploadHandlerFinishBlock)(NSError* error, id context);

@class AGURLConnection;

@interface AGUploadHttpHandler : NSObject

+ (AGUploadHttpHandler*) handler;

- (AGURLConnection*) uploadData:(NSData*)data type:(AGContentTypeEnum)type params:(NSDictionary*)params context:(id)context block:(AGHttpUploadHandlerFinishBlock)block;

@end
