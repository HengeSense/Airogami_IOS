//
//  AGSignupViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGSignupViewController.h"
#import "DCRoundSwitch.h"
#import "AGKeyboardScroll.h"
#import "AGImagePickAndCrop.h"
#import "AGLocationUtils.h"
#import "AGLocationViewController.h"
#import "AGUIUtils.h"
#import "AGUtils.h"
#import "AGDefines.h"
#import "NSString+Addition.h"
#import "AGUIDefines.h"
#import "AGRootViewController.h"
#import "AGManagerUtils.h"
#import "UIImage+Addition.h"
#import <CoreLocation/CoreLocation.h>

#define kAGSignupInputScreenNameShort AGAccountScreenNameShortKey
#define kAGSignupInputPasswordShort AGAccountPasswordShortKey
#define kAGSignupInputLocationEmpty AGAccountLocationEmptyKey
#define kAGSignupInputEmailInvalid AGAccountEmailInvalidKey
#define kAGSignupInputIconRequire AGAccountIconRequireKey
#define kAGSignupInputTag_Name 1
#define kAGSignupInputTag_Password 2
#define kAGSignupInputTag_Email 3
#define kAGSignupInputTag_Description 4

#define kAGSignupInputMaxLength_Name AGAccountScreenNameMaxLength
#define kAGSignupInputMaxLength_Password AGAccountPasswordMaxLength
#define kAGSignupInputMinLength_Password AGAccountPasswordMinLength
#define kAGSignupInputMaxLength_Email AGAccountEmailMaxLength
#define kAGSignupInputMaxLength_Description AGAccountDescriptionMaxLength

static NSString * const Signup_Profile_Images[] = {@"signup_profile_normal.png", @"signup_profile_location.png", @"signup_profile_email.png", @"signup_profile_words.png"};

static NSString * const Signup_Account_Images[] = {@"signup_account_normal.png", @"signup_account_name.png", @"signup_account_password.png"};

static NSString * const Signup_Profile_Image_Highlight = @"signup_profile_image_highlight.png";


@interface AGSignupViewController () <UIActionSheetDelegate, UITextFieldDelegate, AGImagePickAndCropDelegate>
{
    AGLocationUtils *locationUtils;
}

@property (weak, nonatomic) IBOutlet DCRoundSwitch *sexSwitch;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (weak, nonatomic) IBOutlet UIImageView *accountImageView;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property(nonatomic, strong) AGImagePickAndCrop *imagePickAndCrop;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UIImageView *nameCheckImageView;

@property (weak, nonatomic) IBOutlet UIImageView *passwordCheckImageView;

@property (weak, nonatomic) IBOutlet UIImageView *emailCheckImageView;


@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation AGSignupViewController

@synthesize imagePickAndCrop, location;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

-(void) initialize
{
    locationUtils = [[AGLocationUtils alloc] init];
    location = [AGLocation location];
    [locationUtils getCurrentLocation:^(AGLocation *aLocation, NSError *error) {
        //NSLog(@"%@",location);
        dispatch_async(dispatch_get_main_queue(),^ {
           self.location = aLocation;           
        });
    }];
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
     [self.locationButton setTitle:[location toString] forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [AGUIUtils buttonBackgroundImageNormalToHighlight:self.locationButton];
    self.locationButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.locationButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    //highlight
    [self.profileImageButton setBackgroundImage:[UIImage imageNamed:Signup_Profile_Image_Highlight] forState:UIControlStateHighlighted];
    [AGUIDefines setNavigationBackButton:self.backButton];
    [AGUIDefines setNavigationDoneButton:self.rightButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setSexSwitch:nil];
    [self setSexSwitch:nil];
    [self setLocationButton:nil];
    [self setAccountImageView:nil];
    [self setProfileImageView:nil];
    [self setProfileImageButton:nil];
    [self setBackButton:nil];
    [self setRightButton:nil];
    [self setNameTextField:nil];
    [self setPasswordTextField:nil];
    [self setEmailTextField:nil];
    [self setDescriptionTextField:nil];
    [self setScrollView:nil];
    [self setNameCheckImageView:nil];
    [self setPasswordCheckImageView:nil];
    [self setEmailCheckImageView:nil];
    [super viewDidUnload];
}


- (IBAction)backButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)doneButtonTouched:(UIButton *)sender {
    if ([self validate]) {
        [self.view endEditing:YES];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setObject:self.emailTextField.text forKey:@"email"];
        [dict setObject:self.passwordTextField.text forKey:@"password"];
        [dict setObject:self.sexSwitch.text forKey:@"sex"];
        [dict setObject:self.nameTextField.text forKey:@"fullName"];
        [dict setObject:@"" forKey:@"birthday"];
        CLLocationCoordinate2D coordinate = self.location.coordinate;
        [dict setObject:[NSString stringWithFormat:@"%lf", coordinate.longitude] forKey:@"longitude"];
        [dict setObject:[NSString stringWithFormat:@"%lf", coordinate.latitude] forKey:@"latitude"];
        [dict setObject:self.location.subArea forKey:@"city"];
        [dict setObject:self.location.area forKey:@"province"];
        [dict setObject:self.location.country forKey:@"country"];
        [dict setObject:self.descriptionTextField.text forKey:@"shout"];
        [[AGManagerUtils managerUtils].accountManager signup:dict image:[self.profileImageButton imageForState:UIControlStateNormal]];
    }
}


