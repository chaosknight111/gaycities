//
//  GCSettingsViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 3/27/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "GCSettingsViewController.h"
#import "GayCitiesAppDelegate.h"
#import "GCCommunicator.h"
#import "GCConnectController.h"
#import "GCFindPeopleViewController.h"
#import "GCProfileWebViewController.h"

typedef enum {
  ProfilePictureSection = 0,
  EditProfileSection,
  FindFriendsSection,
  SocialNetworksSection,
  SettingsSection,
  GayCitiesAccountSection
} GCSettingsSection;

@implementation GCSettingsViewController

@synthesize settingsTable;
@synthesize communicator=_communicator;
@synthesize connectController=_connectController;
@synthesize appSettingsViewController=_appSettingsViewController;
@synthesize twitterSaved, facebookSaved, foursquareSaved;
@synthesize savedUserName=_savedUserName;
@synthesize savedPassword=_savedPassword;

- (void)dealloc {
  [settingsTable release];
  [_appSettingsViewController release];
  [_savedUserName release];
  [_savedPassword release];
  [super dealloc];
}

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!_appSettingsViewController) {
		_appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		_appSettingsViewController.delegate = self;
	}
	return _appSettingsViewController;
}



#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  showingAction = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];

	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
  
  settingsTable.backgroundColor = [UIColor colorWithRed:.706 green:.792 blue:.867 alpha:1];
  showingAction = NO;
}

- (void)viewDidUnload {
  [super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (!showingAction) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(connectionsFinished:) name:gcFacebookLoginStatusSuccess object:nil];
    [nc addObserver:self selector:@selector(connectionsFinished:) name:gcFacebookLoginStatusNone object:nil];
    [nc addObserver:self selector:@selector(connectionsFinished:) name:gcTwitterLoginStatusSuccess object:nil];
    [nc addObserver:self selector:@selector(connectionsFinished:) name:gcTwitterLoginStatusNone object:nil];
    [nc addObserver:self selector:@selector(connectionsFinished:) name:gcFoursquareLoginStatusNone object:nil];
    [nc addObserver:self selector:@selector(connectionsFinished:) name:gcFoursquareLoginStatusSuccess object:nil];
    [nc addObserver:self selector:@selector(connectionsFinished:) name:gcProfileDetailsUpdated object:nil];
  }
  showingAction = NO;

  GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
  gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	
  
//    signInOutLabel.text = [NSString stringWithFormat:@"Sign Out from %@", self.communicator.ul.gcLoginUsername];
//    addFriendsButton.hidden = NO;
//    addFriendsImage.hidden = NO;
//    fbConnectButton.enabled = YES;
//    foursquareButton.enabled = YES;
//    twitterConnectButton.enabled = YES;
    
//    if ([]) {
//      [twitterConnectButton setImage:[UIImage imageNamed:@"signOutTwitter.png"] forState:UIControlStateNormal];
//    } else {
//      [twitterConnectButton setImage:[UIImage imageNamed:@"Sign-in-with-Twitter.png"] forState:UIControlStateNormal];
//    }
//    
//    if () {
//      [fbConnectButton setImage:[UIImage imageNamed:@"fbLogout.png"] forState:UIControlStateNormal];
//    } else {
//      [fbConnectButton setImage:[UIImage imageNamed:@"fbSmall.png"] forState:UIControlStateNormal];
//    }
//    
//    if () {
//      [foursquareButton setImage:[UIImage imageNamed:@"signoutof-foursquare.png"] forState:UIControlStateNormal];
//    } else {
//      [foursquareButton setImage:[UIImage imageNamed:@"signinwith-foursquare.png"] forState:UIControlStateNormal];
//    }
    
//    signInOutLabel.text = @"SIGN IN OR CREATE AN ACCOUNT";
//    addFriendsButton.hidden = YES;
//    addFriendsImage.hidden = YES;
//    fbConnectButton.enabled = NO;
//    foursquareButton.enabled = NO;
//    [twitterConnectButton setImage:[UIImage imageNamed:@"Sign-in-with-Twitter.png"] forState:UIControlStateNormal];
//    
//    twitterConnectButton.enabled = NO;
}

