//
//  ImageCropper.m
//  Created by http://github.com/iosdeveloper
//

#import "YTImageCropper.h"
#import "AGUtils.h"

@interface YTImageCropper()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation YTImageCropper

@synthesize scrollView, imageView;
@synthesize delegate;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void) viewDidLoad
{
    CGRect rect;
    CGSize imageSize = image.size;
    imageView.image = image;
    rect.origin = CGPointZero;
    rect.size.width = imageSize.width;
    rect.size.height = imageSize.height;
    [imageView setFrame:rect];
       
}

- (void) viewDidLayoutSubviews
{
    
    
    CGSize size = self.scrollView.bounds.size;
    float gap = (size.height - size.width) / 2;
    UIEdgeInsets edgeInsets = {gap , 0, gap, 0};
    scrollView.contentInset = edgeInsets;
    [scrollView setContentSize:imageView.frame.size];
    [scrollView setMinimumZoomScale:scrollView.frame.size.width / imageView.frame.size.width];
    [scrollView setZoomScale:scrollView.minimumZoomScale];

}

- (id)initWithImage:(UIImage *)aImage {
	self = [super initWithNibName:@"YTImageCropper" bundle:nil];
	
	if (self) {
		image = [AGUtils normalizeImage:aImage];
	}
	
	return self;
}

- (IBAction)cancelCropping:(id)sender {
    [delegate imageCropperDidCancel:self]; 
}

- (IBAction)finishCropping {
	float zoomScale = 1.0 / [scrollView zoomScale];
	
	CGRect rect;
    CGSize maskSize = scrollView.bounds.size;
	rect.origin.x = [scrollView contentOffset].x * zoomScale;
	rect.origin.y = ([scrollView contentOffset].y + (maskSize.height - maskSize.width) / 2) * zoomScale;
	rect.size.width = maskSize.width * zoomScale;
	rect.size.height = maskSize.width * zoomScale;

	CGImageRef cr = CGImageCreateWithImageInRect([[imageView image] CGImage], rect);
	
	UIImage *cropped = [UIImage imageWithCGImage:cr scale:1.0f orientation:image.imageOrientation];
	
	CGImageRelease(cr);
	
	[delegate imageCropper:self didFinishCroppingWithImage:cropped];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

@end