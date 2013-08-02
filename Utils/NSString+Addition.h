//
//  NSString+Addition.h
//  Airogami
//
//  Created by Tianhu Yang on 6/13/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Addition)
-(BOOL) isValidEmail;
- (BOOL)isNumeric;
- (NSString*) encodeURIComponent;
@end
