//
//  AGAuthenticate.h
//  Airogami
//
//  Created by Tianhu Yang on 8/12/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AGAccount;

@interface AGAuthenticate : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) AGAccount *account;

@end
