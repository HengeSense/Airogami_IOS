//
//  AGDefines.c
//  Airogami
//
//  Created by Tianhu Yang on 6/14/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

NSString* AGApplicationVersion = @"1.0";
NSString* AGWebServerUrl = @"http://192.168.0.7:8080/";
NSString* AGDataServerUrl = @"https://airogami-user-bucket.s3-us-west-2.amazonaws.com/";

const CGSize AGAccountIconSizeMedium = {512, 512};
const CGSize AGAccountIconSizeSmall = {128, 128};
const int AGAccountDescriptionMaxLength = 250;
const int AGAccountNameMaxLength = 35;
const int AGAccountScreenNameMaxLength = 35;
const int AGAccountScreenNameMinLength = 2;
const int AGAccountAgeMaxLength = 2;
const int AGAccountEmailMaxLength = 255;
const int AGAccountPasswordMaxLength = 15;
const int AGAccountPasswordMinLength = 6;

NSString * AGAccountNameShortKey = @"error.account.name.short";
NSString * AGAccountScreenNameShortKey = @"error.account.screenname.short";
NSString * AGAccountPasswordShortKey = @"error.account.password.short";
NSString * AGAccountPasswordNoMatchKey = @"error.account.password.nomatch";
NSString * AGAccountLocationEmptyKey = @"error.account.location.empty";
NSString * AGAccountEmailInvalidKey = @"error.account.email.invalid";
NSString * AGAccountIconRequireKey = @"error.account.icon.require";
NSString * AGAccountCurrentPasswordShortKey = @"error.account.currentpassword.short";
NSString * AGAccountNewPasswordShortKey = @"error.account.newpassword.short";
//logic
NSString * AGLogicJSONStatusKey = @"status";
NSString * AGLogicJSONMessageKey = @"message";
NSString * AGLogicJSONResultKey = @"result";
int AGLogicJSONStatusNotSignin = 1;

NSString * AGLogicAccountEmailKey = @"email";
NSString * AGLogicAccountPasswordKey = @"password";
NSString * AGLogicAccountScreenNameKey = @"screenName";

//error
NSString *AGHttpFailErrorTitleKey = @"error.connection.fail.title";
NSString *AGErrorTitleKey = @"title";
