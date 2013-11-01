//
//  AGPhotoView.m
//  Airogami
//
//  Created by Tianhu Yang on 7/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGPhotoView.h"
#import "AGPhotoScrollView.h"
#import "AGPhotoLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString *DownloadDone = @"1";
static NSString *DownloadNo = @"0";

@interface AGPhotoView()<AGPhotoScrollViewDelegate>
{
    JPRadialProgressView *progressView;
    NSMutableString  *download;
    id source;
    //text
    AGPhotoLabel *label;
}
@property(nonatomic, assign) CGRect originalFrame;

@end

@implementation AGPhotoView

@synthesize originalFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        originalFrame = frame;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;
        download = [NSMutableString stringWithString:DownloadDone];
    }
    return self;
}

- (void) preview:(UIImage*)sImage medium:(id)medium soure:(id)aSource text:(NSString*)text
{
    if (text.length) {
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        CGRect frame = window.bounds;
        label = [[AGPhotoLabel alloc] initWithFrame:frame];
        label.text = text;
        frame.size.height = [label sizeThatFits:frame.size].height;
        label.frame = frame;
    }
    
    [self preview:sImage medium:medium soure:aSource];
}

- (void) preview:(UIImage*)sImage medium:(id)medium soure:(id)aSource
{
    source = aSource;
    self.userInteractionEnabled = NO;
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    
    NSMutableString *finished = download;
    if (medium == nil) {
        self.image = sImage;
    }
    else if([medium isKindOfClass:[UIImage class]]){
        self.image = medium;
    }
    else if([medium isKindOfClass:[NSURL class]]){
        NSURL *url = medium;
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        UIImage *image = [imageCache imageFromDiskCacheForKey:url.absoluteString];
        if (image == nil) {
            image = sImage;
        }
        finished.string = DownloadNo;
        CGRect frame = CGRectMake(0, 0, 50, 50);
        progressView = [[JPRadialProgressView alloc] initWithFrame:frame];
        JPRadialProgressView *rpv = progressView;
        [self setImageWithURL:url placeholderImage:image options:SDWebImageRefreshCached progress:^(NSUInteger receivedSize, long long expectedSize) {
            rpv.progress = receivedSize / (double)expectedSize;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            finished.string = DownloadDone;
            [rpv removeFromSuperview];
        }];
        
    }
    
    CGRect frame;
    CGSize size = window.bounds.size;
    frame.size = [self adjustSize];
    frame.origin.x = (size.width - frame.size.width) / 2;
    frame.origin.y = (size.height - frame.size.height) / 2;
    [UIView beginAnimations:@"ProfileImageButtonAnimations" context:nil];
    self.frame = frame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showDidStop:finished:context:)];
    [UIView commitAnimations];
}

- (void) setImage:(UIImage *)image
{
    [super setImage:image];
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *) self.superview;
        scrollView.zoomScale = 1.0f;
        CGRect bounds = self.bounds;
        bounds.size = [self adjustSize];
        self.bounds = bounds;
        self.center = self.superview.center;
        scrollView.contentSize = bounds.size;
        
    }
    
}

// based on image size
- (CGSize) adjustSize
{
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *window = [application.delegate window];
    CGSize size = window.bounds.size;
    size.height -= application.statusBarFrame.size.height;
    CGSize newSize = self.image.size;
    if (newSize.width > size.width ) {
        newSize.width = size.width;
    }
    if (newSize.height > size.height ) {
        newSize.height = size.height;
    }
    return newSize;
}

-(void)showDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    AGPhotoScrollView *scrollView = [[AGPhotoScrollView alloc] initWithFrame:window.bounds];
    scrollView.photoScrollViewDelegate = self;
    scrollView.delegate = self;
    CGRect bounds = self.bounds;
    bounds.size = [self adjustSize];
    self.bounds = bounds;
    self.center = self.superview.center;
    scrollView.contentSize = bounds.size;
    [window addSubview:scrollView];
    [scrollView addSubview:self];
    //progress
    if ([DownloadNo isEqual:download]) {
        [window addSubview:progressView];
        progressView.center = progressView.superview.center;
    }
    self.userInteractionEnabled = YES;
    //text
    if (label) {
        [scrollView addSubview:label];
        label.center = scrollView.center;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self;
}

// keep view in center when image is small than scrollView
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
    
}

-(void) scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    label.hidden = YES;
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //text
    label.hidden = scrollView.zoomScale != 1.0f;
}

- (void) dismiss
{
    //text
    label.hidden = YES;
    //
    self.userInteractionEnabled = NO;
    UIScrollView *scrollView = (UIScrollView *) self.superview;
    scrollView.zoomScale = 1.0f;
    [UIView beginAnimations:@"ProfileImageButtonAnimations" context:nil];
    self.frame = originalFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

-(void) dismissDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.superview removeFromSuperview];
    [self removeFromSuperview];
    [progressView removeFromSuperview];
    [source setValue:[NSNumber numberWithBool:YES] forKey:@"done"];
}

@end
