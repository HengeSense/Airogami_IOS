//
//  AGWaitUtils.m
//  Airogami
//
//  Created by Tianhu Yang on 8/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGWaitUtils.h"

@implementation AGWaitUtils

+(void) startWait:(NSString *)message
{
    static NSNumber *number;
    static BOOL animating = NO;
    static UIActivityIndicatorView *activityView;
    @synchronized(number){
        if (message) {
            UILabel *label;
            if (animating == NO) {
                animating = YES;
                UIWindow *window = [[UIApplication sharedApplication].delegate window];
                CGRect rect = [UIScreen mainScreen].bounds;
                UIView *view = [[UIView alloc] initWithFrame:rect];
                view.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
                activityView=[[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                
                rect.origin.y = rect.size.height / 2 + activityView.bounds.size.height / 2 + 20.f;
                rect.size.height = 30.f;
                label = [[UILabel alloc] initWithFrame:rect];
                label.tag = 1;
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [view addSubview:activityView];
                [view addSubview:label];
                [window addSubview:view];
                activityView.center = activityView.superview.center;
                [activityView startAnimating];
            }
            else{
                label = (UILabel *)[activityView.superview viewWithTag:1];
            }
            label.text = message;
            
        }
        else{
            if (animating) {
                animating = NO;
                [activityView stopAnimating];
                [activityView.superview removeFromSuperview];
                activityView = nil;
            }
            
        }
    }
    
}

@end
