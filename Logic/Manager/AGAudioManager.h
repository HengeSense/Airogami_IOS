//
//  AGAudioManager.h
//  Airogami
//
//  Created by Tianhu Yang on 9/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGAudioManager : NSObject

- (void) playReceivedMessage;

- (void) playReceivedMessageWhenViewing;

- (void) playSentMessage;

- (void) playNotification;

@end
