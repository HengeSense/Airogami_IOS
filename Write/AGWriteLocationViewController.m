//
//  AGComposeLocationViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGWriteLocationViewController.h"
#import "AGWriteEditViewController.h"
#import "AGUIUtils.h"

@interface AGWriteLocationViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *doneButtons;

@end

@implementation AGWriteLocationViewController

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
    for (UIButton *button in self.doneButtons) {
        [AGUIUtils buttonBackgroundImageNormalToHighlight:button];
    }
	// Do any additional setup after loading the view.
}

-(void)viewDidUnload
{
    [self setBackButton:nil];
    [self setDoneButtons:nil];
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
    self.location.position = sender.tag;
    composeEditViewController.location = self.location;
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void) setAddress:(CLPlacemark*) placeMark
{
    [super setAddress:placeMark];

    for (UIButton *button in self.doneButtons) {
        if (button.tag < 3) {
            [button setTitle:[self.location stringAt:button.tag] forState:UIControlStateNormal];
        }
    }
}

@end
