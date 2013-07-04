//
//  AGCollectPlaneViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/24/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGCollectPlaneViewController.h"
#import "AGCollectPlaneCell.h"
#import "AYUIButton.h"
#import "AGCollectPlanePickupView.h"
#import "AGCollectPlaneReply.h"
#import "AGCollectPlaneNumberView.h"

@interface AGCollectPlaneViewController ()
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property(nonatomic, strong) AGCollectPlanePulldownHeader *pulldownHeader;
@property (strong, nonatomic)  AGCollectPlanePickupView *pickupView;
@property (strong, nonatomic)  AGCollectPlaneReply *reply;
@property (strong, nonatomic)  AGCollectPlaneNumberView *numberView;

@end

@implementation AGCollectPlaneViewController

@synthesize pulldownHeader, pickupView, reply;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        pickupView = [[AGCollectPlanePickupView alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"AGCollectPlaneHeaderView" owner:self options:nil];
        pulldownHeader = [AGCollectPlanePulldownHeader header];
        reply = [AGCollectPlaneReply reply];
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    UITableView *tv = (UITableView*)self.view;
    CGRect frame = self.view.frame;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [AGUIDefines mainBackgroundImage];
    imageView.userInteractionEnabled = YES;
    self.view = imageView;
    [self.view addSubview:tv];
    [self.view addSubview:self.headerView];
    
    frame.origin.y = self.headerView.bounds.size.height;
    frame.size.height -= frame.origin.y;
    tv.frame = frame;
    
    frame = pulldownHeader.pulldownView.frame;
    frame.origin.y = 52;
    pulldownHeader.pulldownView.frame = frame;
    [tv addSubview:pulldownHeader.pulldownView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    pulldownHeader.delegate = self;
    //numberView = [AGCollectPlaneNumberView numberView:self.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refresh
{
    [pickupView show];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AGCollectPlaneCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.category = indexPath.row;
    cell.aidedButton.tag = indexPath.row;
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.reply show];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
    [pulldownHeader scrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[pulldownHeader scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	
}

- (void)viewDidUnload {
    [self setHeaderView:nil];
    [self setPickupView:nil];
    [super viewDidUnload];
}
@end
