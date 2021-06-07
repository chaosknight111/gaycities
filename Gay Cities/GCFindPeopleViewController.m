//
//  GCFindPeopleViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 5/5/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCFindPeopleViewController.h"
#import "GayCitiesAppDelegate.h"
#import "GCCommunicator.h"
#import "GCUILabelExtras.h"
#import "GCSearchPeopleViewController.h"
#import "GCFindFriendsFromContactsViewController.h"
#import "GCFindFriendVCCell.h"

@implementation GCFindPeopleViewController

@synthesize gcad, communicator, actionTable, findFriendVCType;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id)init
{
	if (self = [super init]) {
		findFriendVCType = GCFindFriendVCTypeStandard;
	}
	
	return self;
}

- (id)initAfterSignIn
{
	if (self = [super init]) {
		findFriendVCType = GCFindFriendVCTypeNewLogin;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	gcad = [GayCitiesAppDelegate sharedAppDelegate];
	communicator = [GCCommunicator sharedCommunicator];
	
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	self.title = @"Add Friends";
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationController.navigationBar.topItem.titleView = titleView;
	[titleView release];
	
	actionTable.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	gcad.mainTabBar.hidden = YES;
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	
	if (findFriendVCType == GCFindFriendVCTypeNewLogin) {
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAndReturn)];
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
	} else {
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAndReturn)];
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
	}
	
	
	self.navigationItem.rightBarButtonItem = nil;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterLoginFinished:) name:gcTwitterLoginStatusSuccess object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [actionTable reloadData];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:gcTwitterLoginStatusSuccess object:nil];
	communicator.ul.delegate = communicator;
	self.actionTable = nil;
    [super dealloc];
}


- (void)searchWithContacts
{
	communicator.ul.delegate = self;
	[communicator.ul findAllFriendsFromLocalAB];
	
	
}



- (void)searchWithTwitter
{
	if ([gcad.connectController twitterIsAuthorized]) {
		communicator.ul.delegate = self;
		[communicator.ul findAllFriendsFromTwitter];
	} else {
		[[GayCitiesAppDelegate sharedAppDelegate].connectController signInOrLogoutTwitter];
	}
	
}

- (void)twitterLoginFinished:(NSNotification *)note
{
	communicator.ul.delegate = self;
	[communicator.ul findAllFriendsFromTwitter];
}

- (void)searchWithFacebook
{
	if (gcad.connectController.hasSavedFacebook) {
		communicator.ul.delegate = self;
		[communicator.ul findAllFriendsFromFacebook];
	} else {
		[GayCitiesAppDelegate sharedAppDelegate].connectController.findFriendsDelegate = self;
		[[GayCitiesAppDelegate sharedAppDelegate].connectController signInOrLogoutFacebook];
//    [self cancelAndReturn];
	}
	
	
	
	
	
}

