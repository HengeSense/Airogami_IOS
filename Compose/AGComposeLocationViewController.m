//
//  AGComposeLocationViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGComposeLocationViewController.h"
#import "AGComposeEditViewController.h"
#import "AGUIUtils.h"

@interface AGComposeLocationViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@end

@implementation AGComposeLocationViewController

@synthesize composeEditViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

-(void)viewDidUnload
{
    [self setBackButton:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        composeEditViewController.location = self.location;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        //[AGUIUtils errorMessgeWithTitle:kSignup_Validate_Error view:self.view];
    }
    
}

- (void) setAddress:(CLPlacemark*) placeMark
{
    [super setAddress:placeMark];
    //self.locationLabel.text = [self.location toString];
}

@end
