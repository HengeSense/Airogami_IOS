//
//  AGSettingProfileScreenNameViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 7/29/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGSettingProfileScreenNameViewController.h"
#import "AGUIUtils.h"
#import "AGDefines.h"
#import "AGMessageUtils.h"
#import "AGManagerUtils.h"
#import "AGAppDirector.h"

static NSString *ScreenNameExist = @"error.account.changescreenname.screenname.exist";

@interface AGSettingProfileScreenNameViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *screenNameTextField;

@end

@implementation AGSettingProfileScreenNameViewController

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
	[AGUIDefines setNavigationBackButton:self.backButton];
    [AGUIDefines setNavigationDoneButton:self.doneButton];
	[AGUIUtils setBackButtonTitle:self];
    [self initData];
}

- (void) initData
{
    NSString *screenName = [AGAppDirector appDirector].account.profile.screenName;
    self.screenNameTextField.text = screenName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setDoneButton:nil];
    [self setScreenNameTextField:nil];
    [super viewDidUnload];
}

#pragma mark - textfield delegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    return YES;
}

- (IBAction)textFieldValueChanged:(UITextField *)textField {
    if (textField.text.length > AGAccountScreenNameMaxLength) {
        textField.text = [textField.text substringToIndex:AGAccountScreenNameMaxLength];
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    //UIImageView *imageView = (UIImageView *)[textField.superview viewWithTag:textField.tag + 10];
    //imageView.highlighted = YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    //UIImageView *imageView = (UIImageView *)[textField.superview viewWithTag:textField.tag + 10];
    //imageView.highlighted = NO;
}

- (IBAction)backButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonTouched:(UIButton *)sender {
    if ([self validate]) {
        [self changeScreenName];
    }
}

- (void) changeScreenName
{
    AGAccountManager *accountManager = [AGManagerUtils managerUtils].accountManager;
    NSDictionary *params = [accountManager paramsForChangeScreenName:self.screenNameTextField.text];
    [accountManager changeScreenName:params context:nil block:^(NSError *error, id context, BOOL succeed) {
        if (succeed) {
            [AGMessageUtils alertMessageUpdated];
        }
        else{
            [AGMessageUtils alertMessageWithTitle:@"" message:AGLS(ScreenNameExist)];
        }
        
    }];
}

-(BOOL) validate
{
    NSString *error = nil;
    if (self.screenNameTextField.text.length < AGAccountScreenNameMinLength) {
        error = AGAccountScreenNameShortKey;
    }
    
    if (error != nil) {
        [AGMessageUtils errorMessgeWithTitle:error view:self.view];
    }
    
    return error == nil;
}

@end
