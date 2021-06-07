//
//  GCPeopleViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/9/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCPeopleViewController.h"
#import "GayCitiesAppDelegate.h"
#import "OCConstants.h"
#import "GCUpdatesPeopleCell.h"
#import "GCPerson.h"
#import "GCProfileWebViewController.h"
#import "GCSingleButtonCell.h"
#import "GCFindPeopleViewController.h"
#import "GCSettingsViewController.h"

@implementation GCPeopleViewController

@synthesize communicator;
@synthesize mainTable, recentButton, friendsButton;
@synthesize whosWhereButton;
@synthesize headerView;
@synthesize profileImageView, profileTextLabel;
@synthesize refreshArrowImageView, refreshLabel, refreshActivity;

- (id)init {
  self = [super init];
	if (self) {
		self.communicator = [GCCommunicator sharedCommunicator];
		communicator.peopleDelegate = self;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	arrowIsPointingDown = YES;
	arrowIsRotating = NO;
	isUpdatingPeople = NO;
	processingShown = NO;
  
	[self setTitle:@"People"];
  
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
  
	tabSelected = nearbyTabSelected;
	mainTable.backgroundColor = [UIColor clearColor];
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.leftBarButtonItem = nil;
		
	if ([communicator.peopleUpdateConnections count] > 0) {
		[self showProcessing];
	}else if ([communicator.nearbyUpdates count] == 0) {
		[self showProcessing];
		[communicator getPeopleUpdates];
	} else {
		[communicator getPeopleUpdates];
	}
	[mainTable setTableHeaderView:headerView];
	//mainTable.tableHeaderView.frame = CGRectMake(0, -62, 320, 99);
	profileLoaded = NO;
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(updateProfileDisplay:) name:gcProfileDetailsUpdated object:nil];
	[nc addObserver:self selector:@selector(cellProfileImageUpdated:) name:gcCellImageUpdatedForPersonNotification object:nil];
	
	UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStyleBordered target:self action:@selector(showMoreOptions)];
	self.navigationItem.rightBarButtonItem = moreButton;
	[moreButton release];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	if (communicator.currentLocation) {
		[recentButton setImage:[UIImage imageNamed:@"nearbyActivity.png"] forState:UIControlStateNormal];
		[recentButton setImage:[UIImage imageNamed:@"nearbyActivityWhite.png"] forState:UIControlStateSelected];
	} else {
		[recentButton setImage:[UIImage imageNamed:@"recentActivity.png"] forState:UIControlStateNormal];
		[recentButton setImage:[UIImage imageNamed:@"recentActivityWhite.png"] forState:UIControlStateSelected];
	}
	
	if (!profileLoaded) {
		[self updateProfileDisplay:nil];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	[mainTable reloadData];
}

- (void)showMoreOptions
{
  GCSettingsViewController *settingsViewController = [[GCSettingsViewController alloc] initWithNibName:@"GCSettingsViewController" bundle:nil];
  [self.navigationController pushViewController:settingsViewController animated:YES];
  [settingsViewController release];
}

- (void)updateProfileDisplay:(NSNotification *)note
{
	if ([communicator.ul isSignedIn]) {
		if (communicator.ul.profileImageSaved) {
			if ([communicator.ul.profileImageSaved isKindOfClass:[UIImage class]]) {
				profileImageView.image = communicator.ul.profileImageSaved;
			}
		} else {
			profileImageView.image = [UIImage imageNamed:@"add-profile-photo.png"];
		}
		
		NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"Hi %@!",communicator.ul.gcLoginUsername];
		if (communicator.ul.userProfileInformation) {
			NSString *age = [communicator.ul.userProfileInformation objectForKey:@"age"];
			if ([age length] == 0) {
				age = nil;
			}
			NSString *gender = [communicator.ul.userProfileInformation objectForKey:@"gender"];
			if ([gender length] == 0) {
				gender = nil;
			}
			NSString *city = [communicator.ul.userProfileInformation objectForKey:@"city"];
			if ([city length] == 0) {
				city = nil;
			}
			NSString *state = [communicator.ul.userProfileInformation objectForKey:@"state"];
			if ([state length] == 0) {
				state = nil;
			}
			if (age && gender && city && state) {
				[string appendFormat:@"\n%@/%@, %@, %@", age, gender, city, state];
			} else if (age && gender && city) {
				[string appendFormat:@"\n%@/%@, %@", age, gender, city];
			} else if (age && gender && state) {
				[string appendFormat:@"\n%@/%@, %@", age, gender, state];
			} else if (age && gender) {
				[string appendFormat:@"\n%@/%@", age, gender];
			} else if (city && state) {
				[string appendFormat:@"\n%@, %@", city, state];
			} else if (city) {
				[string appendFormat:@"\n%@", city];
			} else if (state) {
				[string appendFormat:@"\n%@", state];
			}
		}
		
		profileTextLabel.text = string;
		[string release];
		profileLoaded = YES;
		
		
	} else {
		profileTextLabel.text = @"Sign in to find your friends and check in to nearby places.";
		profileImageView.image = [UIImage imageNamed:@"default_profile40.png"];
		profileLoaded = YES;
		[self changeTable:recentButton];
	}
	
}

