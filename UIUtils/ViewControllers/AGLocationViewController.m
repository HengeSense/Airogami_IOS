//
//  AGSignupLocationViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGLocationViewController.h"
#import "AGUtils.h"
#import "AGUIUtils.h"
#import "AGUIDefines.h"
#import "AGMessageUtils.h"


#define kSignup_Validate_Error @"error.signup.location.choose.invalid"

@interface AGLocationViewController()
{
     BOOL updated;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;


@end

@implementation AGLocationViewController

@synthesize fromViewController, needsUserLocation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AGUIDefines setNavigationBackButton:self.backButton];
    [AGUIDefines setNormalDoneButton:self.doneButton];
    if (!needsUserLocation) {
        self.location = [fromViewController valueForKey:AGLocationViewControllerLocationKey];
    }
    
}

- (void)viewDidUnload {
    [self setDoneButton:nil];
    [self setLocationLabel:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}

//hide navigation
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (IBAction)backButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonTouched:(UIButton *)sender {
    if ([self.location validate]) {
        [fromViewController setValue:self.location forKey:AGLocationViewControllerLocationKey] ;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [AGMessageUtils errorMessgeWithTitle:kSignup_Validate_Error view:self.view];
    }
    
}

- (void) setLocation:(AGLocation *)location
{
    updated = YES;
    [super setLocation:location];
    self.locationLabel.text = [location toString];
}


#pragma mark - mapView delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (updated == NO) {
        updated = YES;
        if (needsUserLocation) {
            [self searchUserLocation];
        }
        
    }
}


@end
