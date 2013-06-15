//
//  AGSignupLocationViewController.h
//  Airogami
//
//  Created by Tianhu Yang on 6/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGooglePlacesAutocompleteViewController.h"

@class AGSignupViewController;

@interface AGSignupLocationViewController : SPGooglePlacesAutocompleteViewController
@property (weak, nonatomic)  AGSignupViewController *signupViewController;
@end
