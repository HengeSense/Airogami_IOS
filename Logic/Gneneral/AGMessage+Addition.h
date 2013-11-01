//
//  AGMessage+Addition.h
//  Airogami
//
//  Created by Tianhu Yang on 10/29/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGMessage.h"

@interface AGMessage (Addition)

@property(nonatomic, assign) CGSize imageSize;

- (NSURL*) messageImageURL:(BOOL)small;
- (NSURL*) messageLocalImageURL:(BOOL)small;
@end
