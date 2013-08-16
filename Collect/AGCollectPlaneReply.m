//
//  AGCollectPlaneReplyView.m
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCollectPlaneReply.h"
#import <QuartzCore/QuartzCore.h>
#import "AGPlane.h"
#import "AGMessage.h"
#import "AGCategory+Addition.h"
#import "AGProfile.h"
#import "AGUtils.h"
#import "AGAccount.h"
#import "AGManagerUtils.h"
#import "AGUIDefines.h"
#import "AGDefines.h"

static NSString *ShoutNothing = @"text.ui.shout.nothing";

@interface AGCollectPlaneReply ()

@property (weak, nonatomic) IBOutlet UIView *contentContainer;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation AGCollectPlaneReply

- (void) layout
{
    CGRect frame = self.descriptionTextView.frame;
    frame.size.height = self.descriptionTextView.contentSize.height;
    if (frame.size.height < 64) {
        frame.size.height = 64;
    }
    self.descriptionTextView.frame = frame;
    //
    CGPoint point;
    point.y = frame.size.height;
    point = [self.descriptionTextView convertPoint:point toView:self.scrollView];
    frame = self.contentTextView.frame;
    frame.size.height = self.contentTextView.contentSize.height;
    self.contentTextView.frame = frame;
    //
    frame = self.contentContainer.frame;
    frame.origin.y = point.y;
    point.y = self.contentTextView.frame.size.height;
    point = [self.contentTextView convertPoint:point toView:self.contentContainer];
    frame.size.height = point.y;
    self.contentContainer.frame = frame;
    //
    point.y = frame.size.height;
    point = [self.contentContainer convertPoint:point toView:self.scrollView];
    frame.size = self.scrollView.contentSize;
    frame.size.height = point.y;
    self.scrollView.contentSize = frame.size;
}

-(void) show:(id)object
{
    [self initData:object];
    [self layout];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.replyView.alpha = 0.0f;
    [window addSubview:self.replyView];
    [UIView beginAnimations:@"ShowAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.3f];
    self.replyView.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void) initData:(id) object
{
    if ([object isKindOfClass:[AGPlane class]]) {
        AGPlane *plane = object;
        AGProfile *profile = plane.accountByOwnerId.profile;
        self.categoryLabel.text = [AGCategory title:plane.category.categoryId];
        self.ageLabel.text = [AGUtils birthdayToAge:profile.birthday];
        self.sexImageView.image = [AGUIDefines sexSymbolImage:profile.sex.intValue == AGAccountSexTypeMale];
        //
        AGDataManger *dataManager = [AGManagerUtils managerUtils].dataManager;
        NSURL *url = [dataManager accountIconUrl:plane.accountByOwnerId.accountId small:YES];
        [self.profileImageButton setImageUrl:url placeImage:[AGUIDefines profileDefaultImage]];
        url = [dataManager accountIconUrl:plane.accountByOwnerId.accountId small:NO];
        self.profileImageButton.mediumUrl = url;
        //
        self.nameLabel.text = profile.fullName;
        if(profile.shout.length){
            self.descriptionTextView.text = profile.shout;
        }
        else{
            self.descriptionTextView.text = NSLocalizedString(ShoutNothing, ShoutNothing);
        }
        
        //
        AGMessage *message = plane.messages.objectEnumerator.nextObject;
        self.contentTextView.text = message.content;
    }
}
     
- (void) dismiss
{
    [UIView beginAnimations:@"ShowAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:.3f];
    self.replyView.alpha = 0.0f;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.replyView removeFromSuperview];
}

- (IBAction)tossBack:(UIButton *)sender {
    [self dismiss];
}


- (IBAction)reply:(UIButton *)sender {
    [self dismiss];
}

+ (id) reply
{
    AGCollectPlaneReply *reply = [[AGCollectPlaneReply alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"AGCollectReplyView" owner:reply options:nil];
    
    reply.replyView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7f];
    CGRect frame = [UIScreen mainScreen].bounds;
    reply.replyView.frame = frame;
    
    reply.containerView.layer.cornerRadius = 5.0f;
    reply.containerView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 + 10);

    return reply;
}


@end
