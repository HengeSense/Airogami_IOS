//
//  AGChatChatPullDownHeader.h
//  Airogami
//
//  Created by Tianhu Yang on 8/20/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGChatChatPullDownHeaderDelegate <NSObject>

- (void) refresh;

@end

@interface AGChatChatPullDownHeader : NSObject<UITableViewDelegate>

@property(nonatomic, weak) id<AGChatChatPullDownHeaderDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *pullDownView;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

+ (id) header;

@end
