//
//  AGViewManager.h
//  Airogami
//
//  Created by Tianhu Yang on 9/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGViewManager : NSObject

+(AGViewManager*)viewManager;

-(void) registerView:(UIView*)view;

-(void) unregisterView:(UIView*)view;

-(void) removeAllViews;

@end
