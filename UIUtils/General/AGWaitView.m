//
//  AGWaitView.m
//  Airogami
//
//  Created by Tianhu Yang on 6/26/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGWaitView.h"

@implementation AGWaitView

@synthesize imageView;

-(id) initWithName:(NSString *)name count:(int)count
{

    CGRect frame = [UIScreen mainScreen].bounds;
    self =  [[AGWaitView alloc] initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        UIImage *image = nil;
        for (int i = 0; i < count; ++i) {
            NSString *path = [NSString stringWithFormat:@"%@%d.png", name, i];
            image = [UIImage imageNamed:path];
            [array addObject:image];
        }
        frame.origin = self.center;
        frame.size = image.size;
        frame.origin.x -= frame.size.width / 2;
        frame.origin.y -= frame.size.height / 2;
        UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
        imageView = iv;
        imageView.animationImages = array;
        imageView.animationRepeatCount = 0;
        imageView.animationDuration = 5.0f;
        [self addSubview:imageView];
    }
    
    return self;
}

- (void) start
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    [imageView startAnimating];
}

- (void) stop
{
    [imageView stopAnimating];
    [self removeFromSuperview];
}

+ (AGWaitView*) radarWaitView
{
    return [[AGWaitView alloc] initWithName:@"radarsprite_" count:189];
}

@end