- (void)cellProfileImageUpdated:(NSNotification *)note
{
	[mainTable reloadData];
}



- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
}


- (void)dealloc {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self  name:gcProfileDetailsUpdated object:nil];
  [nc removeObserver:self name:gcCellImageUpdatedForPersonNotification object:nil];
	communicator.peopleDelegate = nil;
	communicator.ul.delegate = communicator;
	self.mainTable = nil;
	self.recentButton = nil;
	self.friendsButton = nil;
	self.headerView = nil;
	self.whosWhereButton = nil;
	self.profileImageView = nil;
	self.profileTextLabel = nil;
	self.refreshArrowImageView = nil;
	self.refreshLabel = nil;
	self.refreshActivity = nil;
  [super dealloc];
}

#pragma mark Actions

- (void)updatePeopleNow {
//	NSLog(@"Update people Now, doing nothing");
}

- (void)showProcessing {
	processingShown = YES;
	isUpdatingPeople = YES;

	UIEdgeInsets insets = {34,0,-34,0};
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.4];
	[UIView setAnimationDidStopSelector:@selector(hideRefreshElements)];
	[UIView setAnimationDelegate:self];
	mainTable.contentInset = insets;
	[UIView commitAnimations];	
}

- (void)hideProcessing {
	UIEdgeInsets insets = {0,0,0,0};
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.4];
	[UIView setAnimationDidStopSelector:@selector(unHideRefreshElements)];
	[UIView setAnimationDelegate:self];
	mainTable.contentInset = insets;
	[UIView commitAnimations];	
	isUpdatingPeople = NO;
	processingShown = NO;
}

- (void)hideRefreshElements {
	refreshLabel.text = @"\n\nUpdating...";
	[refreshActivity startAnimating];
}

- (void)unHideRefreshElements {
	refreshLabel.text = @"Pull down to refresh";
	[refreshActivity stopAnimating];
	if (!arrowIsPointingDown) {
		arrowIsPointingDown = YES;
	}
}

#pragma mark UserLogin Delegates

- (void)loginResult:(BOOL)result {
  if (result) {
    [communicator getPeopleUpdates];
    [self showProcessing];
  }
}


#pragma mark Communicator Delegates

- (void)didRecievePeopleUpdates {
	[self hideProcessing];
//	NSLog(@"PVC didRecievePeopleUpdates");
	[mainTable reloadData];
	if (communicator.currentLocation) {
		[recentButton setImage:[UIImage imageNamed:@"nearbyActivity.png"] forState:UIControlStateNormal];
		[recentButton setImage:[UIImage imageNamed:@"nearbyActivityWhite.png"] forState:UIControlStateSelected];
	} else {
		[recentButton setImage:[UIImage imageNamed:@"recentActivity.png"] forState:UIControlStateNormal];
		[recentButton setImage:[UIImage imageNamed:@"recentActivityWhite.png"] forState:UIControlStateSelected];
	}
}

- (void)errorRecievingPeopleUpdates {
	NSLog(@"PVC errorRecievingPeopleUpdates");
	[self hideProcessing];

	[mainTable reloadData];
	if (communicator.currentLocation) {
		[recentButton setImage:[UIImage imageNamed:@"nearbyActivity.png"] forState:UIControlStateNormal];
		[recentButton setImage:[UIImage imageNamed:@"nearbyActivityWhite.png"] forState:UIControlStateSelected];
	} else {
		[recentButton setImage:[UIImage imageNamed:@"recentActivity.png"] forState:UIControlStateNormal];
		[recentButton setImage:[UIImage imageNamed:@"recentActivityWhite.png"] forState:UIControlStateSelected];
	}
}

#pragma mark TableView Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!isUpdatingPeople) {
		if ([communicator.peopleUpdateConnections count] == 0) {
			float offsetY = scrollView.contentOffset.y;
			if (offsetY <= -55) {
				[self showProcessing];
				NSLog(@"Scroll Dragged - Force people Updates");
				[communicator getPeopleUpdates];
			}
		}
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!arrowIsRotating && scrollView.tracking && !isUpdatingPeople && !processingShown) {
		float offsetY = scrollView.contentOffset.y;
		if (offsetY <= -55) {
			if (arrowIsPointingDown) {
				arrowIsRotating = YES;
				
				NSInvocationOperation *iop = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(changeTextForArrowUp) object:nil] autorelease];
				[iop start];
			}
		} else {
			if (!arrowIsPointingDown) {
				arrowIsRotating = YES;
				
				NSInvocationOperation *iop = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(changeTextForArrowDown) object:nil] autorelease];
				[iop start];
			}
		}
	}
}

