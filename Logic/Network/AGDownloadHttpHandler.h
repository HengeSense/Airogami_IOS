//
//  AGDownloadHttpHandler.h
//  Airogami
//
//  Created by Tianhu Yang on 8/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGURLConnection.h"

typedef void (^AGDownloadHttpHandlerFinishBlock)(NSError* error, id data, id context);

@interface AGDownloadHttpHandler : NSObject

+ (AGDownloadHttpHandler*) handler;

- (NSURLConnection*) start:(NSString*)path context:(id)context block:(AGDownloadHttpHandlerFinishBlock)block;

@end
