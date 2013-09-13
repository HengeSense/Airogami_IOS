//
//  AGAudioManager.m
//  Airogami
//
//  Created by Tianhu Yang on 9/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAudioManager.h"
#include <AudioToolbox/AudioToolbox.h>

@interface AGAudioManager()

@property(nonatomic) SystemSoundID messageSound;

@end

@implementation AGAudioManager

@synthesize messageSound;

-(id)init
{
    if (self = [super init]) {
        //NSURL *url = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] URLForResource:@"ReceivedMessage" withExtension:@"caf"];
        //AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &messageSound);
        messageSound = 1003;
    }
    return self;
}

- (void) playMessage
{
    AudioServicesPlayAlertSound(messageSound);
    //AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void) dealloc {
    
    AudioServicesDisposeSystemSoundID (messageSound);
}

@end
