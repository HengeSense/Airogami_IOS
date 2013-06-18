//
//  ALTabBarView.m
//  ALCommon
//
//  Created by Andrew Little on 10-08-17.
//  Copyright (c) 2010 Little Apps - www.myroles.ca. All rights reserved.
//

#import "YTTabBar.h"


@implementation YTTabBar

@synthesize tabBarItems, delegate;


- (id)initWithFrame:(CGRect)frame count:(int)count {
    int itemWidth = frame.size.width / count;
    if ((self = [super initWithFrame:frame])) {
        frame.origin.y = 0;
        frame.origin.x = 0;
        frame.size.width = itemWidth;
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < count; ++i) {
            YTTabBarItem * tabBarItem = [[YTTabBarItem alloc] initWithFrame:frame index:i];
            [array addObject:tabBarItem];
            [self addSubview:tabBarItem];
            tabBarItem.delegate = self;
            frame.origin.x += itemWidth;
        }
        tabBarItems = array;
    }
    return self;
}


- (void) onSelected:(int)index
{
    seletedTabBarItem.selected = NO;
    seletedTabBarItem = [tabBarItems objectAtIndex:index];
    [delegate onSelect:index];
}

-(void) selectTab:(int)index
{
    seletedTabBarItem.selected = NO;
    seletedTabBarItem = [tabBarItems objectAtIndex:index];
    seletedTabBarItem.selected = YES;
}

@end
