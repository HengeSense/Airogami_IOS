//
//  AGUtils.h
//  Airogami
//
//  Created by Tianhu Yang on 6/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AGUtils : NSObject
+ (UIImage *)normalizeImage:(UIImage*)image;
+ (NSArray *)localizedStringArray:(NSString*)prefix count:(int) count;
@end
