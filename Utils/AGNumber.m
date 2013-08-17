//
//  AGNumber.m
//  Airogami
//
//  Created by Tianhu Yang on 8/16/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGNumber.h"

@implementation AGNumber

@synthesize number;


-(id) init
{
    if (self = [super init]) {
        number = [NSNumber numberWithInt:0];
    }
    return self;
}
@end
