//
//  AGMessage+Addition.m
//  Airogami
//
//  Created by Tianhu Yang on 10/29/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGMessage+Addition.h"
#import "AGAccount.h"
#import "NSString+Addition.h"

//static NSString *AGContentTypes[] = {@".audio", @".jpg"};

static NSString *AGImageSizes[] = {@"medium", @""};

@implementation AGMessage (Addition)


//accounts/reversed accountId/messagedata/reversed msgDataInc
- (NSURL*) messageImageUrl:(BOOL)small
{
    assert(self.type.shortValue == AGMessageTypeImage);
    NSURL *url = nil;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@accounts/%@/messagedata/%@%@.jpg", AGDataServerUrl, self.account.accountId.stringValue.reverseString, self.link.reverseString, AGImageSizes[small]]];
    return url;
}

//for save images
- (NSString*) messageDataKey:(BOOL)small
{
    NSString *key = [NSString stringWithFormat:@"%@%@", self.objectID.URIRepresentation.absoluteString, AGImageSizes[small]];
    return key;
}

-(CGSize) imageSize
{
    assert(self.type.intValue == AGMessageTypeImage);
    CGSize size;
    int messure = self.prop.intValue;
    size.width = messure >> 16;
    size.height = messure & 0xffff;
    return size;
}

-(void) setImageSize:(CGSize)imageSize
{
    int messure = 0;
    messure = imageSize.height;
    messure += (int)(imageSize.width) << 16;
    self.prop = [NSNumber numberWithInt:messure];
}

@end
