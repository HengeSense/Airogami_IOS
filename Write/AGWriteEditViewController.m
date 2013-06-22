//
//  AGComposeEditViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGWriteEditViewController.h"
#import "AGKeyboardResize.h"
#import <QuartzCore/QuartzCore.h>

@interface AGWriteEditViewController ()
{
    UIButton *sexAidedButton;
}
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *accessoryView;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *sexButtons;

@property (weak, nonatomic) IBOutlet UIButton *sexButton;

@end

@implementation AGWriteEditViewController

@synthesize location;

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
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
	[AGUIDefines setNavigationBackButton:self.backButton];
    [AGUIDefines setNavigationDoneButton:self.sendButton];
    self.textView.inputAccessoryView = self.accessoryView;
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


- (IBAction)dummyButtonTouched:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToLocation" sender:self];
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
    
}

- (IBAction)sendButtonTouched:(UIButton *)sender {
    
}


- (IBAction)locationButtonTouched:(UIButton *)sender {
}


- (IBAction)sexButtonTouched:(UIButton *)sender {
    
    UIWindow * window = self.view.window;
    sexAidedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sexAidedButton addTarget:self action:@selector(sexAidedButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:sexAidedButton];
    for (UIButton *button in self.sexButtons) {
        [sexAidedButton addSubview:button];
        button.tag = 5;
        button.alpha = 0.f;
    }
    
    
    
    [self moveUp:@"AGWriteEditSex"];
}

- (void)earthquake:(UIView*)itemView
{
    CGFloat t = itemView.tag;
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -t);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, t);
    
    itemView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIView *view = (__bridge UIView *)context;
    int count = view.tag;
    
    if (count > 0)
    {
        --view.tag;
        if([finished boolValue]){
            UIView* item = (__bridge UIView *)context;
            item.transform = CGAffineTransformIdentity;
        }
        
    }
    else{
        [self earthquake:(__bridge UIView*)context];
    }
}


- (void)moveUp:(NSString *)animationID {
    
    [UIView animateWithDuration:.2
                          delay:0.0
                        options:(UIViewAnimationCurveLinear|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                          UIWindow * window = self.view.window;
                         CGPoint point = [self.sexButton.superview convertPoint:self.sexButton.center toView:window];
                         for (UIButton *button in self.sexButtons) {
                             button.center = point;
                             button.transform = CGAffineTransformMakeRotation(M_PI);
                             button.alpha = .3f;
                         }
                         //left
                         UIButton *button = [self.sexButtons objectAtIndex:0];
                         point.x -= 50;
                         point.y -= 50;
                         button.center = point;
                         //middle
                         button = [self.sexButtons objectAtIndex:1];
                         point.x += 50;
                         button.center = point;
                         //right
                         button = [self.sexButtons objectAtIndex:2];
                         point.x += 50;
                         button.center = point;
                        
                         
                         [UIView setAnimationDelegate:self];
                         [UIView setAnimationDidStopSelector:@selector(rotate:finished:context:)];

                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

- (void) rotate:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    for (UIButton *button in self.sexButtons) {
       // [self view:button runSpinAnimationWithDuration:.2f];
       
    }
    [UIView animateWithDuration:.2
                          delay:0.0
                        options:(UIViewAnimationCurveLinear|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         for (UIButton *button in self.sexButtons) {
                             button.transform = CGAffineTransformMakeRotation( 2 * M_PI);
                             button.alpha = 1.0f;
                         }
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
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
    
}



- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (text.length != textView.text.length) {
        textView.text = text;
    }
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{

    [AGKeyboardResize setScrollView:self.textView view:self.view];
    
}


- (void)textViewDidEndEditing:(UITextView *)textView{

    [AGKeyboardResize clear];
    [textView resignFirstResponder];
}
@end