- (void)changeTextForArrowUp {
	refreshLabel.text = @"Release to refresh";
	arrowIsPointingDown = NO;
	arrowIsRotating = NO;
}

- (void)changeTextForArrowDown {
	refreshLabel.text = @"Pull Down to refresh";
	arrowIsPointingDown = YES;
	arrowIsRotating = NO;
}

- (IBAction)changeTable:(id)sender {
	if (sender == recentButton) {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"PEOPLE_UPDATES-Nearby tab selected" withParameters:nil];

		tabSelected = nearbyTabSelected;
		recentButton.selected = YES;
		friendsButton.selected = NO;
		whosWhereButton.selected = NO;
	} else { //if (sender == friendsButton) {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"PEOPLE_UPDATES-Friends tab selected" withParameters:nil];
		if (!communicator.ul.currentLoginStatus) {
			communicator.ul.delegate = self;
			[communicator.ul askLoginFriendUpdates];
			return;
		} else {
			tabSelected = friendsTabSelected;
			recentButton.selected = NO;
			friendsButton.selected = YES;
			whosWhereButton.selected = NO;
		}
	} 
	[mainTable reloadData];
}

- (void)showCheckInTab {
	UITabBar *tabBar = [[GayCitiesAppDelegate sharedAppDelegate] mainTabBar];
	UITabBarItem *anItem = nil;
	for (UITabBarItem *item in [tabBar items]) {
		if (item.tag == 50) {
			anItem = item;
			break;
		}
	}
	if (anItem) {
		[tabBar setSelectedItem:anItem];
		[tabBar.delegate tabBar:tabBar didSelectItem:anItem];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tabSelected == nearbyTabSelected) {
		return 1;
	}
	else if (tabSelected == friendsTabSelected) {
		return 1;
	} else if (tabSelected == whosWhereTabSelected) {
		return 1;
	}
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
	if (tabSelected == nearbyTabSelected) {
		return [communicator.nearbyUpdates  count] + 1;
	}
	else if (tabSelected == friendsTabSelected) {
		return [communicator.friendUpdates count] + 2;
	} else if (tabSelected == whosWhereTabSelected) {
		return 1;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section  {
	if (tabSelected == nearbyTabSelected) {
		return @"";
	}
	else if (tabSelected == friendsTabSelected) {
		return @"";
	} else if (tabSelected == whosWhereTabSelected) {
		return @"";
	}
	return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
	int row = [indexPath row];

	GCUpdatesPeopleCell *cell;

	GCPerson *person = nil;
	if (tabSelected == nearbyTabSelected) {
		if (row == 0) {
			GCSingleButtonCell *cell  = (GCSingleButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"singleButtonCell-CheckIn"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSingleButtonCell-CheckIn" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				[cell.button setImage:[UIImage imageNamed:@"checkInNearbyLongOrange.png"] forState:UIControlStateNormal];
				cell.backgroundColor = [UIColor clearColor];
				[cell.button addTarget:self action:@selector(showCheckInTab) forControlEvents:UIControlEventTouchUpInside];
			}
			return cell;
		} else {
			row = row - 1;
		}
		
		if ([communicator.nearbyUpdates count] > 0) {
			person = [communicator.nearbyUpdates objectAtIndex:row];
		}
		cell = (GCUpdatesPeopleCell *)[tableView dequeueReusableCellWithIdentifier:@"updatesPeopleCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCUpdatesPeopleCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
		}
	} else if (tabSelected == friendsTabSelected) {
		if (row == 0) {
			GCSingleButtonCell *cell  = (GCSingleButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"singleButtonCell-CheckIn"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSingleButtonCell-CheckIn" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				[cell.button setImage:[UIImage imageNamed:@"checkInNearbyLongOrange.png"] forState:UIControlStateNormal];
				cell.backgroundColor = [UIColor clearColor];
				[cell.button addTarget:self action:@selector(showCheckInTab) forControlEvents:UIControlEventTouchUpInside];
			}
			return cell;
		} else if (row == 1) {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addFriendsCell"];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addFriendsCell"] autorelease];
				cell.textLabel.font = [UIFont systemFontOfSize:13];
				cell.textLabel.textColor = [UIColor colorWithRed:0 green:.306 blue:.443 alpha:1];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				//cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
				//cell.imageView.image = [UIImage imageNamed:@"findfriendIconPlus.png"];
				UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"findfriendIconPlus.png"]];
				imageView.frame = CGRectMake(10, 5, 20, 20);
				imageView.contentMode = UIViewContentModeScaleAspectFit;
				[cell addSubview:imageView];
				[imageView release];
				cell.textLabel.text = @"        ADD  FRIENDS";
				UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, 320, 1)];
				aView.backgroundColor = [UIColor colorWithRed:.463 green:.463 blue:.463 alpha:1];
				[cell addSubview:aView];
				[aView release];
			}
			return cell;
		}
		row = row - 2;

		if ([communicator.friendUpdates count] > 0) {
			person = [communicator.friendUpdates objectAtIndex:row];
		}
		cell = (GCUpdatesPeopleCell *)[tableView dequeueReusableCellWithIdentifier:@"updatesPeopleCellFriends"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCUpdatesPeopleCellFriends" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
		}
	}
  
	if (!person) {
		cell = (GCUpdatesPeopleCell *)[tableView dequeueReusableCellWithIdentifier:@"updatesPeopleCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCUpdatesPeopleCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
		}
		cell.displayLabel.text = @"";
		cell.profileImage.image = nil;
		cell.shoutLabel.text = @"";
		cell.createdTime.text = @"";
		cell.person = nil;
		return cell;
	}
	person.delegate = nil;
	CGSize constraints = CGSizeMake(199, 199);
	CGSize labelSize = [person.display sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:constraints lineBreakMode:UILineBreakModeWordWrap];
  NSString *shoutText = [person.shout length] > 0 ? person.shout : @"";
	if (labelSize.height < 22) {
		cell.shoutLabel.text = shoutText;
	} else {
		cell.shoutLabel.text = [NSString stringWithFormat:@"\n%@", shoutText];
	}
	
	cell.person = person;
	[cell loadImage];
	cell.displayLabel.text = person.display;
	cell.createdTime.text = [NSString stringForCreatedTimeWithDate:person.createdTime];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	
	if (tabSelected == nearbyTabSelected) {
		if (row == 0) {
			return 60;
		}
		return 70;
	} 
	else if (tabSelected == friendsTabSelected) {
		if (row == 0) {
			return 49;
		} else if (row == 1) {
			return 30;
		}
		return 70;
	}
	else if (tabSelected == whosWhereTabSelected) {
		
		return 44;
		
	}
	return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];

	if (tabSelected == nearbyTabSelected) {
		if (row == 0) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			
			return;
		}
		row = row - 1;
		[self openProfilePageForUser:[[(GCPerson *)[communicator.nearbyUpdates objectAtIndex:row] user] objectForKey:@"username"]];

		
	} else if (tabSelected == friendsTabSelected) {
		if (row == 1) {
			[self showMoreOptions];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		} else if (row == 0) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
		
		row = row - 2;
		[self openProfilePageForUser:[[(GCPerson *)[communicator.friendUpdates objectAtIndex:row] user] objectForKey:@"username"]];
	} else if (tabSelected == whosWhereTabSelected) {
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark User Profile

- (IBAction)profileDetailsPressed {
	if (communicator.ul.gcLoginUsername && communicator.ul.authToken) {
		[self openProfilePageForUser:communicator.ul.gcLoginUsername];
	} else {
		communicator.ul.delegate = self;
		[communicator.ul askLogin];
	}
}

- (IBAction)uploadProfilePicture {
	if (communicator.ul.gcLoginUsername && communicator.ul.authToken) {
		[communicator.ul submitProfilePhoto];
	} else {
		communicator.ul.delegate = self;
		[communicator.ul askLogin];
	}
}

- (void)openProfilePageForUser:(NSString *)username {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gaycities.com/reviewer/%@?iphone=1",username]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	GCProfileWebViewController	*webViewController = [[GCProfileWebViewController alloc] init];
	if (communicator.ul.currentLoginStatus) {
		NSString *string = [NSString stringWithFormat:@"%@|%@", communicator.ul.gcLoginUsername, communicator.ul.authToken];
		NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
									@"gaycities.com", NSHTTPCookieDomain,
									@"\\", NSHTTPCookiePath,  // IMPORTANT!
									@"appsignedin", NSHTTPCookieName,
									string, NSHTTPCookieValue,
									nil];
		
		NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
		NSArray *cookies = [NSArray arrayWithObjects:cookie, nil];
		
		NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
		
		[request setAllHTTPHeaderFields:headers];
	}
	webViewController.profileRequest = request;
	[[self navigationController] pushViewController:webViewController animated:YES];
	[webViewController release];
	[request release];
}

@end



