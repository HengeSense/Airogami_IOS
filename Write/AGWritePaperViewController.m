//
//  AGComposePaperViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/15/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGWritePaperViewController.h"
#import "AGUIDefines.h"
#import "AGWriteEditViewController.h"
#import "AGCategory.h"
#import "AGRootViewController.h"

@interface AGWritePaperViewController ()
{
    int selectedCategoryId;
}

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@end

@implementation AGWritePaperViewController

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
        [[NSBundle mainBundle] loadNibNamed:@"AGWritePaperHeaderView" owner:self options:nil];
    }
    return self;
}


- (void)loadView {
    [super loadView];
    UITableView *tv = (UITableView*)self.view;
    CGRect frame = self.view.frame;
    UIView *view = [[UIImageView alloc] initWithFrame:frame];
    view.userInteractionEnabled = YES;
    self.view = view;
    [self.view addSubview:tv];
    [self.view addSubview:self.headerView];
    
    frame.origin.y = self.headerView.bounds.size.height;
    frame.size.height -= frame.origin.y;
    
    tv.frame = frame;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AGUIDefines setNavigationBackButton:self.profileButton];
    //self.tableView.tableHeaderView = self.headerView;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [self setHeaderView:nil];
    [self setProfileButton:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    return cell;
} 
*/

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
    
}

- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedCategoryId = indexPath.row + 1;
    [self performSegueWithIdentifier:@"ToEdit" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToEdit"]) {
        AGWriteEditViewController *awevc = (AGWriteEditViewController*) segue.destinationViewController;
        awevc.categoryId =  [NSNumber numberWithInt:selectedCategoryId];

    }
    
}

- (IBAction)profileButtonTouched:(UIButton *)sender {
    [self.navigationController pushViewController:[AGRootViewController settingViewController] animated:YES];
}


@end
