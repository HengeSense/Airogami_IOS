//
//  AGLocationUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 6/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGLocationUtils.h"
#import <CoreLocation/CoreLocation.h>
#import "CLController.h"
#import "NSArray+Addition.h"
#import "AGUtils.h"

@interface AGLocationUtils()<CLControllerDelegate>
{
    CLGeocoder *geocoder;
    CLController *clController;
    AGLocationUtilsResultBlock block;
}
@end

@implementation AGLocationUtils

- (id) init
{
    if (self = [super init]) {
        geocoder = [[CLGeocoder alloc] init];
        clController = [[CLController alloc] init];
        clController.delegate = self;
    }
    return self;
}

-(void) getCurrentLocation:(AGLocationUtilsResultBlock)aBlock
{
    block = aBlock;
    [clController start];
}

- (void)locationUpdate:(CLLocation *)location withError:(NSError *)error
{
    if (error) {
        block(nil, error);
    }
    else{
        [geocoder reverseGeocodeLocation:location completionHandler:
         ^(NSArray *placemarks, NSError *error) {
            if (error) {
                block(nil, error);
            } else {
                CLPlacemark *placemark = [placemarks onlyObject];
                block([AGLocation locationWithPlaceMark:placemark], error);
            }
        }];
    }
}

+ (void) transformLocation:(CLLocation *)location completion:(AGLocationUtilsResultBlock)block
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         if (error) {
             block(nil, error);
         } else {
             CLPlacemark *placemark = [placemarks onlyObject];
             block([AGLocation locationWithPlaceMark:placemark], error);
         }
     }];
}
@end
