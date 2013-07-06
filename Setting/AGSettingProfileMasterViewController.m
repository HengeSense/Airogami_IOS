//
//  AGSettingProfileViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 7/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGSettingProfileMasterViewController.h"
#import "AGSexSwitch.h"
#import "NSString+Addition.h"
#import "AGLocationViewController.h"
#import "AGRootViewController.h"

@interface AGSettingProfileMasterViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UIButton *regionButton;

@property (weak, nonatomic) IBOutlet AGSexSwitch *sexSwitch;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emailImageView;

@property (nonatomic, strong) AGLocation *location;

@end

@implementation AGSettingProfileMasterViewController

@synthesize location;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setLocation:(AGLocation *)aLocation
{
    location = aLocation;
    [self.regionButton setTitle:[location toString] forState:UIControlStateNormal];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        self.emailImageView.highlighted = YES;
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        self.emailImageView.highlighted = NO;
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.ageTextField) {
        if ([string isNumeric] == NO) {
            return NO;
        }
    }
    return YES;
}

- (IBAction)textFieldEditingChanged:(UITextField *)textField {
    if (textField == self.nameTextField) {
        if (textField.text.length > AGAccountNameMaxLength) {
            textField.text = [textField.text substringToIndex:AGAccountNameMaxLength];
        }
    }
    else if(textField == self.ageTextField)
    {
        if (textField.text.length > AGAccountAgeMaxLength) {
            textField.text = [textField.text substringToIndex:AGAccountAgeMaxLength];
        }
    }
    else if(textField == self.emailTextField)
    {
        if (textField.text.length > AGAccountEmailMaxLength) {
            textField.text = [textField.text substringToIndex:AGAccountAgeMaxLength];
        }
    }
}

#pragma mark - UITextView delegate

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.descriptionTextView) {
        self.descriptionImageView.highlighted = YES;
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.descriptionTextView) {
        self.descriptionImageView.highlighted = NO;
    }
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //return
    if ([text isEqualToString:@"\n"]) {
        [aTextView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (text.length > AGAccountDescriptionMaxLength) {
        text = [text substringToIndex:AGAccountDescriptionMaxLength];
    }
    if (text.length != textView.text.length) {
        textView.text = text;
    }
}

- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setSettingButton:nil];
    [self setNameTextField:nil];
    [self setScreenNameLabel:nil];
    [self setAgeTextField:nil];
    [self setSexSwitch:nil];
    [self setDescriptionTextView:nil];
    [self setEmailTextField:nil];
    [self setDescriptionImageView:nil];
    [self setEmailImageView:nil];
    [self setRegionButton:nil];
    [super viewDidUnload];
}

- (IBAction)backButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settingButtonTouched:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToSetting" sender:self];
}

- (IBAction)regionButtonTouched:(UIButton *)sender {
    AGLocationViewController *slvc = [AGRootViewController locationViewController];
    slvc.fromViewController = self;
    [self.navigationController pushViewController:slvc animated:YES];
}

- (IBAction)passwordButtonTouched:(UIButton *)sender {
}



@end
