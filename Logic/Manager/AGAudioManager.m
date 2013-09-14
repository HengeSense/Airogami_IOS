//
//  AGAudioManager.m
//  Airogami
//
//  Created by Tianhu Yang on 9/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAudioManager.h"
#include <AudioToolbox/AudioToolbox.h>

static const SystemSoundID ReceivedMessage = 1003;
static const SystemSoundID Notification = 1307;

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

- (void) playMessage
{
    AudioServicesPlayAlertSound(ReceivedMessage);
    //AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
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
