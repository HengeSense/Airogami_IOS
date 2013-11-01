//
//  AGChatChatViewController+Aided.h
//  Airogami
//
//  Created by Tianhu Yang on 10/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatChatViewController.h"

@interface AGChatChatViewController (Aided)

-(void) send;
-(void) sendImages:(NSArray*)images text:(NSString*)text;
-(void) clear;
@end
