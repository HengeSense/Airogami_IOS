//
//  AGComposeEditViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGWriteEditViewController.h"
#import "AGKeyboardResize.h"
#import "AGWriteEditViewAnimation.h"
#import "AGWriteLocationViewController.h"
#import "AGCategory+Addition.h"
#import "AGUIUtils.h"
#import "AGMessageUtils.h"
#import "AGManagerUtils.h"
#import <QuartzCore/QuartzCore.h>

#define kAGWriteEditTextMaximum 200

static NSString *AGWriteEditSexImages[] = {@"write_edit_both_button.png", @"write_edit_male_button.png", @"write_edit_female_button.png"};
static NSString *AGContentEmpty = @"plane.sendplane.content.empty";
static NSString *AGContentLong = @"plane.sendplane.content.long";

@interface AGWriteEditViewController ()
{
    UIButton *sexAidedButton;
    AGWriteEditViewAnimation *writeEditViewAnimation;
    int sex;
}
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *accessoryView;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *sexButtons;

@property (weak, nonatomic) IBOutlet UIButton *sexButton;

@end

@implementation AGWriteEditViewController

@synthesize location, categoryId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) initialize
{
    [AGUIDefines setNavigationBackButton:self.backButton];
    [AGUIDefines setNavigationDoneButton:self.sendButton];
    [AGUIUtils setBackButtonTitle:self];
    
    location = [AGLocation location];
    sexAidedButton = [[UIButton alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [sexAidedButton addTarget:self action:@selector(sexAidedButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *button in self.sexButtons) {
        [sexAidedButton addSubview:button];
    }
    writeEditViewAnimation = [[AGWriteEditViewAnimation alloc] initWithView:sexAidedButton];
    self.textView.inputAccessoryView = self.accessoryView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
	self.titleLabel.text = [AGCategory title:self.categoryId];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setSendButton:nil];
    [self setAccessoryView:nil];
    [self setTextView:nil];
    [self setTitleLabel:nil];
    [self setLocationLabel:nil];
    [self setCountLabel:nil];
    [self setSexButtons:nil];
    [self setSexButton:nil];
    [super viewDidUnload];
}

- (IBAction)backButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //self.textView.inputAccessoryView.hidden = YES;
}


- (IBAction)sendButtonTouched:(UIButton *)sender {
    if ([self validate]) {
        if (categoryId.intValue < AGCategoryChain) {//plane
            [[AGManagerUtils managerUtils].planeManager sendPlane:[self obtainData] context:nil block:^(NSError *error, id context) {
                if (error) {
                    [self.textView becomeFirstResponder];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
        else{
            [[AGManagerUtils managerUtils].chainManager sendChain:[self obtainData] context:nil block:^(NSError *error, id context) {
                if (error) {
                    [self.textView becomeFirstResponder];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    
    }
}

-(BOOL) validate
{
    NSString *error = nil;
    if (self.textView.text.length < 1) {
        error = AGContentEmpty;
    }
    else if (self.textView.text.length > kAGWriteEditTextMaximum)
    {
        error = AGContentLong;
    }
    if (error != nil) {
        [AGMessageUtils errorMessgeWithTitle:error view:self.view];
    }
    
    return error == nil;
}

- (NSDictionary*) obtainData
{
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:10];
    if ([self.location empty] == NO) {
        [self.location appendParam:data];
    }
    [data setObject:[NSNumber numberWithInt:sex] forKey:@"sex"];
    
    if (categoryId.intValue < AGCategoryChain) {
        [data setObject:categoryId forKey:@"categoryVO.categoryId"];
        [data setObject:self.textView.text forKey:@"messageVO.content"];
        [data setObject:[NSNumber numberWithInt:AGMessageTypeText] forKey:@"messageVO.type"];
    }
    else{
        [data setObject:self.textView.text forKey:@"chainMessageVO.content"];
        [data setObject:[NSNumber numberWithInt:AGMessageTypeText] forKey:@"chainMessageVO.type"];
    }
    
    
    return data;
}


- (IBAction)locationButtonTouched:(UIButton *)sender {
    [self sexButtonFold];
    [self performSegueWithIdentifier:@"ToLocation" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AGWriteLocationViewController class]]) {
        AGWriteLocationViewController * wlvc = segue.destinationViewController;
        wlvc.writeEditViewController = self;
        
    }
}

-(void) setLocation:(AGLocation *)aLocation
{
    location = aLocation;
    self.locationLabel.text = [location validString];
}

- (IBAction)sexButtonTouched:(UIButton *)sender {
    
    [self sexButtonToggle];
    
}

- (IBAction)sexButtonsTouched:(UIButton *)sender {
    
    [self sexButtonFold];
    sex = sender.tag - 1;
    [self.sexButton setBackgroundImage:[UIImage imageNamed:AGWriteEditSexImages[sex]] forState:UIControlStateNormal];
    switch (sex) {
        case 0://both
            
            break;
        case 1://male
            
            break;
        case 2://female
            
            break;
            
        default:
            break;
    }
    
}

- (void) sexButtonToggle
{
    CGPoint point = [self.sexButton.superview convertPoint:self.sexButton.center toView:self.view.window];
    [writeEditViewAnimation toggle:point];
}

- (void) sexButtonFold
{
    CGPoint point = [self.sexButton.superview convertPoint:self.sexButton.center toView:self.view.window];
    [writeEditViewAnimation fold:point];
}


- (void) view:(UIView*)view runSpinAnimationWithDuration:(CGFloat) duration;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: .0 /* full rotation*/ ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1.0;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}



- (void) sexAidedButtonTouched:(UIButton*)sender
{
    CGPoint point = [self.sexButton.superview convertPoint:self.sexButton.center toView:self.view.window];
    [writeEditViewAnimation fold:point];
}



- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (text.length != textView.text.length) {
        textView.text = text;
    }
    self.countLabel.text = [NSString stringWithFormat:@"%d", kAGWriteEditTextMaximum - textView.text.length];
    [self sexButtonFold];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{

    [AGKeyboardResize setScrollView:self.textView view:self.view];
    
}


- (void)textViewDidEndEditing:(UITextView *)textView{

    [AGKeyboardResize clear];
    [textView resignFirstResponder];
}
@end
