//
//  AGSettingProfilePasswordViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 7/6/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGSettingProfilePasswordViewController.h"
#import "AGUIUtils.h"
#import "AGDefines.h"
#import "AGMessageUtils.h"

@interface AGSettingProfilePasswordViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UITextField *currentTextField;
@property (weak, nonatomic) IBOutlet UITextField *nowTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;

@end

@implementation AGSettingProfilePasswordViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setDoneButton:nil];
    [self setCurrentTextField:nil];
    [self setNowTextField:nil];
    [self setConfirmTextField:nil];
    [super viewDidUnload];
}

#pragma mark - textfield delegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (IBAction)textFieldValueChanged:(UITextField *)textField {
    if (textField.text.length > AGAccountPasswordMaxLength) {
        textField.text = [textField.text substringToIndex:AGAccountPasswordMaxLength];
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    UIImageView *imageView = (UIImageView *)[textField.superview viewWithTag:textField.tag + 10];
    imageView.highlighted = YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    UIImageView *imageView = (UIImageView *)[textField.superview viewWithTag:textField.tag + 10];
    imageView.highlighted = NO;
}

- (IBAction)backButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonTouched:(UIButton *)sender {
    if ([self validate]) {
        
    }
}

-(BOOL) validate
{
    NSString *error = nil;
    if (self.currentTextField.text.length < AGAccountPasswordMinLength) {
        error = AGAccountCurrentPasswordShortKey;
    }
    else if ([self.nowTextField.text isEqualToString:self.confirmTextField.text] == NO ){
        error = AGAccountPasswordNoMatchKey;
    }
    else if (self.nowTextField.text.length <  AGAccountPasswordMinLength){
        error = AGAccountNewPasswordShortKey;
    }
   
    if (error != nil) {
        [AGMessageUtils errorMessgeWithTitle:error view:self.view];
    }
    
    return error == nil;
}

@end
