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
#import "UIView+Addition.h"

@interface AGCollectPlaneViewController ()
{
    NSArray * data;
    UITableView * tv;
}
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property(nonatomic, strong) AGRefreshPulldownHeader *pulldownHeader;
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
        pulldownHeader = [AGRefreshPulldownHeader header];
        reply = [AGCollectPlaneReply reply];
        data = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    tv = (UITableView*)self.view;
    //
    CGRect frame = self.view.frame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.userInteractionEnabled = YES;
    self.view = view;
    [self.view addSubview:self.headerView];
    
    frame.origin.y = self.headerView.bounds.size.height;
    frame.size.height -= frame.origin.y;
    frame.origin.x = 6.0f;
    frame.size.width -= frame.origin.x * 2;
    view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    view.layer.cornerRadius = 5.0f;
    view.clipsToBounds = YES;
    //
    frame.origin.x = frame.origin.y = 0;
    tv.frame = frame;
    [view addSubview:tv];
    [self.view addSubview:view];
    //
    frame = tv.bounds;
    frame.origin.y = -frame.size.height;
    UIView* grayView = [[UIView alloc] initWithFrame:frame];
    grayView.backgroundColor = [UIColor colorWithRed:47 / 255.0f green:89 / 255.0f blue:130 / 255.0f alpha:1.0f];
    [tv addSubview:grayView];
    //
    pulldownHeader.scrollView = tv;
    pulldownHeader.delegate = self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDate) name:AGNotificationUpdateDate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collected:) name:AGNotificationCollected object:nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"planes",@"",@"chains", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetCollected object:nil userInfo:dict];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect frame = pulldownHeader.pulldownView.frame;
    frame.origin.y = -frame.size.height;
    pulldownHeader.pulldownView.frame = frame;
    //
    frame = tv.superview.frame;
    frame.size.height += 5.0f;
    tv.autoresizingMask = UIViewAutoresizingNone;
    tv.superview.frame = frame;
    //
    [tv addSubview:pulldownHeader.pulldownView];
    //[tv setTopRoundedCornerWithRadius:5.0f];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateDate
{
    for (AGCollectPlaneCell *cell in tv.visibleCells) {
        [cell updateDate];
    }
}

- (void) collected:(NSNotification*) notification
{
    NSDictionary * dict = notification.userInfo;
    NSArray *collects = [dict objectForKey:@"collects"];
    data = collects;
    [tv reloadData];
}

- (void) refresh
{
    //[pickupView show];
    
}

- (IBAction)getMoreTouched:(UIButton *)sender {
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
    cell.tableView = tv;
    //cell.category = indexPath.row;
    cell.aidedButton.tag = indexPath.row;
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    id obj = [data objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[AGPlane class]])
    {
        AGPlane *plane = obj;
        cell.collectType = plane.source.intValue;
        cell.category = plane.category.categoryId.intValue;
        cell.topLabel.text = plane.accountByOwnerId.profile.city;
        cell.date = plane.updatedTime;
        //cell.bottomLabel.text = [AGUtils dateToString:plane.updatedTime];
        AGMessage *message = plane.messages.objectEnumerator.nextObject;
        cell.messageLabel.text = message.content;
    }
    else if ([obj isKindOfClass:[AGChain class]])
    {
        AGChain *chain = obj;
        cell.category = AGCategoryChain;
        cell.topLabel.text = chain.account.profile.city;
        AGChainMessage *chainMessage = chain.chainMessage;
        cell.collectType = chainMessage.source.intValue;
        cell.date = chain.updatedTime;
        //cell.bottomLabel.text = [AGUtils dateToString:chain.updatedTime];
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
         
- (void)viewDidUnload {
    [self setHeaderView:nil];
    [self setPickupView:nil];
    [super viewDidUnload];
}
@end
