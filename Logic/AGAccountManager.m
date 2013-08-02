//
//  AGAccountManager.m
//  Airogami
//
//  Created by Tianhu Yang on 7/30/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAccountManager.h"
#import "AGJSONHttpHandler.h"
#import "NSString+Addition.h"
#import "AGUIUtils.h"
#import "AGDefines.h"

static NSString *SignupPath = @"account/emailSignup.action?";
static int SignupStatusDuplicate = 10003;

@implementation AGAccountManager

- (void) signup:(NSMutableDictionary*) params
{
    NSMutableString *path = [NSMutableString stringWithCapacity:1024];
    [path appendString:SignupPath];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *value = obj;
        [path appendString:key];
        [path appendString:@"="];
        [path appendString:[value encodeURIComponent]];
        [path appendString:@"&"];
     
    }];
    [path appendString:@"version=1.0"];
    [[AGJSONHttpHandler handler] start:path block:^(NSError *error, NSMutableDictionary *dict) {
        if (error) {
            [AGUIUtils alertMessageWithTitle:NSLocalizedString(@"error.network.connection", @"error.network.connection") error:error];
        }
        else{
            NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
            if (status.intValue == 0) {
                [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.signup.succeed", @"msesage.signup.succeed")];
            }
            else if (status.intValue == SignupStatusDuplicate){
                [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.signup.duplicate", @"msesage.signup.duplicate")];
            }else{
                [AGUIUtils alertMessageWithTitle:@"" message:NSLocalizedString(@"message.server.unkown", @"message.server.unkown")];
            }
        
        }
    }];
}

@end
