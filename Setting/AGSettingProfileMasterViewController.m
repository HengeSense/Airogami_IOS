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
#import "AGUIUtils.h"
#import "AGMessageUtils.h"
#import "AGImagePickAndCrop.h"
#import "AGProfileImageButton.h"
#import "AGDatePicker.h"
#import "AGManagerUtils.h"
#import "AGUtils.h"

#define kAGSettingProfileSettingHighlight @"profile_setting_icon_highlight.png"
#define kAGSettingProfileLocationHighlight @"profile_location_button_highlight.png"
#define kAGSettingProfilePasswordHighlight @"profile_password_icon_box_highlight.png"

@interface AGSettingProfileMasterViewController ()<AGImagePickAndCropDelegate, UIActionSheetDelegate, AGDatePickerDelegate>
{
    UITextView * aidedTextView;
    AGImagePickAndCrop *imagePickAndCrop;
    AGAccountManager *accountManager;
}
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet AGProfileImageButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UIButton *changeProfileImageButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;

@property (weak, nonatomic) IBOutlet UIButton *screenNameButton;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet AGSexSwitch *sexSwitch;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;
@property (weak, nonatomic) IBOutlet UIButton *passwordButton;

@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (nonatomic, strong) AGLocation *location;
@property(nonatomic, strong) AGDatePicker *datePicker;

@end

@implementation AGSettingProfileMasterViewController

@synthesize location, datePicker;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    datePicker = [[AGDatePicker alloc] init];
    datePicker.delegate = self;
    accountManager = [AGManagerUtils managerUtils].accountManager;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AGUIDefines setNavigationBackButton:self.backButton];
    [AGUIDefines setNavigationDoneButton:self.doneButton];
    [self.settingButton setImage:[UIImage imageNamed:kAGSettingProfileSettingHighlight] forState:UIControlStateHighlighted];
    [self.locationButton setBackgroundImage:[UIImage imageNamed:kAGSettingProfileLocationHighlight] forState:UIControlStateHighlighted];
    [self.passwordButton setBackgroundImage:[UIImage imageNamed:kAGSettingProfilePasswordHighlight] forState:UIControlStateHighlighted];
    [AGUIUtils buttonBackgroundImageNormalToHighlight:self.screenNameButton];
    [AGUIUtils buttonBackgroundImageNormalToHighlight:self.changeProfileImageButton];
    //
    [self.locationButton setTitleColor:[UIColor colorWithRed:110 / 255.0f green:110 / 255.0f blue:110 / 255.0f alpha:1.0f] forState:UIControlStateSelected];
    self.infoImageView.image = [self.infoImageView.image stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    self.infoImageView.frame =  self.infoImageView.superview.bounds;
    //
    aidedTextView = [[UITextView alloc] initWithFrame:self.descriptionTextView.frame];
    aidedTextView.font = self.descriptionTextView.font;
    aidedTextView.hidden = YES;
    [self.descriptionTextView.superview addSubview:aidedTextView];
    self.ageTextField.inputView = datePicker.datePicker;
    self.ageTextField.inputAccessoryView = datePicker.toolBar;
    [self initData];
}

- (void) initData
{
    AGProfile *profile = accountManager.account.profile;
    
    self.likesLabel.text = [profile.likesCount stringValue];
    self.nameTextField.text = profile.fullName;
    [self.screenNameButton setTitle:profile.screenName forState:UIControlStateNormal];
    if (profile.birthday) {
        self.ageTextField.text = [AGUtils birthdayToAge:profile.birthday];
    }
    else{
        self.ageTextField.text = @"";
    }
    self.sexSwitch.sexType = profile.sex.intValue;
    self.location = [AGLocation locationWithProfile:profile];
    [self.locationButton setTitle:[self.location toString] forState:UIControlStateNormal];
    self.descriptionTextView.text = profile.shout;
    NSURL *url = [[AGManagerUtils managerUtils].dataManager accountIconUrl:profile.accountId small:YES];
    [self.profileImageButton setImageUrl:url placeImage:nil];
    //self.emailTextField.text = profile.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    if ([key isEqualToString:AGLocationViewControllerLocationKey]) {
        //self.location = value;
    }
}

