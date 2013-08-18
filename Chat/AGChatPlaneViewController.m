//
//  AGChatPlaneViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatPlaneViewController.h"
#import "AGNotificationManager.h"
#import "AGChatPlaneCell.h"
#import "AGPlane.h"
#import "AGAccount.h"
#import "AGProfile.h"
#import "AGUtils.h"
#import "AGMessage.h"
#import "AGChain.h"
#import "AGControllerUtils.h"
#import "AGManagerUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface AGChatPlaneViewController ()
{
    NSArray * data;
    int selectedIndex;
}

@end

@implementation AGChatPlaneViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    //
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    imageView.image = [AGUIDefines mainBackgroundImage];
    [self.tableView.backgroundView addSubview:imageView];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(obtainedPlanes:) name:AGNotificationObtainedPlanes object:nil];
    [[AGManagerUtils managerUtils].notificationManager startTimer];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainPlanes object:nil userInfo:nil];
}

- (void) viewWillUnload
{
    [super viewWillUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) obtainedPlanes:(NSNotification*) notification
{
    NSDictionary * dict = notification.userInfo;
    //NSString *action = [dict objectForKey:@"action"];
    NSArray *planes = [dict objectForKey:@"planes"];
    data = planes;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AGChatPlaneCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    NSObject *obj = [data objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[AGPlane class]])
    {
        AGPlane *plane = (AGPlane*)obj;
        AGProfile *profile;
        if([managerUtils.accountManager.account.accountId isEqual:plane.accountByOwnerId.accountId])
        {
            profile = plane.accountByTargetId.profile;
        }
        else{
            profile = plane.accountByOwnerId.profile;
        }
        cell.nameLabel.text = profile.fullName;
        //cell.messageLabel.text = ;
        cell.timeLabel.text = [AGUtils dateToString:plane.createdTime];
        AGMessage *message = [[AGControllerUtils controllerUtils].planeController recentMessageForPlane:plane.planeId];
        cell.messageLabel.text = message.content;
        [cell.profileImageView setImageWithAccountId:profile.accountId];
    }
    else if ([obj isKindOfClass:[AGChain class]])
    {
        
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

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"ToChat" sender:self];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"ToChat"]) {
        [segue.destinationViewController setValue:[data objectAtIndex:selectedIndex] forKey:@"airogami"];
    }
}

@end
