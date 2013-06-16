//
//  AGLocation.m
//  Airogami
//
//  Created by Tianhu Yang on 6/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGLocation.h"

@implementation AGLocation
@synthesize country, area, subArea;


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

- (BOOL) validate
{
    if (country.length > 0 && area.length > 0 && subArea.length > 0) {
        return YES;
    }
    return NO;
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
    return [[AGLocation alloc] initWithCountry:places[0] area:places[1] subArea:places[2]];
}

+ (AGLocation*) location
{
    return [[AGLocation alloc] initWithCountry:@"" area:@"" subArea:@""];
}
@end
