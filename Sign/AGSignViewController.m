//
//  AGRootViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGSignViewController.h"
#import "AGUIUtils.h"

#define kAGSigninButtonTag 1
#define kAGSignupButtonTag 2

@interface AGSignViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@property (weak, nonatomic) IBOutlet UIButton *signinButton;

@end

@implementation AGSignViewController

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
	[AGUIUtils buttonBackgroundImageNormalToHighlight:self.signinButton];
    [AGUIUtils buttonBackgroundImageNormalToHighlight:self.signupButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signTouched:(UIButton *)sender {
    switch (sender.tag) {
        case kAGSigninButtonTag:
            [self performSegueWithIdentifier:@"ToSignin" sender:self];
            break;
        case kAGSignupButtonTag:
            [self performSegueWithIdentifier:@"ToSignup" sender:self];
            break;
            
        default:
            break;
    }
    
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

- (void)viewDidUnload {
    [self setSignupButton:nil];
    [self setSigninButton:nil];
    [super viewDidUnload];
}
@end
