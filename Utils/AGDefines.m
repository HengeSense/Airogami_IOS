//
//  AGDefines.c
//  Airogami
//
//  Created by Tianhu Yang on 6/14/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//
#import "AGDefines.h"

const int AGDeviceType = 1;
const int AGApplicationVersion = 1;
//http://192.168.0.6:8080/
NSString* AGWebServerUrl = @"http://ec2-50-112-76-55.us-west-2.compute.amazonaws.com/airogami/";//http://ec2-50-112-76-55.us-west-2.compute.amazonaws.com/airogami/
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
const int AGAccountMessageContentMaxLength = 255;

NSString * AGAccountNameShortKey = @"error.account.name.short";
NSString * AGAccountScreenNameShortKey = @"error.account.screenname.short";
NSString * AGAccountPasswordShortKey = @"error.account.password.short";
NSString * AGAccountPasswordNoMatchKey = @"error.account.password.nomatch";
NSString * AGAccountLocationEmptyKey = @"error.account.location.empty";
NSString * AGAccountEmailInvalidKey = @"error.account.email.invalid";
NSString * AGAccountBirthdayRequireKey = @"error.account.birthday.require";
NSString * AGAccountIconRequireKey = @"error.account.icon.require";
NSString * AGAccountCurrentPasswordShortKey = @"error.account.currentpassword.short";
NSString * AGAccountNewPasswordShortKey = @"error.account.newpassword.short";
NSString * AGAccountShoutNothing = @"text.ui.shout.nothing";

//plane
NSString *AGPlaneSendPlaneOK = @"message.plane.sendplane.ok";
NSString *AGPlaneSendPlaneLimit = @"message.plane.sendplane.limit";
//logic
NSString * AGLogicJSONStatusKey = @"status";
NSString * AGLogicJSONMessageKey = @"message";
NSString * AGLogicJSONResultKey = @"result";
NSString * AGLogicJSONSucceedKey = @"succeed";
NSString * AGLogicJSONErrorKey = @"error";
NSString * AGLogicJSONAccountStatLeftKey = @"accountStatLeft";
NSString * AGLogicJSONNoneValue = @"none";
int AGLogicJSONStatusNotSignin = 1;
int AGLogicJSONStatusSigninElsewhere = 2;
int AGLogicJSONStatusInput = 101;

NSString * AGLogicAccountEmailKey = @"email";
NSString * AGLogicAccountPasswordKey = @"password";
NSString * AGLogicAccountScreenNameKey = @"screenName";

//error
NSString *AGHttpFailErrorTitleKey = @"error.connection.fail.title";
NSString *AGErrorTitleKey = @"title";
