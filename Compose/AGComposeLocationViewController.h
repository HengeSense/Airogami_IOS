//
//  AGComposeLocationViewController.h
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "SPGooglePlacesAutocompleteViewController.h"

@class AGComposeEditViewController;

@interface AGComposeLocationViewController : SPGooglePlacesAutocompleteViewController
@property (weak, nonatomic)  AGComposeEditViewController *composeEditViewController;
@end
