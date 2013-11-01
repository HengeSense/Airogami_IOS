//
//  AGImageTextPicker.m
//  Airogami
//
//  Created by Tianhu Yang on 10/31/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGImageTextPicker.h"

@interface AGImageTextPicker ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>
{
    __weak IBOutlet UILabel *label;
    __weak IBOutlet UITextView *textView;
    __weak IBOutlet UIImageView *imageView;
    UIImagePickerController *imagePickerController;
    BOOL picked;
}

@end

@implementation AGImageTextPicker

@synthesize delegate;

+(id) imageTextPicker
{
    return [[AGImageTextPicker alloc] initWithNibName:@"AGImageTextPicker" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (picked == NO) {
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    label.hidden = YES;
}

-(void) textViewDidEndEditing:(UITextView *)textView_
{
    label.text = textView_.text;
    textView_.hidden = YES;
    label.hidden = NO;
    [label sizeToFit];
    label.center = imageView.center;
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //send
    if ([text isEqualToString:@"\n"]) {
        [aTextView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView_
{
    NSString *text = textView_.text;
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (text.length > AGAccountMessageContentMaxLength) {
        text = [text substringToIndex:AGAccountMessageContentMaxLength];
    }
    if (text.length != textView.text.length) {
        textView.text = text;
    }
}

//buttons
- (IBAction)cancelButton:(UIButton *)sender {
    [self cancel];
}

- (IBAction)doneButton:(UIButton *)sender {
    [self done];
}

- (IBAction)textButton:(UIButton *)sender {
    textView.hidden = NO;
    [textView becomeFirstResponder];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    picked = YES;
    imageView.image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancel];
}


//logic

- (void) pick:(UIViewController *)viewController type:(AGImagePickerType)type
{
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    switch (type) {
        case AGImagePickerType_Camera:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case AGImagePickerType_Library:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        default:
            break;
    }
    [viewController presentViewController:self animated:NO completion:nil];
}

-(void) cancel
{
    [delegate imageTextPicker:self didFinish:NO image:nil text:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

-(void) done
{
    [delegate imageTextPicker:self didFinish:YES image:imageView.image text:textView.text];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


@end
