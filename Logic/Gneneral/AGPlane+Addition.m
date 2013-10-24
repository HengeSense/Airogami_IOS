//
//  AGPlane+Addition.m
//  Airogami
//
//  Created by Tianhu Yang on 10/23/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPlane+Addition.h"
#import "AGAppDirector.h"

@implementation AGPlane (Addition)

-(BOOL) isOwner
{
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    return [accountId isEqualToNumber:self.accountByOwnerId.accountId];
}

-(BOOL) isLiked
{
    BOOL isLiked;
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    if ([accountId isEqualToNumber:self.accountByOwnerId.accountId]) {
        isLiked = self.likedByT.boolValue;
    }
    else{
        isLiked = self.likedByO.boolValue;
    }
    return isLiked;
}

-(BOOL) hasLiked
{
    BOOL hasLiked;
    NSNumber *accountId = [AGAppDirector appDirector].account.accountId;
    if ([accountId isEqualToNumber:self.accountByOwnerId.accountId]) {
        hasLiked = self.likedByO.boolValue;
    }
    else{
        hasLiked = self.likedByT.boolValue;
    }
    return hasLiked;
}

@end
