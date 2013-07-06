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
extern const int AGAccountDescriptionMaxLength;
extern const int AGAccountNameMaxLength;
extern const int AGAccountAgeMaxLength;
extern const int AGAccountEmailMaxLength;

#endif
