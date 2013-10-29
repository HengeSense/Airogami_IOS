//
//  AGDefines.h
//  Airogami
//
//  Created by Tianhu Yang on 6/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#ifndef Airogami_AGDefines_h
#define Airogami_AGDefines_h
#import <UIKit/UIKit.h>

typedef enum{
    AGCategoryChain = 0,
    AGCategoryRandom,
    AGCategoryQuestion,
    AGCategoryConfession,
    AGCategoryRelationship,
    AGCategoryLocalInformation,
    AGCategoryFeeling,
    AGCategoryUnknown
} AGPlaneCategoryEnum;

//content type
typedef enum{
    AGContentTypeAudio = 12,
    AGContentTypeImage = 13
}AGContentTypeEnum;

typedef enum{
    AGMessageTypeLike = 10,
    AGMessageTypeText,
    AGMessageTypeAudio = AGContentTypeAudio,
    AGMessageTypeImage = AGContentTypeImage,
} AGMessageTypeEnum;

typedef enum
{
    AGSendStateNone = -2,
    AGSendStateSending = -1,
    AGSendStateSent = 0,
    AGSendStateFailed = 1,
    AGSendStateRead = 2
} AGSendStateEnum;

typedef enum{
    AGPlaneStatusNew = 0,
    AGPlaneStatusReplied
} AGPlaneStatusEnum;

typedef enum{
    AGChainMessageStatusNew = 0,
    AGChainMessageStatusReplied,
    AGChainMessageStatusDeleted
} AGChainMessageStatusEnum;

typedef enum{
    AGCollectTypeReceived = 0,
    AGCollectTypePickuped
} AGCollectType;

typedef enum{
    AGAccountSexTypeUnkown = 0,
    AGAccountSexTypeMale,
    AGAccountSexTypeFemale
} AGAccountSexType;

#define IS_DEBUG

extern const int AGDeviceType;
extern const int AGApplicationVersion;
extern NSString* AGWebServerUrl;
extern NSString* AGDataServerUrl;

extern const CGSize AGAccountIconSizeMedium;
extern const CGSize AGAccountIconSizeSmall;
extern const int AGAccountDescriptionMaxLength;
extern const int AGAccountNameMaxLength;
extern const int AGAccountAgeMaxLength;
extern const int AGAccountEmailMaxLength;
extern const int AGAccountScreenNameMinLength;
extern const int AGAccountScreenNameMaxLength;
extern const int AGAccountPasswordMaxLength;
extern const int AGAccountPasswordMinLength;
extern const int AGAccountMessageContentMaxLength;



extern  NSString * AGAccountNameShortKey;
extern  NSString * AGAccountPasswordShortKey;
extern  NSString * AGAccountPasswordNoMatchKey;
extern  NSString * AGAccountCurrentPasswordShortKey;
extern  NSString * AGAccountNewPasswordShortKey;
extern  NSString * AGAccountLocationEmptyKey;
extern  NSString * AGAccountEmailInvalidKey;
extern  NSString * AGAccountScreenNameShortKey;
extern  NSString * AGAccountBirthdayRequireKey;
extern  NSString * AGAccountIconRequireKey ;
extern  NSString * AGAccountShoutNothing;

//plane

extern  NSString *AGPlaneSendPlaneOK;
extern  NSString *AGPlaneSendPlaneLimit;
#define AGChainSendChainOK AGPlaneSendPlaneOK
#define AGChainSendChainLimit AGPlaneSendPlaneLimit

extern  NSString * AGLogicJSONStatusKey;
extern  NSString * AGLogicJSONMessageKey;
extern  NSString * AGLogicJSONResultKey;
extern  NSString * AGLogicJSONSucceedKey;
extern  NSString * AGLogicJSONErrorKey;
extern  NSString * AGLogicJSONAccountStatLeftKey;
extern  NSString * AGLogicJSONNoneValue;
extern  NSString * AGLogicJSONDataValue;

extern  NSString * AGLogicAccountEmailKey;
extern  NSString * AGLogicAccountPasswordKey;
extern  NSString * AGLogicAccountScreenNameKey;
extern  NSString * AGLogicAccountUuidKey;
extern int AGLogicJSONStatusNotSignin;
extern int AGLogicJSONStatusSigninElsewhere;
extern int AGLogicJSONStatusInput;

//error
extern NSString *AGHttpFailErrorTitleKey;
extern NSString *AGErrorTitleKey;

//block
typedef void (^AGHttpDoneBlock)(NSError *error, id context);
typedef void (^AGHttpFinishBlock)(NSError *error, id context, NSMutableDictionary *result);
typedef void (^AGHttpSucceedBlock)(NSError *error, id context, BOOL succeed);

#endif
