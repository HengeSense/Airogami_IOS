//
//  AGAccount.m
//  Airogami
//
//  Created by Tianhu Yang on 10/23/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGAccount.h"
#import "AGAccountStat.h"
#import "AGAuthenticate.h"
#import "AGChain.h"
#import "AGChainMessage.h"
#import "AGHot.h"
#import "AGMessage.h"
#import "AGNeoAccount.h"
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
@dynamic neoAccount;
@dynamic planesForOwnerId;
@dynamic planesForTargetId;
@dynamic profile;
@dynamic hot;

@end
