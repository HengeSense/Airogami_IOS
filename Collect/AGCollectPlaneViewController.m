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
#import "AGManagerUtils.h"
#import "AGPlane.h"
#import "AGChain.h"
#import "AGUtils.h"
#import "AGCategory.h"
#import "AGMessage.h"
#import "AGNotificationCenter.h"
#import "AGControllerUtils.h"

@interface AGCollectPlaneViewController ()
{
    NSArray * data;
    UITableView * tv;
}
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
        data = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    tv = (UITableView*)self.view;
    CGRect frame = self.view.frame;
    UIImageView *view = [[UIImageView alloc] initWithFrame:frame];
    view.userInteractionEnabled = YES;
    self.view = view;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collected:) name:AGNotificationCollected object:nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"planes",@"",@"chains", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetCollected object:nil userInfo:dict];
}

- (void) collected:(NSNotification*) notification
{
    NSDictionary * dict = notification.userInfo;
    //NSString *action = [dict objectForKey:@"action"];
    NSArray *collects = [dict objectForKey:@"collects"];
    data = collects;
    [tv reloadData];
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
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AGCollectPlaneCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //cell.category = indexPath.row;
    cell.aidedButton.tag = indexPath.row;
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    id obj = [data objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[AGPlane class]])
    {
        AGPlane *plane = obj;
        cell.category = plane.category.categoryId.intValue;
        cell.topLabel.text = plane.accountByOwnerId.profile.city;
        cell.bottomLabel.text = [AGUtils dateToString:plane.createdTime];
        AGMessage *message = plane.messages.objectEnumerator.nextObject;
        cell.messageLabel.text = message.content;
    }
    else if ([obj isKindOfClass:[AGChain class]])
    {
        AGChain *chain = obj;
        cell.category = AGCategoryChain;
        cell.topLabel.text = chain.account.profile.city;
        AGChainMessage *chainMessage = [[AGControllerUtils controllerUtils].chainController recentChainMessageForCollect:chain.chainId];
        cell.bottomLabel.text = [AGUtils dateToString:chainMessage.createdTime];
        cell.messageLabel.text = chainMessage.content;
    }
        
    
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
    [self.reply show:[data objectAtIndex:indexPath.row]];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
    [pulldownHeader scrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[pulldownHeader scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	
}

-(void) viewWillUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillUnload];
}
         
- (void)viewDidUnload {
    [self setHeaderView:nil];
    [self setPickupView:nil];
    [super viewDidUnload];
}
@end
