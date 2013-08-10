//
//  AGSigninViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/14/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//


#import "AGSigninViewController.h"
#import "AGUIUtils.h"
#import "AGDefines.h"
#import "AGUIDefines.h"
#import "AGManagerUtils.h"
#import "NSString+Addition.h"
#import "AGRootViewController.h"
#import "AGMessageUtils.h"
#import "AGAppDelegate.h"

#define kAGSigninScreenNameInvalid @"error.signin.email.invalid"
#define kAGSigninPasswordInvalid @"error.signin.password.invalid"
#define kAGSigninInputTag_Name 1
#define kAGSigninInputTag_Password 2

#define kAGSigninInputMaxLength_ScreenName AGAccountScreenNameMaxLength
#define kAGSigninInputMaxLength_Email AGAccountEmailMaxLength
#define kAGSigninInputMinLength_Password AGAccountPasswordMinLength
#define kAGSigninInputMaxLength_Password AGAccountPasswordMaxLength

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
	[AGUIDefines setNavigationBackButton:self.backButton];
    [AGUIDefines setNavigationDoneButton:self.doneButton];
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
        [self.view endEditing:YES];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
        BOOL isEmail = [self.nameTextField.text isValidEmail];
        if (isEmail) {
            [dict setObject:self.nameTextField.text forKey:@"email"];
        }
        else{
            [dict setObject:self.nameTextField.text forKey:@"screenName"];
        }
        
        [dict setObject:self.passwordTextField.text forKey:@"password"];
        
        [[AGManagerUtils managerUtils].accountManager signin:dict automatic:NO animated:YES context:nil block:^(NSError *error, BOOL succeed) {
            if (succeed) {
                [[AGRootViewController rootViewController] switchToMain];
            }
         
        }];
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
        case kAGSigninInputTag_Name:
            should = newLength <= kAGSigninInputMaxLength_Email;
            break;
        case kAGSigninInputTag_Password:
            should = newLength <= kAGSigninInputMaxLength_Password;
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
    if ([self.nameTextField.text isValidEmail] == NO) {
        if (self.nameTextField.text.length > kAGSigninInputMaxLength_ScreenName) {
            error = kAGSigninScreenNameInvalid;
        }
        
    }
    if(error == nil && self.passwordTextField.text.length < kAGSigninInputMinLength_Password){
        error = kAGSigninPasswordInvalid;
    }

    if (error != nil) {
        [AGMessageUtils errorMessgeWithTitle:error view:self.view];
    }
    
    return error == nil;
}

@end