- (void) setLocation:(AGLocation *)aLocation
{
    location = aLocation;
    NSString *title = [location toString];
    [self.locationButton setTitle:title forState:UIControlStateNormal];
    self.locationButton.selected = title.length != 0;
}

- (void) finish:(BOOL)done
{
    [self.ageTextField resignFirstResponder];
    if (done) {
        self.ageTextField.text = [AGUtils birthdayToAge:datePicker.datePicker.date];
    }

}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static float padding = 10;
    if (indexPath.row == 3) {
        CGRect frame = self.descriptionTextView.frame;
        aidedTextView.text = self.descriptionTextView.text;
        frame.size.height = aidedTextView.contentSize.height;
        self.descriptionTextView.frame = frame;
        //container
        UIView *view = self.descriptionTextView.superview;
        float height = frame.size.height + frame.origin.y + padding;
        frame = view.frame;
        frame.size.height = height;
        view.frame = frame;
        return  frame.origin.y + height;
    }
    else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


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
    else if (textField == self.ageTextField){
        AGProfile *profile = accountManager.account.profile;
        if (profile.birthday) {
            datePicker.datePicker.date = profile.birthday;
        }
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
    aidedTextView.text = self.descriptionTextView.text;
    if (aidedTextView.contentSize.height != self.descriptionTextView.bounds.size.height) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
}

- (void)viewDidUnload {
    aidedTextView = nil;
    [self setBackButton:nil];
    [self setDoneButton:nil];
    [self setNameTextField:nil];
    [self setAgeTextField:nil];
    [self setSexSwitch:nil];
    [self setDescriptionTextView:nil];
    [self setEmailTextField:nil];
    [self setDescriptionImageView:nil];
    [self setEmailImageView:nil];
    [self setLocationButton:nil];
    [self setInfoImageView:nil];
    [self setSettingButton:nil];
    [self setPasswordButton:nil];
    [self setScreenNameButton:nil];[self setChangeProfileImageButton:nil];
    [self setProfileImageButton:nil];
    [self setLikesLabel:nil];
    [super viewDidUnload];
}

#pragma mark - AGImagePickAndCropDelegate

- (IBAction)profileImageButtonTouched:(UIButton *)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"Add Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Take Photo", @"Choose From Library", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    imagePickAndCrop = [[AGImagePickAndCrop alloc] init];
    imagePickAndCrop.delegate = self;
    switch (buttonIndex) {
        case 0:
            [imagePickAndCrop pickAndCrop:self type:AGImagePickAndCropType_Camera];
            break;
        case 1:
            [imagePickAndCrop pickAndCrop:self type:AGImagePickAndCropType_Library];
            break;
        default:
            break;
    }
}

#pragma mark - AGImagePickAndCropDelegate
- (void) imageCropperDidCancel:(AGImagePickAndCrop *)pickAndCrop
{
    imagePickAndCrop = nil;
}

- (void) imagePickAndCrop:(AGImagePickAndCrop *)pickAndCrop didFinishingWithImage:(UIImage *)image
{
    [self.profileImageButton setImage:image forState:UIControlStateNormal];
    imagePickAndCrop = nil;
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
    slvc.needsUserLocation = YES;
    [self.navigationController pushViewController:slvc animated:YES];
}

- (IBAction)passwordButtonTouched:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToPassword" sender:self];
}

- (IBAction)screenNameButtonTouched:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToScreenName" sender:self];
}


- (IBAction)doneButtonTouched:(UIButton *)sender {
    if ([self validate]) {
        
    }
}


-(BOOL) validate
{
    NSString *error = nil;
    if (self.nameTextField.text.length < 2) {
        error = AGAccountNameShortKey;
    }
    else if (self.locationButton.titleLabel.text.length == 0 || self.locationButton.state != UIControlStateSelected ){
        error = AGAccountLocationEmptyKey;
    }
    else if ([self.emailTextField.text isValidEmail] == NO ){
        error = AGAccountEmailInvalidKey;
    }
    if (error != nil) {
        [AGMessageUtils errorMessgeWithTitle:error view:self.view];
    }
    
    return error == nil;
}

@end
