//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "AGBubbleTableViewDelegate.h"
#import "AGManagerUtils.h"
#import "AGUIUtils.h"
#import "SDImageCache+Addition.h"
#import <SDWebImage/UIButton+WebCache.h>

#define kMineLeftCapWidth 22
#define kMineTopCapWidth 17

#define kSomeoneLeftCapWidth 21
#define kSomeoneTopCapWidth 17


@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIButton *contentButton;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIButton *avatarButton;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize label;
@synthesize contentButton;
@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarButton = _avatarButton;
@synthesize stateButton = _stateButton;
@synthesize bubbleTableView;

- (id) init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.avatarButton.layer.cornerRadius = 5.0;
    self.avatarButton.layer.masksToBounds = YES;
    self.avatarButton.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
    self.avatarButton.layer.borderWidth = 1.0;
    [self.avatarButton addTarget:self action:@selector(avatarImageTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.avatarButton];
    //
#if !__has_feature(objc_arc)
    self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
    self.bubbleImage = [[UIImageView alloc] init];
#endif
    [self.contentView addSubview:self.bubbleImage];
    //
    self.stateButton = [[AGBubbleCellStateButton alloc] init];
    [self.stateButton addTarget:self action:@selector(stateImageTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.stateButton];
    self.backgroundColor = [UIColor clearColor];
    //label
    label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = NSBubbleData.font;
    label.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:label];
    //contentButton
    contentButton = [[UIButton alloc] init];
    contentButton.layer.cornerRadius = 5.0;
    contentButton.layer.masksToBounds = YES;
    [self.contentView addSubview:contentButton];
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = self.frame;
    [super setFrame:frame];
    if (self.data && CGRectEqualToRect(rect, frame) == NO) {
        [self setupInternalData];
    }

}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarButton = nil;
    [super dealloc];
}
#endif


- (void)setData:(NSBubbleData *)data
{
    _data = data;
    
    NSBubbleType type = data.type;
    if (self.showAvatar) {
        self.avatarButton.hidden = NO;
        if (data.account) {
            NSURL *url = [data.account accountIconUrl:YES];
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            UIImage *image = [imageCache imageFromDiskCacheForKey:url.absoluteString];
            if (image) {
                image = [AGUIDefines profileDefaultImage];
            }
            [self.avatarButton setImageWithURL:url forState:UIControlStateNormal placeholderImage:image options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
#ifdef IS_DEBUG
                if (error) {
                    NSLog(@"UIBubbleTableViewCell.setData: %@", error);
                }
#endif
                
            }];
        }
        else{
            UIImage *image = self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"];
            [self.avatarButton setBackgroundImage:image forState:UIControlStateNormal];
        }
        
    }
    else
    {
        self.avatarButton.hidden = YES;
    }
    //
    label.hidden = contentButton.hidden = YES;
    //
    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:kSomeoneLeftCapWidth topCapHeight:kSomeoneTopCapWidth];
        
    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:kMineLeftCapWidth topCapHeight:kMineTopCapWidth];
    }
    //set image
    UIImage *image = nil;
    if (data.imageKey) {
        image = [[SDImageCache imageCache] imageFromDiskCacheForKey:self.data.imageKey];
    }
    else if(data.image){
        image = data.image;
    }
    //
    if (image) {
        [contentButton setImage:image forState:UIControlStateNormal];
        contentButton.hidden = NO;
        self.customView = contentButton;
    }
    else if(data.imageURL){
        contentButton.hidden = NO;
        self.customView = contentButton;
        [contentButton setImageWithURL:self.data.imageURL forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
#ifdef IS_DEBUG
            if (error) {
                NSLog(@"initWithImageKey: error=%@", error);
            }
#endif
        }];
    }
    else{
        label.hidden = NO;
        self.customView = label;
    }
    //[self setupInternalData];
}

- (void) stateImageTouched
{
    switch (self.data.state) {
        case AGSendStateFailed:
            [bubbleTableView didSelectCellAtIndexPath:[bubbleTableView indexPathForCell:self] bubbleData:self.data type:UIBubbleCellSelectSendFailed];
            break;
        default:
            break;
    }

}

- (void) avatarImageTouched
{
    [bubbleTableView didSelectCellAtIndexPath:[bubbleTableView indexPathForCell:self] bubbleData:self.data type:UIBubbleCellSelectAvatar];
}

- (void) setupInternalData
{
    
    NSBubbleType type = self.data.type;
    CGRect frame = CGRectMake(0, 0, self.data.size.width, self.data.size.height);
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    
    //important: make the bubble image not too small
    if (width + self.data.insets.left + self.data.insets.right < 45) {
        width = 45 - (self.data.insets.left + self.data.insets.right);
    }

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        if (type == BubbleTypeSomeoneElse) x += (kAvartarHeight + kAvatarMargin * 2);
        if (type == BubbleTypeMine) x -= (kAvartarHeight + kAvatarMargin * 2);
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? kAvatarMargin : self.frame.size.width - (kAvartarHeight + kAvatarMargin);
        CGFloat avatarY = self.frame.size.height - kAvartarHeight - kCellSpacing;
        
        self.avatarButton.frame = CGRectMake(avatarX, avatarY, kAvartarHeight, kAvartarHeight);
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.size.height) - kCellSpacing;
        if (delta > 0) y = delta;
    }
    
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    frame = self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
    //state
    if (type == BubbleTypeMine) {
        self.stateButton.frame = CGRectMake(0, 0 , kBubbleCellStateButtonWidth, kBubbleCellStateButtonWidth);
        self.stateButton.center = CGPointMake(x - kBubbleCellStateButtonWidth / 2 + 3, y  + self.data.insets.top + height / 2);
        self.stateButton.cellState = self.data.state;
    }
    else{
        self.stateButton.frame = CGRectMake(0, 0 , kBubbleCellStateButtonWidth, kBubbleCellStateButtonWidth);
        self.stateButton.center = CGPointMake(frame.origin.x + frame.size.width + kBubbleCellStateButtonWidth / 2 - 4, frame.origin.y + frame.size.height / 2);
        self.stateButton.cellState = AGSendStateNone;
    }
    
}

- (void) refresh:(NSArray*)fields
{
    for (NSString *field in fields) {
        if ([field isEqualToString:@"state"]) {
            if (self.data.type == BubbleTypeMine){
                self.stateButton.cellState = self.data.state;
            }
            
        }
    }
    
}

@end
