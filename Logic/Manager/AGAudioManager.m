//
//  AGAudioManager.m
//  Airogami
//
//  Created by Tianhu Yang on 9/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAudioManager.h"
#include <AudioToolbox/AudioToolbox.h>

static const SystemSoundID ReceivedMessage = 1307;
static const SystemSoundID ReceivedMessageWhenViewing = 1003;
static const SystemSoundID SentMessage = 1004;
static const SystemSoundID Notification = 1071;

@interface AGAudioManager()
{
}


@end

@implementation AGAudioManager


-(id)init
{
    if (self = [super init]) {
        //NSURL *url = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] URLForResource:@"ReceivedMessage" withExtension:@"caf"];
        //AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &messageSound);
    }
    return self;
}

- (void) playReceivedMessage
{
    AudioServicesPlayAlertSound(ReceivedMessage);
}

- (void) playReceivedMessageWhenViewing
{
    AudioServicesPlayAlertSound(ReceivedMessageWhenViewing);
    //AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void) playSentMessage
{
    AudioServicesPlayAlertSound(SentMessage);
}

- (void) playNotification
{
    AudioServicesPlayAlertSound(Notification);
    //AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void) dealloc {
    
    //AudioServicesDisposeSystemSoundID (messageSound);
}

@end
