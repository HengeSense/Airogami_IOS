//
//  AGResetPasswordViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/14/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGResetPasswordViewController.h"
#import "NSString+Addition.h"
#import "AGUIUtils.h"
#import "AGUIDefines.h"
#import "AGMessageUtils.h"

#define kAGSignupInputTag_Email 1

#define kAGSignupInputEmailInvalid AGAccountEmailInvalidKey

static NSString * const Reset_Password_Images[] = {@"reset_password_normal.png", @"reset_password_email.png"};

@interface AGResetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIImageView *resetPasswordImageView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIImageView *emailCheckImageView;


@end

@implementation AGResetPasswordViewController

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
    [AGUIDefines setNormalDoneButton:self.doneButton];
    [AGUIUtils setBackButtonTitle:self];
}

- (void)viewDidUnload {
    [self setEmailTextField:nil];
    [self setBackButton:nil];
    [self setResetPasswordImageView:nil];
    [self setDoneButton:nil];
    [self setEmailCheckImageView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)doneButtonTouched:(UIButton *)sender {

    if ([self validate]) {
        
    }
}


#pragma mark - TextField actions

- (IBAction)editDidBegin:(UITextField *)sender {
    
    
    self.resetPasswordImageView.image = [UIImage imageNamed:Reset_Password_Images[sender.tag]];
    
    //[AGKeyboardScroll setScrollView:(UIScrollView*)self.scrollView view:self.scrollView activeField:sender];
    
}


- (IBAction)editDidEnd:(UITextField *)sender {
    
    self.resetPasswordImageView.image = [UIImage imageNamed:Reset_Password_Images[0]];
    //[AGKeyboardScroll clear];
    [sender resignFirstResponder];
}

- (IBAction)textFieldValueChanged:(UITextField *)textField {
    switch (textField.tag) {
        case kAGSignupInputTag_Email:
            self.emailCheckImageView.hidden = [textField.text isValidEmail] == NO;
            break;
            
        default:
            break;
    }
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL) validate
{
    NSString *error = nil;

    if ([self.emailTextField.text isValidEmail] == NO ){
        error = kAGSignupInputEmailInvalid;
    }
    if (error != nil) {
        [AGMessageUtils errorMessgeWithTitle:error view:self.view];
    }
    
    return error == nil;
}
@end
