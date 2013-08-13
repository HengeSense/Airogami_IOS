//
//  AGProfileManager.h
//  Airogami
//
//  Created by Tianhu Yang on 8/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGProfileManager : NSObject

- (void) uploadIcons:(NSDictionary*)params image:(UIImage*)image context:(id)context block:(AGHttpDoneBlock)block;

- (void) editProfile:(NSDictionary*)params image:(UIImage*)image context:(id)context block:(AGHttpDoneBlock)block;

@end
