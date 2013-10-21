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
#import "UIView+Addition.h"

@interface AGWritePaperViewController ()
{
    int selectedCategoryId;
    UITableView *tv;
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
    tv = (UITableView*)self.view;
    //
    CGRect frame = self.view.frame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.userInteractionEnabled = YES;
    [view addSubview:self.headerView];
    self.view = view;
    //
    frame.origin.y = self.headerView.bounds.size.height;
    frame.size.height -= frame.origin.y;
    frame.origin.x = 0.0f;
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
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*UIEdgeInsets contentInsets = self.tableView.contentInset;
    contentInsets.top = 2.0f;
    self.tableView.contentInset = contentInsets;
    */
    [AGUIDefines setNavigationBackButton:self.profileButton];
    //self.tableView.tableHeaderView = self.headerView;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //
    CGRect frame = tv.superview.frame;
    frame.size.height += 5.0f;
    tv.autoresizingMask = UIViewAutoresizingNone;
    tv.superview.frame = frame;
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
    selectedCategoryId = (indexPath.row + 1) % AGCategoryUnknown;
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
