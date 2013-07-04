//
//  AGPlaneCategory.h
//  Airogami
//
//  Created by Tianhu Yang on 7/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGPlaneCategory : NSObject

@property(nonatomic, strong) NSNumber *categoryId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *description;

-(id) initWithId:(int)ID name:(NSString*)name description:(NSString*) aDescription;

+(void) initialize;
+(AGPlaneCategory*) categoryWithId:(int)ID;
@end
