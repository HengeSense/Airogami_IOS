//
//  AGChatPlaneViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 6/28/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatPlaneViewController.h"
#import "AGNotificationCenter.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(obtained:) name:AGNotificationObtained object:nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"planes", @"planes", @"chains", @"chains", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationGetObtained object:nil userInfo:dict];
    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) obtained:(NSNotification*) notification
{
    NSDictionary * dict = notification.userInfo;
    NSString *action = [dict objectForKey:@"action"];
    if ([action isEqual:@"one"])
    {
        NSNumber *planeId = [dict objectForKey:@"planeId"];
        NSNumber *chainId = [dict objectForKey:@"chainId"];
        Class cls;
        NSNumber *number = nil;
        NSString *key;
        if (planeId) {
            number = planeId;
            cls = [AGPlane class];
            key = @"planeId";
        }
        else if(chainId){
            number = chainId;
            cls = [AGChain class];
            key = @"chainId";
        }
        for (int i = 0; i< data.count; ++i) {
            id obj = [data objectAtIndex:i];
            if([obj isKindOfClass:cls]){
                id objId = [obj valueForKey:key];
                if([objId  isEqual:number])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self setData:obj forCell:[self.tableView cellForRowAtIndexPath:indexPath]];
                    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
    }
    else{
        NSArray *chats = [dict objectForKey:@"chats"];
        data = chats;
        [self.tableView reloadData];
    }
    
    
}

- (void) deleteAirogami:(int) row
{
    id airogami =  [data objectAtIndex:row];
    if ([airogami isKindOfClass:[AGPlane class]]) {
        AGPlane *plane = airogami;
        AGPlaneManager *planeManager = [AGManagerUtils managerUtils].planeManager;
        NSDictionary *params = [planeManager paramsForDeletePlane:plane];
        [planeManager deletePlane:params plane:plane context:nil block:^(NSError *error, id context) {
            
        }];
    }
    else if ([airogami isKindOfClass:[AGChain class]]) {
        AGChain *chain = airogami;
        AGChainManager *chainManager = [AGManagerUtils managerUtils].chainManager;
        NSDictionary *params = [chainManager paramsForDeleteChain:chain.chainId];
        [chainManager deleteChain:params chain:chain context:nil block:^(NSError *error, id context) {
            
        }];
    }
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
    id obj = [data objectAtIndex:indexPath.row];
    [self setData:obj forCell:cell];
    
    return cell;
}

-(void) setData:(id)obj forCell:(UITableViewCell*)tableViewCell
{
    AGChatPlaneCell *cell = (AGChatPlaneCell *)tableViewCell;
    AGManagerUtils *managerUtils = [AGManagerUtils managerUtils];
    AGProfile *profile = nil;
    int count = 0;
    if([obj isKindOfClass:[AGPlane class]])
    {
        AGPlane *plane = obj;
        if([managerUtils.accountManager.account.accountId isEqual:plane.accountByOwnerId.accountId])
        {
            profile = plane.accountByTargetId.profile;
        }
        else{
            profile = plane.accountByOwnerId.profile;
        }
        //cell.messageLabel.text = ;
        AGMessage *message = [[AGControllerUtils controllerUtils].planeController recentMessageForPlane:plane.planeId];
        cell.timeLabel.text = [AGUtils dateToString:plane.updatedTime];
        cell.messageLabel.text = message.content;
        //count = [[AGControllerUtils controllerUtils].messageController getUnreadMessageCountForPlane:plane.planeId];
        count = plane.unreadMessagesCount.intValue;
    }
    else if ([obj isKindOfClass:[AGChain class]])
    {
        AGChain *chain = obj;
        profile = chain.account.profile;
        cell.timeLabel.text = [AGUtils dateToString:chain.updatedTime];
        AGChainMessage *chainMessage = [[AGControllerUtils controllerUtils].chainController recentChainMessageForChat:chain.chainId];
        cell.messageLabel.text = chainMessage.content;
        //count = [[AGControllerUtils controllerUtils].chainMessageController getUnreadChainMessageCountForChain:chain.chainId];
        AGChainMessage *cm = [[AGControllerUtils controllerUtils].chainMessageController getChainMessageForChain:chain.chainId];
        count = cm.unreadChainMessagesCount.intValue;
    }
    
    [cell.profileImageView setImageWithAccountId:profile.accountId];
    cell.nameLabel.text = profile.fullName;
    if (count == 0) {
        cell.badge = @"";
    }
    else if (count > 99){
        cell.badge = @"99+";
    }
    else{
        cell.badge = [NSString stringWithFormat:@"%d", count];
    }
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self deleteAirogami:indexPath.row];
    }
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
