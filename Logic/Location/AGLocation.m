//
//  AGLocation.m
//  Airogami
//
//  Created by Tianhu Yang on 6/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGLocation.h"


@implementation AGLocation
@synthesize country, area, subArea, coordinate, position;


- (id) initWithCountry:(NSString*) aCountry area:(NSString*) anArea subArea:(NSString*) aSubArea coordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (self = [super init]) {
        country = aCountry;
        area = anArea;
        subArea = aSubArea;
        coordinate = aCoordinate;
    }
    return self;
}

- (id) initWithCountry:(NSString*) aCountry area:(NSString*) anArea subArea:(NSString*) aSubArea
{
    if (self = [super init]) {
        country = aCountry;
        area = anArea;
        subArea = aSubArea;
    }
    return self;
}

- (NSString*) toString
{
    NSMutableString *string = [NSMutableString stringWithString:country];
    if (area.length > 0) {
        [string insertString:@", " atIndex:0];
        [string insertString:area atIndex:0];
    }
    if (subArea.length > 0) {
        [string insertString:@", " atIndex:0];
        [string insertString:subArea atIndex:0];
    }
    return string;
}

- (NSString*) validString
{
    if (position > 2) {
        return NSLocalizedString(@"location.randomDestination", @"Random destination");
    }
    NSMutableString *string = [NSMutableString stringWithString:country];
    for (int i = 1; i >= position; --i) {
        [string insertString:@", " atIndex:0];
        [string insertString:[self stringAt:i] atIndex:0];
    }
    
    return string;
}

- (NSString*) stringAt:(int) index
{
    switch (index) {
        case 0:
            return self.subArea;
            break;
        case 1:
            return self.area;
            break;
        case 2:
            return self.country;
            break;
            
        default:
            return nil;
            break;
    }
}

- (BOOL) validate
{
    if (country.length > 0 && area.length > 0 && subArea.length > 0) {
        return YES;
    }
    return NO;
}

- (BOOL) empty
{
    return country.length == 0;
}

- (void) appendParam:(NSMutableDictionary*)params
{
    [params setObject:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:@"longitude"];
    [params setObject:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:@"latitude"];
    if (country) {
        [params setObject:country forKey:@"country"];
    }
    if (subArea) {
        [params setObject:subArea forKey:@"city"];
    }
    if (area) {
        [params setObject:area forKey:@"province"];
    }

}

+ (AGLocation*) locationWithProfile:(AGProfile*) profile
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [profile.latitude doubleValue];
    coordinate.longitude = [profile.longitude doubleValue];
    return [[AGLocation alloc] initWithCountry:profile.country area:profile.province subArea:profile.city coordinate:coordinate];
}

+ (AGLocation*) locationWithPlaceMark:(CLPlacemark*) placeMark
{
    NSString *places[] = {@"", @"", @""};
    NSString *texts[] = {placeMark.administrativeArea, placeMark.subAdministrativeArea, placeMark.locality, placeMark.subLocality};
    if (placeMark.country.length > 0) {
        places[0] = placeMark.country;
    }
    for (int i = 0, count = 1; i < 4 && count < 3; ++i) {
        if (texts[i].length > 0) {
            places[count] = texts[i];
            ++count;
        }
    }
    return [[AGLocation alloc] initWithCountry:places[0] area:places[1] subArea:places[2] coordinate:placeMark.location.coordinate];
}

+ (AGLocation*) location
{
    return [[AGLocation alloc] initWithCountry:@"" area:@"" subArea:@""];
}
@end
