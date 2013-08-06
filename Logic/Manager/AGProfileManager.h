//
//  AGProfileManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AGUploadIconFinishBlock)(NSError* error, id context);

@interface AGProfileManager : NSObject

- (void) uploadIcons:(NSMutableDictionary*)params image:(UIImage*)image context:(id)context block:(AGUploadIconFinishBlock)block;

@end
