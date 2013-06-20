//
//  AGComposeLocationViewController.h
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "SPGooglePlacesAutocompleteViewController.h"

@class AGWriteEditViewController;

@interface AGWriteLocationViewController : SPGooglePlacesAutocompleteViewController
@property (weak, nonatomic)  AGWriteEditViewController *composeEditViewController;
@end
