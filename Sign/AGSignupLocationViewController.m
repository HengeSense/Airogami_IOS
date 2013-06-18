//
//  AGSignupLocationViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/7/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGSignupLocationViewController.h"
#import "AGUtils.h"
#import "AGSignupViewController.h"
#import "AGUIUtils.h"
#import "AGUIDefines.h"


#define kSignup_Location_Back_Highlight @"back_button_highlight.png"
#define kSignup_Validate_Error @"error.signup.location.choose.invalid"

@interface AGSignupLocationViewController()
{
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;


@end

@implementation AGSignupLocationViewController

@synthesize signupViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.backButton setBackgroundImage:[UIImage imageNamed:kSignup_Location_Back_Highlight] forState:UIControlStateHighlighted];
    [self.backButton setTitleColor:[AGUIDefines navigationBackHighlightColor] forState:UIControlStateHighlighted];
    
    [self.doneButton setBackgroundImage:[UIImage imageNamed:Normal_Done_Highlight] forState:UIControlStateHighlighted];
    [self.doneButton setTitleColor:[AGUIDefines navigationDoneHighlightColor] forState:UIControlStateHighlighted];
    self.location = signupViewController.location;
    self.locationLabel.text = [self.location toString];
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
        signupViewController.location = self.location;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [AGUIUtils errorMessgeWithTitle:kSignup_Validate_Error view:self.view];
    }
    
}

- (void) setAddress:(CLPlacemark*) placeMark
{
    [super setAddress:placeMark];
    self.locationLabel.text = [self.location toString];
}

@end
