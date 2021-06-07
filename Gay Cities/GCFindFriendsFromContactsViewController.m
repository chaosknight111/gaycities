//
//  GCLocateFriendsFromContactsViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 5/1/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCFindFriendsFromContactsViewController.h"
#import "GCFindFriendCell.h"
#import "GayCitiesAppDelegate.h"
#import "GCUILabelExtras.h"
#import "GCCommunicator.h"
#import "GCFindFriendPerson.h"

@implementation GCFindFriendsFromContactsViewController


@synthesize contacts, mainTable;
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

- (id)initWithContacts:(NSMutableDictionary *)newContacts
{
	if (self = [super init]) {
		if (newContacts) {
			contacts = [[NSMutableDictionary alloc] initWithDictionary:newContacts];
			
		}
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.communicator = [GCCommunicator sharedCommunicator];
	communicator.ul.delegate = self;
	
	if (!contacts) {
		contacts = [[NSMutableDictionary alloc] init];
	}
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	self.title = @"Friends";
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	mainTable.backgroundColor = [UIColor clearColor];
	self.currentPerson = nil;
	currentAction = friendActionNone;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(cellProfileImageUpdated) name:gcCellImageUpdatedForFindFriendNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAndReturn)];
	//	self.navigationItem.leftBarButtonItem = cancelButton;
	//	[cancelButton release];
	
	//	self.navigationItem.rightBarButtonItem = nil;
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
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self name:gcCellImageUpdatedForFindFriendNotification object:nil];
	communicator.ul.delegate = communicator;
	self.mainTable = nil;
	self.contacts = nil;
    [super dealloc];
}



- (void)cellProfileImageUpdated
{
	[mainTable reloadData];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (contacts && [contacts count] == 3) { 
		return 3;
	}
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {  //allFriends  nonFriends  notUsers
	if (contacts && [contacts count] == 3) {
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
		NSArray *nonFriends = [contacts objectForKey:@"nonFriends"];
		NSArray *allFriends = [contacts objectForKey:@"allFriends"];
		NSArray *notUsers = [contacts objectForKey:@"notUsers"];
		
		if ([nonFriends count] == 0 && [allFriends count] == 0 && [notUsers count] == 0 && section == 0) {
			return 30;
		}
		
		if (section == 0 && [nonFriends count] > 0) {
			return 30;
			
		} else if (section == 2 && [allFriends count] > 0) {
			return 30;
			
		} else if (section == 1 && [notUsers count] > 0) {
			return 30;
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
		
		if ([nonFriends count] == 0 && [allFriends count] == 0 && [notUsers count] == 0 && section == 0) {
			UILabel *label = [UILabel gcLabelBlueForTableHeaderView:30];
			label.text = @"We were unable to find any matches";
			return label;

		} else if (section == 0 && [nonFriends count] > 0) {
			UILabel *label = [UILabel gcLabelBlueForTableHeaderView:30];
			label.text = @"GayCities members";
			return label;
			
		} else if (section == 2 && [allFriends count] > 0) {
			UILabel *label = [UILabel gcLabelBlueForTableHeaderView:30];
			label.text = @"Already Friends on GayCities";
			return label;
			
		} else if (section == 1 && [notUsers count] > 0) {
			UILabel *label = [UILabel gcLabelBlueForTableHeaderView:30];
			label.text = @"Invite these contacts to join GayCities";
			return label;
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
						cell.fullNameLabel.textColor = [UIColor blackColor];

						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					} else {
						cell.actionImageView.image = [UIImage imageNamed:@"invited-already-button.png"]; 
						cell.fullNameLabel.textColor = [UIColor darkGrayColor];

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
		cell = (GCFindFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"findFriendNoImageCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCFindFriendNoImageCell" owner:self options:nil];
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

					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Invite?" message:[NSString stringWithFormat:@"Would you like to send an invite to %@?", person.email] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
					[alert show];
					[alert release];
					
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		self.currentPerson = nil;
		currentAction = friendActionNone;

		return;
	} else if (buttonIndex == 1 && currentPerson) {
		if ([currentPerson.passed_full_name length] > 0) {
			[communicator.ul submitFriendActionWithUsernameOrEmail:currentPerson.email andAction:friendInviteNewAction withName:currentPerson.passed_full_name];
		} else {
			[communicator.ul submitFriendActionWithUsernameOrEmail:currentPerson.email andAction:friendInviteNewAction withName:currentPerson.email];
		}
	}
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
					NSLog(@"Invite Send Error? Person is not contained in NOT USERS?");
				}
			}
				break;
		}
	}
	
	self.currentPerson = nil;
	currentAction = friendActionNone;
	[mainTable reloadData];

}


@end












