//
//  AGDataManger.h
//  Airogami
//
//  Created by Tianhu Yang on 8/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGProfileImageButton.h"
#import "AGProfileImage.h"

typedef void (^AGMessageDataTokenBlock)(NSError *error, id context, NSDictionary *token);

@interface AGDataManger : NSObject

- (NSURL*) accountIconUrl:(NSNumber*)accountId small:(BOOL) small;
- (NSURL*) messageDataUrl:(NSNumber*)accountId msgDataInc:(NSNumber*)msgDataInc type:(AGMessageTypeEnum) type;
- (void) messageDataToken:(NSDictionary *)params context:(id)context block:(AGMessageDataTokenBlock)block;
- (void) uploadData:(NSData *)data params:(NSDictionary *)params type:(AGContentTypeEnum)type context:(id)context block:(AGHttpDoneBlock)block;
- (NSDictionary*)paramsForMessageDataToken:(NSNumber*)type;

@end
