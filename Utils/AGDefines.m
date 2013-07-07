//
//  AGDefines.c
//  Airogami
//
//  Created by Tianhu Yang on 6/14/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

const int AGApplicationVersion = 1;
const int AGAccountDescriptionMaxLength = 250;
const int AGAccountNameMaxLength = 100;
const int AGAccountScreenNameMaxLength = 100;
const int AGAccountAgeMaxLength = 2;
const int AGAccountEmailMaxLength = 256;
const int AGAccountPasswordMaxLength = 15;
const int AGAccountPasswordMinLength = 6;

NSString * AGAccountNameShortKey = @"error.account.name.short";
NSString * AGAccountScreenNameShortKey = @"error.account.screenname.short";
NSString * AGAccountPasswordShortKey = @"error.account.password.short";
NSString * AGAccountPasswordNoMatchKey = @"error.account.password.nomatch";
NSString * AGAccountLocationEmptyKey = @"error.account.location.empty";
NSString * AGAccountEmailInvalidKey = @"error.account.email.invalid";
NSString * AGAccountCurrentPasswordShortKey = @"error.account.currentpassword.short";
NSString * AGAccountNewPasswordShortKey = @"error.account.newpassword.short";