- (void)didSignInToFacebook:(BOOL)success
{
	[GayCitiesAppDelegate sharedAppDelegate].connectController.findFriendsDelegate = nil;
	[self.actionTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


- (void)searchByName
{
	GCSearchPeopleViewController *spvc = [[GCSearchPeopleViewController alloc] initWithSearchType:findFriendsName];
	[self.navigationController pushViewController:spvc animated:YES];
	[spvc release];
	
	
	
	
}


- (void)searchByEmail
{
	
	GCSearchPeopleViewController *spvc = [[GCSearchPeopleViewController alloc] initWithSearchType:findFriendsEmail];
	[self.navigationController pushViewController:spvc animated:YES];
	[spvc release];
	
	
	
}

- (IBAction)cancelAndReturn
{
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	[self dismissModalViewControllerAnimated:YES];
	
	
}



#pragma mark UL Find Friends Delegate

- (void)findFriendSearchResults:(NSMutableDictionary *)allPeopleReturned
{
	if (allPeopleReturned) {
		gcad.mainTabBar.hidden = YES;
		gcad.adBackgroundView.hidden = YES;
		gcad.shouldShowAdView = NO;
		
		GCFindFriendsFromContactsViewController *ffvc = [[GCFindFriendsFromContactsViewController alloc] initWithContacts:allPeopleReturned];
		[self.navigationController pushViewController:ffvc animated:YES];
		[ffvc release];
	}
	
	
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {  //allFriends  nonFriends  notUsers

	
	return 5;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}


/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
 if (contacts && [contacts count] > 0) {
 if (section == 0) {
 NSArray *people = [contacts objectForKey:@"nonFriends"];
 if (people) {
 if ([people count] > 0) {
 return @"Tap any contact below to add friends on GayCities";
 }
 }
 } else if (section == 1) {
 NSArray *people = [contacts objectForKey:@"allFriends"];
 if (people) {
 if ([people count] > 0) {
 return @"Contacts that are already friends on GayCities";
 }
 }
 } else if (section == 2) {
 NSArray *people = [contacts objectForKey:@"notUsers"];
 if (people) {
 if ([people count] > 0) {
 return @"Invite any of these friends to join GayCities";
 }
 }
 }
 }
 
 return @"";
 
 
 }
 
 */

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (findFriendVCType == GCFindFriendVCTypeNewLogin) {
		return 60;
    
	}
	return 60;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UILabel *label = [UILabel gcLabelBlueForTableHeaderViewLarger:100];

	if (findFriendVCType == GCFindFriendVCTypeNewLogin) {
		label.text = @"GayCities is more fun when you get\nupdates from your friends";

	} else {
		//label.text = @"You have successfully signed into your account.\n\nUse the options below to find and connect with your friends.";
		label.text = @"GayCities is more fun when you get\nupdates from your friends";

	}
	return label;

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	int row = [indexPath row];
	
	GCFindFriendVCCell *cell = (GCFindFriendVCCell *)[tableView dequeueReusableCellWithIdentifier:@"findFriendVCCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCFindFriendVCCell" owner:self options:nil];
		cell = [[[nib objectAtIndex:0] retain] autorelease];
		[cell.twitterButton addTarget:self action:@selector(searchWithTwitter) forControlEvents:UIControlEventTouchUpInside];
		[cell.fbButton addTarget:self action:@selector(searchWithFacebook) forControlEvents:UIControlEventTouchUpInside];

	}
	
	
	switch (row) {
		case 0:
	 {
		cell.fbButton.hidden = YES;
		cell.twitterButton.hidden = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.imageView.image = [UIImage imageNamed:@"findfriendIconContacts.png"];
		cell.textLabel.text = @"Find friends in my address book";
	 }
			break;
		case 3:
	 {
		if ([gcad.connectController twitterIsAuthorized]) {
			cell.fbButton.hidden = YES;
			cell.twitterButton.hidden = YES;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = @"Search for Twitter friends";
			cell.imageView.image = [UIImage imageNamed:@"findfriendIconTwitter.png"];
		} else {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.fbButton.hidden = NO;
			cell.twitterButton.hidden = NO;
			cell.textLabel.text = @"";
			cell.imageView.image = nil;		
		}
		
	 }
			break;
		case 4:
	 {
		if (gcad.connectController.hasSavedFacebook) {
			cell.fbButton.hidden = YES;
			cell.twitterButton.hidden = YES;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = @"Add Facebook friends";
			cell.imageView.image = [UIImage imageNamed:@"findfriendIconFacebook.png"];
		} else {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.fbButton.hidden = NO;
			cell.twitterButton.hidden = YES;
			cell.textLabel.text = @"";
			cell.imageView.image = nil;
		}
		
	 }
			break;
		case 1:
	 {
		cell.fbButton.hidden = YES;
		cell.twitterButton.hidden = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.text = @"Search by name";
		cell.imageView.image = [UIImage imageNamed:@"findfriendIconName.png"];
	 }
			break;
		case 2:
	 {
		cell.fbButton.hidden = YES;
		cell.twitterButton.hidden = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.text = @"Search by email address";
		cell.imageView.image = [UIImage imageNamed:@"findfriendIconEmail.png"];
	 }
			break;

	}
	
	
	
	return cell;
	
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	
	switch (row) {
		case 0:
	 {
		[self searchWithContacts];
	 }
			break;
		case 3:
	 {
		if ([gcad.connectController twitterIsAuthorized]) {
			[self searchWithTwitter];
		}
	 }
			break;
		case 4:
	 {
		if (gcad.connectController.hasSavedFacebook) {
			[self searchWithFacebook];
		}
	 }
			break;
		case 1:
	 {
		[self searchByName];
	 }
			break;
		case 2:
	 {
		[self searchByEmail];
	 }
			break;
			
	}

	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
