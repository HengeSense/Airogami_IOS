#import "CLController.h"

@interface CLController() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation CLController
@synthesize locationManager;
@synthesize delegate;


- (id) init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self; // send loc updates to myself
	}
	return self;
}
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	[self.delegate locationUpdate:newLocation withError:nil];
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	[self.delegate locationUpdate:nil withError:error];
}

-(void) start
{
    [self.locationManager startUpdatingLocation];
}

-(void) stop
{
    [self.locationManager stopUpdatingLocation];
}

@end
