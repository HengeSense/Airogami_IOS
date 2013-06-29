//
//  AGSlideSegue.m
//  Airogami
//
//  Created by Tianhu Yang on 6/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGSlideSegue.h"
#import <QuartzCore/QuartzCore.h>

@implementation AGSlideSegue

-(void)perform {
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    CATransition* transition1 = [CATransition animation];
    transition1.duration = .25;
    transition1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition1.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition1.subtype = kCATransitionFromLeft; //
    
    
    
    [sourceViewController.view.layer addAnimation:transition1 forKey:kCATransition];
    [destinationController.navigationController.view.layer addAnimation:transition
                                           forKey:kCATransition];
    
    [sourceViewController presentModalViewController:destinationController animated:NO];
    
    
}
@end
