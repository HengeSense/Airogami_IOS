//
//  AGChatProfileViewController.m
//  Airogami
//
//  Created by Tianhu Yang on 7/8/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGChatProfileViewController.h"
#import "AGProfileImageButton.h"
#import "AGUIDefines.h"
#import "AGProfile.h"
#import "AGLocation.h"
#import "AGUtils.h"
#import "AGDefines.h"
#import "AGNotificationCenter.h"

@interface AGChatProfileViewController ()
@property (weak, nonatomic) IBOutlet AGProfileImageButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionContainer;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation AGChatProfileViewController

@synthesize account;

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

    self.descriptionContainer.image = [self.descriptionContainer.image stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    [AGUIDefines setNavigationBackButton:self.backButton];
    //
    [self initData];
    //
    NSDictionary *dict = [NSDictionary dictionaryWithObject:account forKey:@"account"];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGNotificationObtainAccount object:self userInfo:dict];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileChanged:) name:AGNotificationProfileChanged object:nil];
    //
    //[account.profile addObserver:self forKeyPath:<#(NSString *)#> options:<#(NSKeyValueObservingOptions)#> context:<#(void *)#>]
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initData
{
    AGProfile *profile = account.profile;
    if (profile) {
        //self.likesLabel.text = [profile.likesCount stringValue];
        self.nameLabel.text = profile.fullName;
        self.screenNameLabel.text = profile.screenName;
        self.ageLabel.text = [AGUtils birthdayToAge:profile.birthday];
        
        self.sexImageView.image = [AGUIDefines sexSymbolImage:profile.sex.intValue == AGAccountSexTypeMale];
        self.locationLabel.text = [[AGLocation locationWithProfile:profile] toString];
        if(profile.shout.length){
            self.descriptionLabel.text = profile.shout;
        }
        else{
            self.descriptionLabel.text = NSLocalizedString(AGAccountShoutNothing, AGAccountShoutNothing);
        }
        [self.profileImageButton setImageWithAccountId:profile.accountId];
    }
    
}

- (void)profileChanged:(NSNotification*)notification
{
    NSNumber *accountId = [notification.userInfo objectForKey:@"accountId"];
    if ([accountId isEqualToNumber:account.accountId]) {
        [self initData];
    }
}

#pragma mark - Table view data source



/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
}*/

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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        CGRect frame = self.descriptionLabel.frame;
        frame.size = [self.descriptionLabel sizeThatFits:frame.size];
        self.descriptionLabel.frame = frame;
        return frame.origin.y + frame.size.height;
    }
    else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setProfileImageButton:nil];
    [self setNameLabel:nil];
    [self setScreenNameLabel:nil];
    [self setAgeLabel:nil];
    [self setSexImageView:nil];
    [self setLocationLabel:nil];
    [self setDescriptionLabel:nil];
    [self setDescriptionContainer:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}

- (IBAction)backButtonTouched:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)reportButtonTouched:(UIButton *)sender {
}


- (IBAction)profileImageButtonTouched:(AGProfileImageButton *)sender {
}

@end
