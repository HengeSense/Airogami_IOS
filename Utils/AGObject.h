//
//  AGObject.h
//  Airogami
//
//  Created by Tianhu Yang on 8/9/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGObject : NSObject<NSCoding>

//called by codingProperties;
- (NSArray *)propertyKeys;
//must be override
- (NSArray*) codingProperties;

@end
