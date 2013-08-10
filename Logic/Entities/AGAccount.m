//
//  AGAccount.m
//  Airogami
//
//  Created by Tianhu Yang on 8/9/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAccount.h"
#import "AGAccountStat.h"
#import "AGAuthenticate.h"
#import "AGChain.h"
#import "AGChainMessage.h"
#import "AGMessage.h"
#import "AGPlane.h"
#import "AGProfile.h"


@implementation AGAccount

@dynamic accountId;
@dynamic updateCount;
@dynamic accountStat;
@dynamic authenticate;
@dynamic chainMessages;
@dynamic chains;
@dynamic messages;
@dynamic planesForOwnerId;
@dynamic planesForTargetId;
@dynamic profile;

@end
