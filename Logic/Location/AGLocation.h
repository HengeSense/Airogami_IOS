//
//  AGLocation.h
//  Airogami
//
//  Created by Tianhu Yang on 6/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AGLocation : NSObject
@property(nonatomic, strong) NSString *country;
@property(nonatomic, strong) NSString *area;
@property(nonatomic, strong) NSString *subArea;
@property(nonatomic, assign) int position;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
+ (AGLocation*) locationWithPlaceMark:(CLPlacemark*) placeMark;
+ (AGLocation*) location;
- (NSString*) toString;
- (BOOL) validate;
- (NSString*) stringAt:(int) index;
@end
