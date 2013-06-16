
#import <CoreLocation/CoreLocation.h>

@protocol CLControllerDelegate <NSObject>
@required
- (void)locationUpdate:(CLLocation *)location withError:(NSError *)error;
@end

@interface CLController : NSObject

@property (nonatomic, assign) id <CLControllerDelegate> delegate;
- (void) start;
@end