//
//  GCSearchPeopleViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/8/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCSearchPeopleViewController.h"
#import "GCFindFriendCell.h"
#import "GayCitiesAppDelegate.h"
#import "GCUILabelExtras.h"
#import "GCCommunicator.h"

@implementation GCSearchPeopleViewController

@synthesize searchType;
@synthesize mainTable;
@synthesize mainSearchBar;
@synthesize contacts;
@synthesize communicator;
@synthesize currentPerson;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithSearchType:(FriendSearchType)type
{
	if (self = [super initWithNibName:nil bundle:nil]) {
		self.searchType = type;
	}
	
	return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	self.title = @"Search";
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	communicator = [GCCommunicator sharedCommunicator];
	
	if (searchType < 1 || searchType > 5) {
		searchType = findFriendsName;
	}
	contacts = [[NSMutableDictionary alloc] init];
	communicator.ul.delegate = self;
	self.currentPerson = nil;
	currentAction = friendActionNone;
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(cellProfileImageUpdated:) name:gcCellImageUpdatedForFindFriendNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	switch (searchType) {
		case findFriendsPhone:
			mainSearchBar.placeholder = @"Phone Number";
			break;
		case findFriendsName:
			mainSearchBar.placeholder = @"Full Name";
			break;
		case findFriendsEmail:
			mainSearchBar.placeholder = @"Enter Any Email Address";
			break;
		case findFriendsTwitter:
			mainSearchBar.placeholder = @"Enter Your Twitter Username";
			break;
		case findFriendsFacebook:
			mainSearchBar.hidden = YES;
			break;
		default:
			mainSearchBar.placeholder = @"Search";
			break;
	}
	
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
  [[NSNotificationCenter defaultCenter] removeObserver:self name:gcCellImageUpdatedForFindFriendNotification object:nil];

	communicator.ul.delegate = communicator;
	self.mainTable = nil;
	self.mainSearchBar = nil;
	self.contacts = nil;
    [super dealloc];
}


