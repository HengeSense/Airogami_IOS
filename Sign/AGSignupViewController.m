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
#import "AGSignupLocationViewController.h"
#import "AGUIUtils.h"
#import "AGUtils.h"
#import "NSString+Addition.h"

#define kAGSignupInputNameShort @"error.signup.name.short"
#define kAGSignupInputPasswordShort @"error.signup.password.short"
#define kAGSignupInputLocationEmpty @"error.signup.location.empty"
#define kAGSignupInputEmailInvalid @"error.signup.email.invalid"
#define kAGSignupInputTag_Name 1
#define kAGSignupInputTag_Password 2
#define kAGSignupInputTag_Email 3
#define kAGSignupInputTag_Description 4

#define kAGSignupInputMaxLength_Name 30
#define kAGSignupInputMaxLength_Password 15
#define kAGSignupInputMaxLength_Email 256
#define kAGSignupInputMaxLength_Description 50

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

- (void) setLocation:(AGLocation *)aLocation
{
    location = aLocation;
     [self.locationButton setTitle:[location toString] forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sexSwitch.onText = @"Male";
    self.sexSwitch.offText = @"Female";
    self.sexSwitch.offTintColor = [UIColor colorWithRed:0xf2 / 255.f green:0x7f / 255.f blue:0x7a / 255.f alpha:1.0f];
    self.sexSwitch.onTintColor = [UIColor colorWithRed:0x75 / 255.f green:0xab / 255.f blue:0xd0 / 255.f alpha:1.0f];

    UIImage *image = [self.locationButton imageForState:UIControlStateNormal];
    [self.locationButton setImage:nil forState:UIControlStateNormal];
    [self.locationButton setBackgroundImage:image forState:UIControlStateHighlighted];
    self.locationButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.locationButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    //highlight
    [self.profileImageButton setImage:[UIImage imageNamed:Signup_Profile_Image_Highlight] forState:UIControlStateHighlighted];
    [self.backButton setImage:[UIImage imageNamed:Navigation_Back_Button_Highlight] forState:UIControlStateHighlighted];
    [self.rightButton setImage:[UIImage imageNamed:Navigation_Done_Button_Highlight] forState:UIControlStateHighlighted];
    
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
        
    }
}


- (IBAction)locationButtonTouched:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToLocation" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier compare:@"ToLocation"] == 0) {
        AGSignupLocationViewController *slvc = (AGSignupLocationViewController *) segue.destinationViewController;
        slvc.signupViewController = self;
    }
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
    [self.profileImageButton setImage:image forState:UIControlStateNormal];
    [self.profileImageButton setImage:nil forState:UIControlStateHighlighted];
    self.imagePickAndCrop = nil;
}

-(BOOL) validate
{
    NSString *error = nil;
    if (self.nameTextField.text.length < 2) {
        error = kAGSignupInputNameShort;
    }
    else if(self.passwordTextField.text.length < 6){
        error = kAGSignupInputPasswordShort;
    }
    else if (self.locationButton.titleLabel.text.length == 0){
        error = kAGSignupInputLocationEmpty;
    }
    else if ([self.emailTextField.text isValidEmail] == NO ){
        error = kAGSignupInputEmailInvalid;
    }
    if (error != nil) {
        [AGUIUtils errorMessgeWithTitle:error view:self.view];
    }
    
    return error == nil;
}

@end
