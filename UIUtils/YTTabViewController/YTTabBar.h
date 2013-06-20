
#import <UIKit/UIKit.h>
#import "YTTabBarItem.h"

@protocol YTTabBarDelegate <NSObject>

-(void) onSelect:(int) index;

@end

@interface YTTabBar : UIImageView <YTTabBarItemDelegate> {

    YTTabBarItem *seletedTabBarItem;
}

@property(nonatomic, strong) NSArray *tabBarItems;
@property(nonatomic, assign) NSObject<YTTabBarDelegate> *delegate;

- (id)initWithFrame:(CGRect)frame count:(int)count selected:(int) index;
- (void) selectTab:(int) index;

@end