- (IBAction)locationButtonTouched:(UIButton *)sender {
    //[self performSegueWithIdentifier:@"ToLocation" sender:self];
    AGLocationViewController *slvc = [AGRootViewController locationViewController];
    slvc.fromViewController = self;
    [self.navigationController pushViewController:slvc animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier compare:@"ToLocation"] == 0) {
//        
//        AGLocationViewController *slvc = (AGLocationViewController *) segue.destinationViewController;
//        slvc.fromViewController = self;
//    }
}


- (IBAction)imageTouched:(UIButton *)sender {
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

- (IBAction)editDidBegin:(UITextField *)sender {
    if(sender.tag < 3){
        self.accountImageView.image = [UIImage imageNamed:Signup_Account_Images[sender.tag]];
    }
    
    else{
        self.profileImageView.image = [UIImage imageNamed:Signup_Profile_Images[sender.tag - 1]];
    }
    
    [AGKeyboardScroll setScrollView:(UIScrollView*)self.scrollView view:self.scrollView activeField:sender];
    
}


- (IBAction)editDidEnd:(UITextField *)sender {
    if(sender.tag < 3){
        self.accountImageView.image = [UIImage imageNamed:Signup_Account_Images[0]];
    }
    
    else{
        self.profileImageView.image = [UIImage imageNamed:Signup_Profile_Images[0]];
    }
    [AGKeyboardScroll clear];
    [sender resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
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
        case kAGSignupInputTag_Email:
            should = newLength <= kAGSignupInputMaxLength_Email;
            break;
        case kAGSignupInputTag_Description:
            should = newLength <= kAGSignupInputMaxLength_Description;
            break;
            
        default:
            break;
    }
    return should;
}

- (IBAction)textFieldValueChanged:(UITextField *)textField {
    switch (textField.tag) {
        case kAGSignupInputTag_Name:
            self.nameCheckImageView.hidden = textField.text.length < 2;
            break;
        case kAGSignupInputTag_Password:
            self.passwordCheckImageView.hidden = textField.text.length < 6;
            break;
        case kAGSignupInputTag_Email:
            self.emailCheckImageView.hidden = [textField.text isValidEmail] == NO;
            break;
        case kAGSignupInputTag_Description:
            break;
            
        default:
            break;
    }
}


#pragma mark - AGImagePickAndCropDelegate
- (void) imageCropperDidCancel:(AGImagePickAndCrop *)pickAndCrop
{
    self.imagePickAndCrop = nil;
}

- (void) imagePickAndCrop:(AGImagePickAndCrop *)pickAndCrop didFinishingWithImage:(UIImage *)image
{
    image = [image imageWithSize:AGAccountIconSize];
    [self.profileImageButton setImage:image forState:UIControlStateNormal];
    [self.profileImageButton setImage:nil forState:UIControlStateHighlighted];
    self.imagePickAndCrop = nil;
}

-(BOOL) validate
{
    NSString *error = nil;
    if (self.nameTextField.text.length < 2) {
        error = kAGSignupInputScreenNameShort;
    }
    else if(self.passwordTextField.text.length < kAGSignupInputMinLength_Password){
        error = kAGSignupInputPasswordShort;
    }
    else if (self.locationButton.titleLabel.text.length == 0){
        error = kAGSignupInputLocationEmpty;
    }
    else if ([self.emailTextField.text isValidEmail] == NO ){
        error = kAGSignupInputEmailInvalid;
    }
    else if ([self.profileImageButton imageForState:UIControlStateNormal] == nil ){
        error = kAGSignupInputIconRequire;
    }
    if (error != nil) {
        [AGUIUtils errorMessgeWithTitle:error view:self.view];
    }
    
    return error == nil;
}

@end