- (void)revertState {
  self.communicator.ul.delegate = self.communicator;
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self name:gcFacebookLoginStatusSuccess object:nil];
  [nc removeObserver:self name:gcFacebookLoginStatusNone object:nil];
  [nc removeObserver:self name:gcTwitterLoginStatusSuccess object:nil];
  [nc removeObserver:self name:gcTwitterLoginStatusNone object:nil];
  [nc removeObserver:self name:gcFoursquareLoginStatusNone object:nil];
  [nc removeObserver:self name:gcFoursquareLoginStatusSuccess object:nil];
  [nc removeObserver:self name:gcProfileDetailsUpdated object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
  // TODO: Find a good place/time to send social data
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  if (!showingAction) [self revertState];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (GCCommunicator *)communicator {
  if (!_communicator) {
    self.communicator = [GCCommunicator sharedCommunicator];
  }
  return _communicator;
}

- (GCConnectController *)connectController {
  if (!_connectController) {
    self.connectController = [[GayCitiesAppDelegate sharedAppDelegate] connectController];
  }
  return _connectController;
}

- (BOOL)isAuthenticatedToGC {
  return [self.communicator.ul isSignedIn];
}

- (BOOL)twitterSaved {
  return [self.connectController twitterIsAuthorized];
}

- (BOOL)facebookSaved {
  return self.connectController.hasSavedFacebook;
}

- (BOOL)foursquareSaved {
  return self.connectController.hasSavedFoursquare;
}

#pragma mark UserLogin Delegates

- (void)loginResult:(BOOL)result {
//  NSLog(@"Login delegate called in settings, reloading table if success: %i", result);
  if (result) {
    [self.settingsTable reloadData];
  }
}

#pragma mark Sign In

- (void)connectionsFinished:(NSNotification *)note{
//  NSLog(@"Connections finished, reloading table");
  [self.settingsTable reloadData];
//	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
//	[gcad.mainTabBar setHidden:NO];
//	[gcad.adBackgroundView setHidden:NO];
//	gcad.shouldShowAdView = YES;
}


- (void)connectWithGayCities {
	if ([self.communicator.ul isSignedIn]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sign out?" message:@"Are you sure you want to sign out from your account?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
		[alertView show];
		[alertView release];
	} else {
		self.communicator.ul.delegate = self;
		[self.communicator.ul askLogin];
	}
	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
	} else if (buttonIndex == 1) {
		[self.communicator.ul logoutOfAccount];
		[[GayCitiesAppDelegate sharedAppDelegate].connectController logoutOfAccounts];
		[self.communicator.friendUpdates removeAllObjects];
		[self.communicator getPeopleUpdates];
	}
}

- (void)connectWithTwitter {
	[[GayCitiesAppDelegate sharedAppDelegate].connectController signInOrLogoutTwitter];
}

- (void)connectWithFacebook {
	[[GayCitiesAppDelegate sharedAppDelegate].connectController signInOrLogoutFacebook];
}

- (void)connectWithFoursquare {
  [[GayCitiesAppDelegate sharedAppDelegate].connectController signInOrLogoutFoursquare:self];
}

- (void)connectWithFriends {
	if ([self.communicator isThereNoInternet]) {
		[self.communicator showNoInternetAlertGeneric];
	} else if (![self.communicator.ul isSignedIn]){
		[self.communicator.ul askLogin];
	} else {
		GCFindPeopleViewController *fpvc = [[GCFindPeopleViewController alloc] init];
		UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:fpvc];
		[self.navigationController presentModalViewController:controller animated:YES];
		[fpvc release];
		[controller release];
	}
}

- (void)showSettings {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  self.savedUserName = [defaults stringForKey:@"gcUserIDKey"];
  self.savedPassword = [defaults stringForKey:@"gcPasswordKey"];
  
  self.appSettingsViewController.showDoneButton = NO;
	[self.navigationController pushViewController:self.appSettingsViewController animated:YES];
}

- (void)uploadProfilePicture {
	if (self.isAuthenticatedToGC) {
		[self.communicator.ul submitProfilePhoto];
	} else {
		self.communicator.ul.delegate = self;
		[self.communicator.ul askLogin];
	}
}

