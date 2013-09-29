//
//  AGSynchronize.h
//  Airogami
//
//  Created by Tianhu Yang on 9/27/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGSynchronizeDelegate <NSObject>

-(void) didFinish:(BOOL)succeed;

@end

@interface AGSynchronize : NSObject

@property(nonatomic, weak) id<AGSynchronizeDelegate> delegate;

-(BOOL) shouldSynchronize;

-(void) synchronize;

@end
