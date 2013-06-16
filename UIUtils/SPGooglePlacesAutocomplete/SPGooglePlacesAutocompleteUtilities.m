//
//  SPGooglePlacesAutocompleteUtilities.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/18/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompleteUtilities.h"

#define kSPPlacesAutocompleteOK @"OK"

SPGooglePlacesAutocompletePlaceType SPPlaceTypeFromDictionary(NSDictionary *placeDictionary) {
    return [[placeDictionary objectForKey:@"types"] containsObject:@"establishment"] ? SPPlaceTypeEstablishment : SPPlaceTypeGeocode;
}

NSString *SPBooleanStringForBool(BOOL boolean) {
    return boolean ? @"true" : @"false";
}

NSString *SPPlaceTypeStringForPlaceType(SPGooglePlacesAutocompletePlaceType type) {
    return (type == SPPlaceTypeGeocode) ? @"geocode" : @"establishment";
}

BOOL SPEnsureGoogleAPIKey() {
    BOOL userHasProvidedAPIKey = YES;
    if ([kGoogleAPIKey isEqualToString:@"YOUR_API_KEY"]) {
        userHasProvidedAPIKey = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"API Key Needed" message:@"Please replace kGoogleAPIKey with your Google API key." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    return userHasProvidedAPIKey;
}

void SPPresentAlertViewWithErrorAndTitle(NSError *error, NSString *title) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, title) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(kSPPlacesAutocompleteOK, kSPPlacesAutocompleteOK) otherButtonTitles:nil];
    [alert show];
}
BOOL SPIsEmptyString(NSString *string) {
    return !string || ![string length];
}

void SplitAddress(NSString *address, NSMutableArray *items){
    NSArray *array = [address componentsSeparatedByString:@","];
    for (int i = 2, index = 0; i > -1; --i) {
        index = array.count - ( 3 - i);
        if (index > -1) {
            [items replaceObjectAtIndex:i withObject:[array objectAtIndex:index]];
        }
        else{
            [items replaceObjectAtIndex:i withObject:@""];
        }
    }
}