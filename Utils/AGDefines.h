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
    AGCategoryRandom = 0,
    AGCategoryQuestion,
    AGCategoryConfession,
    AGCategoryRelationship,
    AGCategoryLocalInformation,
    AGCategoryFeeling,
    AGCategoryChain
} AGCategory;

typedef enum{
    AGCollectTypeReceived = 0,
    AGCollectTypePickuped
} AGCollectType;

extern const int AGApplicationVersion;
extern NSString* AGWebServerUrl;
extern NSString* AGDataServerUrl;

extern const int AGAccountDescriptionMaxLength;
extern const int AGAccountNameMaxLength;
extern const int AGAccountAgeMaxLength;
extern const int AGAccountEmailMaxLength;
extern const int AGAccountScreenNameMinLength;
extern const int AGAccountScreenNameMaxLength;
extern const int AGAccountPasswordMaxLength;
extern const int AGAccountPasswordMinLength;


extern  NSString * AGAccountNameShortKey;
extern  NSString * AGAccountPasswordShortKey;
extern  NSString * AGAccountPasswordNoMatchKey;
extern  NSString * AGAccountCurrentPasswordShortKey;
extern  NSString * AGAccountNewPasswordShortKey;
extern  NSString * AGAccountLocationEmptyKey;
extern  NSString * AGAccountEmailInvalidKey;
extern  NSString * AGAccountScreenNameShortKey;

extern  NSString * AGLogicJSONStatusKey;


#endif