#pragma mark - Settings View COntroller Delegate

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
  // check login again to make sure it's valid.
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *newUserName = [defaults stringForKey:@"gcUserIDKey"];
  NSString *newPassword = [defaults stringForKey:@"gcPasswordKey"];
  
  if (![newPassword isEqualToString:self.savedPassword] || ![newUserName isEqualToString:self.savedUserName]) {
    [self.communicator.ul checkChangedLogin];
  }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.isAuthenticatedToGC ? 6 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.isAuthenticatedToGC && section == SocialNetworksSection) return 3;
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  int section = indexPath.section;
  int row = indexPath.row;
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
  }

  if (self.isAuthenticatedToGC) {
    switch (section) {
      case ProfilePictureSection:;
        cell.textLabel.text = @"Upload a profile picture";
//        if ([self.communicator.ul.profileImageSaved isKindOfClass:[UIImage class]]) {
//          cell.imageView.image = self.communicator.ul.profileImageSaved;
//        } else {
        cell.imageView.image = nil; //[UIImage imageNamed:@"default_profile"];
//        }
        break;
      case EditProfileSection:;
        cell.textLabel.text = @"Edit your personal profile";
        cell.imageView.image = nil;
        break;       
      case FindFriendsSection:;
        cell.textLabel.text = @"Add Friends";
        cell.imageView.image = nil;
        break;  
      case SocialNetworksSection:;
        if (row == 0) {
          cell.textLabel.text = self.facebookSaved ? @"Sign out facebook" : @"connect facebook";
          cell.imageView.image = [UIImage imageNamed:@"FacebookSettings"];
        } else if (row == 1) {
          cell.textLabel.text = self.twitterSaved ? @"Sign out twitter" : @"connect twitter";
          cell.imageView.image = [UIImage imageNamed:@"TwitterSettings"];
        } else {
          cell.textLabel.text = self.foursquareSaved ? @"Sign out foursquare" : @"connect foursquare";
          cell.imageView.image = [UIImage imageNamed:@"FoursquareSettings"];
        }
        break;  
      case SettingsSection:;
        cell.textLabel.text = @"Settings";
        cell.imageView.image = nil;
        break;  
      case GayCitiesAccountSection:;
        cell.textLabel.text = @"Sign out of GayCities";
        cell.imageView.image = nil;
        break;  
      default:;
        break;
    }
  } else {
    switch (section) {
      case 0:;
        cell.textLabel.text = @"Sign In to GayCities";
        cell.imageView.image = nil;
        break;
      case 1:;
        cell.textLabel.text = @"Settings";
        cell.imageView.image = nil;
        break;       
      default:;
        break;
    }
  }
  
  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // Delete the row from the data source
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }   
  else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the item to be re-orderable.
  return YES;
}
*/

#pragma mark -
#pragma mark Web View

- (void)openProfilePageForUser:(NSString *)username {
	NSURL *url = [NSURL URLWithString:@"http://iphone.gaycities.com/i_profile_edit.php"];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	GCProfileWebViewController	*webViewController = [[GCProfileWebViewController alloc] init];
	if (self.communicator.ul.currentLoginStatus) {
		NSString *string = [NSString stringWithFormat:@"%@|%@", self.communicator.ul.gcLoginUsername, self.communicator.ul.authToken];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  showingAction = YES;
  int row = indexPath.row;
  int section = indexPath.section;
  if (self.isAuthenticatedToGC) {
    switch (section) {
      case ProfilePictureSection:;
        [self uploadProfilePicture];
        break;
      case EditProfileSection:;
        [self openProfilePageForUser:self.communicator.ul.gcLoginUsername];
        break;       
      case FindFriendsSection:;
        [self connectWithFriends];
        break;  
      case SocialNetworksSection:;
        if (row == 0) {
          [self connectWithFacebook];
        } else if (row == 1) {
          [self connectWithTwitter];
        } else {
          [self connectWithFoursquare];
        }
        break;  
      case SettingsSection:;
        [self showSettings];
        break;  
      case GayCitiesAccountSection:;
        [self connectWithGayCities];
        break;  
      default:;
        break;
    }
  } else {
    switch (section) {
      case 0:;
        [self connectWithGayCities];
        break;
      case 1:;
        [self showSettings];
        break;       
      default:;
        break;
    }
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
