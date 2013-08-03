//
//  AGProfileManager.m
//  Airogami
//
//  Created by Tianhu Yang on 8/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGProfileManager.h"
#import "AGUploadHttpHandler.h"
#import "AGUIUtils.h"


@implementation AGProfileManager

- (void) uploadIcon:(NSMutableDictionary *)params image:(UIImage *)image
{
    NSString *path = [params objectForKey:@"key"];
    [[AGUploadHttpHandler handler] uploadImage:path params:params image:image block:^(NSError *error) {
        if (error) {
            if ([error.domain isEqualToString:@"Server Error"]) {
                [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.server.unkown", @"message.server.unkown")];
            }
            else{
                [AGUIUtils alertMessageWithTitle:NSLocalizedString(@"error.network.connection", @"error.network.connection") error:error];
            }
            
        }
        else{
            //succceed
            NSLog(@"uploadIcon successfully");
        }
    }];
}

@end
