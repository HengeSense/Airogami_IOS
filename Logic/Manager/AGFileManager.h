//
//  AGFileManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/5/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGFileManager : NSObject

@property(nonatomic, strong) NSNumber *accountId;

+ (AGFileManager*)fileManager;

- (NSURL*) urlForData;
- (NSURL*) urlForDatabase;
- (NSURL*) urlForConfig;

@end