- (void)cellProfileImageUpdated:(NSNotification *)note
{
	[mainTable reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (contacts && [contacts count] > 0) { 
		return 3;
	}
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {  //allFriends  nonFriends  notUsers
	if (contacts && [contacts count] > 0) {
		if (section == 0) {
			NSArray *people = [contacts objectForKey:@"nonFriends"];
			if (people) {
				return [people count];
			}
		} else if (section == 2) {
			NSArray *people = [contacts objectForKey:@"allFriends"];
			if (people) {
				return [people count];
			}
		} else if (section == 1) {
			NSArray *people = [contacts objectForKey:@"notUsers"];
			if (people) {
				return [people count];
			}
		}
	}
	
	return 0;
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
	
	if (contacts && [contacts count] == 3) {
		if (section == 0) {
			NSArray *people = [contacts objectForKey:@"nonFriends"];
			if (people) {
				return 30;
			}
		} else if (section == 2) {
			NSArray *people = [contacts objectForKey:@"allFriends"];
			if (people) {
				return 30;
			}
		} else if (section == 1) {
			NSArray *people = [contacts objectForKey:@"notUsers"];
			if (people) {
				return 30;
			}
		}
	}
	
	return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	
	
	if (contacts && [contacts count] == 3) {
		NSArray *nonFriends = [contacts objectForKey:@"nonFriends"];
		NSArray *allFriends = [contacts objectForKey:@"allFriends"];
		NSArray *notUsers = [contacts objectForKey:@"notUsers"];

		if (nonFriends && allFriends && notUsers) {
			if ([nonFriends count] == 0 && [allFriends count] == 0 && [notUsers count] == 0) {
				if (section == 0) {
					UILabel *label = [UILabel gcLabelBlueForTableHeaderView:30];
					label.text = @"We were unable to find any matches";
					return label;
				} else {
					return nil;
				}
				
			}
		}
		
		if (section == 0) {
			
			if (nonFriends) {
				if ([nonFriends count] > 0) {
					UILabel *label = [UILabel gcLabelBlueForTableHeaderView:30];
					label.text = @"GayCities members";
					return label;
				}
			}
		} else if (section == 2) {
			if (allFriends) {
				if ([allFriends count] > 0) {
					UILabel *label = [UILabel gcLabelBlueForTableHeaderView:30];
					label.text = @"Current friends on GayCities";
					return label;
				}
			}
		} else if (section == 1) {
			if (notUsers) {
				if ([notUsers count] > 0) {
					UILabel *label = [UILabel gcLabelBlueForTableHeaderView:30];
					label.text = @"Invite these contacts to join GayCities";
					return label;
				}
			}
		}
	}
	
	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	int row = [indexPath row];
	int section = [indexPath section];
	
	GCFindFriendCell *cell = nil;
	
	
	GCFindFriendPerson *person = nil;
	
	if (contacts && [contacts count] == 3) {
		if (section == 0 || section == 2) {
			cell = (GCFindFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"findFriendCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCFindFriendCell" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				
			}
			NSArray *people = nil;
			if (section == 0) {
				people = [contacts objectForKey:@"nonFriends"];
				cell.actionImageView.image = [UIImage imageNamed:@"add-find-fan-button.png"]; 
			} else if (section == 2) {
				people = [contacts objectForKey:@"allFriends"];
				cell.actionImageView.image = [UIImage imageNamed:@"checked-find-fan-button.png"]; 
			}
			
			if (people && [people count] > row) {
				person = (GCFindFriendPerson *)[people objectAtIndex:row];
			}
			
			if (person) {
				cell.usernameLabel.text = person.username;
				cell.fullNameLabel.text = @"";
				
				if ([person.first_name length] > 0 && [person.last_name length] > 0) {
					cell.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", person.first_name, person.last_name];
				} else if ([person.last_name length] > 0) {
					cell.fullNameLabel.text = person.last_name;
				} else if ([person.email length] > 0) {
					cell.fullNameLabel.text = person.email;
				} else if ([person.username length] > 0) {
					cell.fullNameLabel.text = person.username;
					cell.usernameLabel.text = @"";
				}
				
				cell.person = person;
				[cell loadImage];
			} else {
				cell.usernameLabel.text = @"";
				cell.fullNameLabel.text = @"";
				cell.person = nil;
				cell.profileImageView.image = nil;
			}
		} else if (section == 1) {
			cell = (GCFindFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"findFriendNoImageCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCFindFriendNoImageCell" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				
			}
			NSArray *people = [contacts objectForKey:@"notUsers"];
			
			if (people && [people count] > row) {
				person = (GCFindFriendPerson *)[people objectAtIndex:row];
				if (person) {
					if (!person.invite_sent) {
						cell.actionImageView.image = [UIImage imageNamed:@"invite-find-fan-button.png"]; 
						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					} else {
						cell.actionImageView.image = [UIImage imageNamed:@"invited-already-button.png"]; 
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						
					}
					
					if ([person.passed_full_name length] > 0) {
						cell.fullNameLabel.text= person.passed_full_name;
						cell.usernameLabel.text = person.email;
					} else {
						cell.fullNameLabel.text= person.email;
						cell.usernameLabel.text = @"";
					}
				}
				
			}
		}
	} else {
		cell = (GCFindFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"findFriendCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCFindFriendCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
			
		}
		cell.fullNameLabel.text = @"";
		cell.usernameLabel.text = @"";
	}
	
	
	return cell;
	
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	int section = [indexPath section];
	
	GCFindFriendPerson *person = nil;
	
	if (contacts && [contacts count] == 3) {
		if (section == 0) {
			NSMutableArray *people = [contacts objectForKey:@"nonFriends"];
			if (people) {
				person = (GCFindFriendPerson *)[people objectAtIndex:row];
				self.currentPerson = person;
				currentAction = friendAddAction;
				[communicator.ul submitFriendActionWithUsernameOrEmail:person.username andAction:friendAddAction withName:nil];  
			}
		} else if (section == 2) {
			NSMutableArray *people = [contacts objectForKey:@"allFriends"];
			if (people) {
				person = (GCFindFriendPerson *)[people objectAtIndex:row];
				self.currentPerson = person;
				currentAction = friendRemoveAction;
				[communicator.ul submitFriendActionWithUsernameOrEmail:person.username andAction:friendRemoveAction withName:nil];
			}
		} else if (section == 1) {
			NSMutableArray *people = [contacts objectForKey:@"notUsers"];
			if (people) {
				person = (GCFindFriendPerson *)[people objectAtIndex:row];
				if (!person.invite_sent) {
					self.currentPerson = person;
					currentAction = friendInviteNewAction;
					if ([person.passed_full_name length] > 0) {
						[communicator.ul submitFriendActionWithUsernameOrEmail:person.email andAction:friendInviteNewAction withName:person.passed_full_name];
					} else {
						[communicator.ul submitFriendActionWithUsernameOrEmail:person.email andAction:friendInviteNewAction withName:person.email];
					}
				}
			}
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
	} else {
		self.currentPerson = nil;
		currentAction = friendActionNone;
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[mainTable reloadData];
	}
	
}


#pragma mark UL Find Friends Delegate

- (void)findFriendSearchResults:(NSMutableDictionary *)allPeopleReturned
{
	if (allPeopleReturned && [allPeopleReturned count] == 3) {
		self.contacts = allPeopleReturned;
		
	} else {
		[contacts removeAllObjects];

	}
	
	[mainTable reloadData];
}


- (void)friendActionResult:(BOOL)result
{
	if (result && currentPerson && currentAction != friendActionNone && [currentPerson isKindOfClass:[GCFindFriendPerson class]]) {		
		switch (currentAction) {
			case friendAddAction: {
				NSMutableArray *nonFriends = [contacts objectForKey:@"nonFriends"];
				if ([nonFriends containsObject:currentPerson]) {
					[[contacts objectForKey:@"allFriends"] addObject:currentPerson];
					[nonFriends removeObject: currentPerson];
				} else {
					NSLog(@"Friend is not contained in NON friends?");
				}
			}
				break;
			case friendRemoveAction: {
				NSMutableArray *allFriends = [contacts objectForKey:@"allFriends"];
				if ([allFriends containsObject:currentPerson]) {
					[[contacts objectForKey:@"nonFriends"] addObject:currentPerson];
					[allFriends removeObject: currentPerson];
				} else {
					NSLog(@"Friend is not contained in ALL friends?");
				}
			}
				break;
			case friendInviteNewAction: {
				NSMutableArray *notUsers = [contacts objectForKey:@"notUsers"];
				if ([notUsers containsObject:currentPerson]) {
					currentPerson.invite_sent = YES;
				} else {
					NSLog(@"Friend is not contained in NOT USERS?");
				}
			}
				break;
		}
		
	}
	
	self.currentPerson = nil;
	currentAction = friendActionNone;
	[mainTable reloadData];
	
}



#pragma mark Search Delegates

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	if (searchBar.showsCancelButton == NO) {
		[searchBar setShowsCancelButton:YES animated:YES];
	}
	[contacts removeAllObjects];
	[mainTable reloadData];

	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

	//	NSArray *keywords = [searchText componentsSeparatedByString:@" "];
	//NSMutableArray *tempSearchResults = [[NSMutableArray alloc] init];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = @"";
	[searchBar setShowsCancelButton:NO animated:YES];
	
	[searchBar resignFirstResponder];
	[contacts removeAllObjects];
	[mainTable reloadData];
	
	
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	
	[searchBar resignFirstResponder];
	if (searchBar.showsCancelButton == YES) {
		[searchBar setShowsCancelButton:NO animated:YES];
	}
	
	NSString *searchText = searchBar.text;
	if ([searchText length] > 0) {
		
		switch (searchType) {
			case findFriendsName:
			{
				[communicator.ul findFriendsWithSearchData:searchText andParameter:@"full_name"];
			}
				
				break;
			case findFriendsEmail:
			 {
				[communicator.ul findFriendsWithSearchData:searchText andParameter:@"email"];
			 }
				
				break;
			case findFriendsTwitter:
			 {
				[communicator.ul findFriendsWithSearchData:searchText andParameter:@"twitter_name"];
			 }
				
				break;
			case findFriendsFacebook:
		 {
			[communicator.ul findFriendsWithSearchData:searchText andParameter:@"twitter_name"];
		 }
				
				break;
		}
		
		
	} else {
		if ([searchBar respondsToSelector:@selector(setShowsCancelButton:animated:)]) {
			[searchBar setShowsCancelButton:NO animated:YES];
		} else {
			searchBar.showsCancelButton = NO;
		}
		
		[contacts removeAllObjects];

		
		[mainTable reloadData];
	}
	
	
}

@end
