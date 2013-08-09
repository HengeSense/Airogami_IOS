//
//  AGLocation.h
//  Airogami
//
//  Created by Tianhu Yang on 6/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AGProfile.h"

@interface AGLocation : NSObject

@property(nonatomic, strong) NSString *country;
@property(nonatomic, strong) NSString *area;
@property(nonatomic, strong) NSString *subArea;
@property(nonatomic, assign) int position;// 0, 1, 2, 3 (empty)
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly) BOOL empty;

+ (AGLocation*) locationWithProfile:(AGProfile*) profile;
+ (AGLocation*) locationWithPlaceMark:(CLPlacemark*) placeMark;
+ (AGLocation*) location;
- (NSString*) toString;
- (NSString*) validString;
- (BOOL) validate;
- (NSString*) stringAt:(int) index;
- (void) appendParam:(NSMutableDictionary*)params;

@end
