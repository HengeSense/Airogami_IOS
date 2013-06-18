//
//  AGSigninViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/14/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//


#import "AGSigninViewController.h"
#import "AGUIUtils.h"
#import "AGUIDefines.h"

#define kAGSigninAccountInvalid @"error.signin.account.invalid"
#define kAGSignupInputTag_Name 1
#define kAGSignupInputTag_Password 2

#define kAGSignupInputMaxLength_Name 30
#define kAGSignupInputMaxLength_Password 15

static NSString * const Signin_Account_Images[] = {@"signin_account_normal.png", @"signin_account_name.png", @"signin_account_password.png"};

@interface AGSigninViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *accountImageView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;


@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation AGSigninViewController

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
	[self.backButton setBackgroundImage:[UIImage imageNamed:Navigation_Back_Button_Highlight] forState:UIControlStateHighlighted];
    [self.backButton setTitleColor:[AGUIDefines navigationBackHighlightColor] forState:UIControlStateHighlighted];
    [self.doneButton setBackgroundImage:[UIImage imageNamed:Navigation_Done_Button_Highlight] forState:UIControlStateHighlighted];
    [self.doneButton setTitleColor:[AGUIDefines navigationDoneHighlightColor] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAccountImageView:nil];
    [self setBackButton:nil];
    [self setDoneButton:nil];
    [self setNameTextField:nil];
    [self setPasswordTextField:nil];
    [super viewDidUnload];
}


- (IBAction)backButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonTouched:(UIButton *)sender {
    if([self validate]){
        
    }
}


- (IBAction)resetPasswordButtonTouched:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToResetPassword" sender:self];
}


#pragma mark - TextField actions

- (IBAction)editDidBegin:(UITextField *)sender {

    
     self.accountImageView.image = [UIImage imageNamed:Signin_Account_Images[sender.tag]];
    
    //[AGKeyboardScroll setScrollView:(UIScrollView*)self.scrollView view:self.scrollView activeField:sender];
    
}


- (IBAction)editDidEnd:(UITextField *)sender {

     self.accountImageView.image = [UIImage imageNamed:Signin_Account_Images[0]];
    //[AGKeyboardScroll clear];
    [sender resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    BOOL should = YES;
    switch (textField.tag) {
        case kAGSignupInputTag_Name:
            should = newLength <= kAGSignupInputMaxLength_Name;
            break;
        case kAGSignupInputTag_Password:
            should = newLength <= kAGSignupInputMaxLength_Password;
            break;
            
        default:
            break;
    }
    return should;
}

#pragma mark - validate
-(BOOL) validate
{
    NSString *error = nil;
    if (self.nameTextField.text.length < 2) {
        error = kAGSigninAccountInvalid;
    }
    else if(self.passwordTextField.text.length < 6){
        error = kAGSigninAccountInvalid;
    }

    if (error != nil) {
        [AGUIUtils errorMessgeWithTitle:error view:self.view];
    }
    
    return error == nil;
}

@end
