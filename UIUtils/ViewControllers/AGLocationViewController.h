//
//  AGSignupLocationViewController.h
//  Airogami
//
//  Created by Tianhu Yang on 6/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGooglePlacesAutocompleteViewController.h"


@interface AGLocationViewController : SPGooglePlacesAutocompleteViewController
@property (weak, nonatomic)  UIViewController *fromViewController;
@property (nonatomic, assign) BOOL needsUserLocation;
@end
