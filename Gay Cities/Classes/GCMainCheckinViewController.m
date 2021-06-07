
//
//  GCMainCheckinViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 2/7/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCMainCheckinViewController.h"
#import "GCUILabelExtras.h"
#import "GCListingsCell.h"
#import "GCListing.h"
#import "GayCitiesAppDelegate.h"
#import "GCListingViewController.h"
#import "GCListingCheckinViewController.h"
#import "GCProfileWebViewController.h"
#import "GCSingleButtonCell.h"

@implementation GCMainCheckinViewController

@synthesize communicator, mainTable;
@synthesize checkinListings;
@synthesize processingView, activityView;
@synthesize showingProfilePage;
@synthesize refreshLabel, refreshActivity;
@synthesize showAllNearbyVisible;

- (id)init
{
	if ((self = [super init])) {
		self.communicator = [GCCommunicator sharedCommunicator];
		//communicator.peopleDelegate = self;
		//communicator.ul.delegate = self;
    self.showAllNearbyVisible = NO;
	}
	return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  communicator.checkinAndPopularDelegate = self;
	
  arrowIsPointingDown = YES;
	arrowIsRotating = NO;
	isUpdatingListings = NO;
	processingShown = NO;
  
	[self setTitle:@"Check In"];
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	mainTable.backgroundColor = [UIColor clearColor];
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.leftBarButtonItem = nil;

  self.navigationItem.rightBarButtonItem = nil;
	showingProfilePage = NO;
	if (communicator.myNearbyMetroID == -1) {
		showAlertMessage = YES;
	} else {
		showAlertMessage = NO;

	}
	alertShown = NO;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(cachedCheckinsLoaded:) name:gcCheckinListingsLoadedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	communicator.checkinAndPopularDelegate = self;
	if (!showingProfilePage) {
    [self.checkinListings removeAllObjects];
		if (communicator.listings.closeByCheckinListingsLoaded) {
      if ([communicator.listings.popularListings count] > 0) {
        NSArray *popularArray = [[NSArray alloc] initWithArray:communicator.listings.popularListings];
        NSDictionary *popular = [[NSDictionary alloc] initWithObjectsAndKeys:popularArray, @"listings", @"POPULAR NOW", @"headerTitle", nil];
        [self.checkinListings addObject:popular];
        [popular release];
        [popularArray release];
        self.showAllNearbyVisible = YES;
      }
      
      if ([communicator.listings.closeByCheckinListings count] > 0) {
        NSArray *closebyArray = [[NSArray alloc] initWithArray:communicator.listings.closeByCheckinListings];
        NSDictionary *closeby = [[NSDictionary alloc] initWithObjectsAndKeys:closebyArray, @"listings", @"NEARBY GAYCITIES PLACES", @"headerTitle", nil];
        [self.checkinListings addObject:closeby];
        [closeby release];
        [closebyArray release];
        self.showAllNearbyVisible = YES;
      }
      
      if ([communicator.foursquareListings count] > 0) {
        NSArray *foursquareArray = [[NSArray alloc] initWithArray:communicator.foursquareListings];
        NSDictionary *foursquare = [[NSDictionary alloc] initWithObjectsAndKeys:foursquareArray, @"listings", @"OTHER PLACES", @"headerTitle", nil];
        [self.checkinListings addObject:foursquare];
        [foursquare release];
        [foursquareArray release];
      }
		}
		[communicator findMe:GCLocationSearchCheckins];
	}
	
}



- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	if (showingProfilePage) {
    showingProfilePage = NO;
  } else {
		if (([communicator.listings.closeByCheckinListings count] == 0 && [communicator.listings.popularListings count] == 0) && (communicator.myNearbyMetroID != communicator.currentMetroID || !communicator.previousLocation) && showAlertMessage && !alertShown && communicator.listings.closeByCheckinListingsLoaded) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Find Nearby Listings" message:@"We need your current location to show listings where you can\ncheck in." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"OK, Find Me", nil];
			[alert show];
			[alert release];
			alertShown = YES;
			showAlertMessage = NO;
		} else if ((!communicator.listings.closeByCheckinListingsLoaded || !communicator.isUpdatingLocation) && ![communicator isThereNoInternet]) {
      [self hideProcessing];
      [communicator refreshCheckinsAndLocation]; // new
      [self showProcessingInTable];
      [self performSelector:@selector(stopUpdating) withObject:nil afterDelay:12.0];
		} else if (communicator.isUpdatingLocation) {
      [self showProcessingInTable];
      [self performSelector:@selector(stopUpdating) withObject:nil afterDelay:12.0];
    }
	}
	[mainTable reloadData];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		if (communicator.isUpdatingLocation) {
			NSLog(@"checkin - already updating location");
			return;
		}
		if (communicator.myNearbyMetroID == -1) {
			[communicator refreshCheckinsAndLocation];
		} else {
			//[self showProcessing];
			[communicator refreshCheckinsAndLocation];
		}
	}
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self hideProcessing];
  if (processingShown || isUpdatingListings) {
    [self hideProcessingInTable];
  }
	if (!alertShown && !communicator.previousLocation && !showAlertMessage && communicator.myNearbyMetroID != -1) {
		showAlertMessage = YES;
	}
}



- (void)viewDidUnload {

}


- (void)dealloc {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self name:gcCheckinListingsLoadedNotification object:nil];
  communicator.checkinAndPopularDelegate = nil;

  [checkinListings release];
  checkinListings = nil;
	self.mainTable = nil;
	self.processingView = nil;
	self.activityView = nil;
  self.refreshLabel = nil;
  self.refreshActivity = nil;
  [super dealloc];
}

- (NSMutableArray *)checkinListings {
  if (!checkinListings) {
    checkinListings = [[NSMutableArray alloc] init];
  }
  return checkinListings;
}

#pragma mark -
#pragma mark Reload scroll methods

#pragma mark TableView Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!isUpdatingListings) {
		if (!communicator.isUpdatingLocation) {
      // need to incorporate several previous positions, last update time, distance traveled, time elapsed, etc...
			float offsetY = scrollView.contentOffset.y;
			if (offsetY <= -55) {
				[self showProcessingInTable];
				NSLog(@"Scroll Dragged - Force Checkin Updates");
				[communicator refreshCheckinsAndLocation];
        [self performSelector:@selector(stopUpdating) withObject:nil afterDelay:10.0];
			}
		} else if (!processingShown) {
      [self showProcessingInTable];
      [self performSelector:@selector(stopUpdating) withObject:nil afterDelay:5.0];
    }
	}
	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (!arrowIsRotating && scrollView.tracking && !isUpdatingListings && !processingShown) {
    
		float offsetY = scrollView.contentOffset.y;
		if (offsetY <= -55) {
			if (arrowIsPointingDown) {
				arrowIsRotating = YES;
				
        //	NSLog(@"Scroll point up now: %f", offsetY);
				NSInvocationOperation *iop = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(changeTextForArrowUp) object:nil] autorelease];
				[iop start];
				
			}
			
		} else {
			if (!arrowIsPointingDown) {
				arrowIsRotating = YES;
				
				//NSLog(@"Scroll point down now: %f", offsetY);
				NSInvocationOperation *iop = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(changeTextForArrowDown) object:nil] autorelease];
				[iop start];
			}
			
		}
	}
}

- (void)changeTextForArrowUp
{
  
	refreshLabel.text = @"Release to refresh";
	arrowIsPointingDown = NO;
	arrowIsRotating = NO;
  
}

- (void)changeTextForArrowDown {
	refreshLabel.text = @"Pull Down to refresh";
	arrowIsPointingDown = YES;
	arrowIsRotating = NO;
  
}

- (void)stopUpdating {
  [self hideProcessingInTable];
}

- (void)showProcessingInTable
{
	processingShown = YES;
	isUpdatingListings = YES;
  
	UIEdgeInsets insets = {34,0,-34,0};
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.4];
	[UIView setAnimationDidStopSelector:@selector(hideRefreshElements)];
	[UIView setAnimationDelegate:self];
	mainTable.contentInset = insets;
	[UIView commitAnimations];	
  
	
}

- (void)hideProcessingInTable
{
  if (processingShown) {
    UIEdgeInsets insets = {0,0,0,0};
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4];
    [UIView setAnimationDidStopSelector:@selector(unHideRefreshElements)];
    [UIView setAnimationDelegate:self];
    mainTable.contentInset = insets;
    [UIView commitAnimations];	
    isUpdatingListings = NO;
    processingShown = NO;
  }
	
}

- (void)hideRefreshElements
{
	//refreshArrowImageView.hidden = YES;
	refreshLabel.text = @"\n\nUpdating...";
	[refreshActivity startAnimating];
}

- (void)unHideRefreshElements
{
	refreshLabel.text = @"Pull down to refresh";
	[refreshActivity stopAnimating];
	//refreshArrowImageView.hidden = NO;
	if (!arrowIsPointingDown) {
		//refreshArrowImageView.transform = CGAffineTransformMakeRotation(0);
		arrowIsPointingDown = YES;
	}
	
	
}

#pragma mark Communicator delegates

- (void)cachedCheckinsLoaded:(NSNotification *)note{
	[self didRecieveCheckInUpdates];
}

- (void)didRecieveCheckInUpdates {
  [self performSelectorOnMainThread:@selector(processCheckinUpdates) withObject:nil waitUntilDone:NO];
}

- (void)errorRecievingCheckInUpdates {
  [self performSelectorOnMainThread:@selector(processCheckinUpdates) withObject:nil waitUntilDone:NO];
}

- (void)processCheckinUpdates {
  [self hideProcessingInTable];
  [self.checkinListings removeAllObjects];
  self.showAllNearbyVisible = NO;

	NSLog(@"processCheckinUpdates - updating popular and checkins");
	if (communicator.myNearbyMetroID != -1 && communicator.previousLocation) {
    if ([communicator.listings.popularListings count] > 0) {
      NSArray *popularArray = [[NSArray alloc] initWithArray:communicator.listings.popularListings];
      NSDictionary *popular = [[NSDictionary alloc] initWithObjectsAndKeys:popularArray, @"listings", @"POPULAR NOW", @"headerTitle", [NSNumber numberWithInt:[popularArray count]], @"rowCount", nil];
      [self.checkinListings addObject:popular];
      [popular release];
      [popularArray release];
      self.showAllNearbyVisible = YES;
    }
    
    if ([communicator.listings.closeByCheckinListings count] > 0) {
      NSArray *closebyArray = [[NSArray alloc] initWithArray:communicator.listings.closeByCheckinListings];
      NSDictionary *closeby = [[NSDictionary alloc] initWithObjectsAndKeys:closebyArray, @"listings", @"NEARBY GAYCITIES PLACES", @"headerTitle", [NSNumber numberWithInt:MIN([closebyArray count], 10)], @"rowCount", nil];
      [self.checkinListings addObject:closeby];
      [closeby release];
      [closebyArray release];
      self.showAllNearbyVisible = YES;
    }
	}
  
  if ([communicator.foursquareListings count] > 0) {
    NSArray *foursquareArray = [[NSArray alloc] initWithArray:communicator.foursquareListings];
    NSDictionary *foursquare = [[NSDictionary alloc] initWithObjectsAndKeys:foursquareArray, @"listings", @"OTHER PLACES", @"headerTitle", [NSNumber numberWithInt:MIN([foursquareArray count], 15)], @"rowCount", nil];
    [self.checkinListings addObject:foursquare];
    [foursquare release];
    [foursquareArray release];
  }
  
  if (self.navigationController.topViewController == self) {
		[self hideProcessing];
		[mainTable reloadData];
	}
}




#pragma mark Misc

- (void)showProcessing
{
	processingView.hidden = NO;
	[activityView startAnimating];
}

- (void)hideProcessing
{
	[activityView stopAnimating];
	processingView.hidden = YES;

}

- (IBAction)showAllNearby
{
	if ([communicator.listings.allCloseByCheckinListings count] == 0 && [communicator.listings.closeByCheckinListings count] ==0 && [communicator.listings.popularListings count] == 0) {
		UITabBar *tabBar = [[GayCitiesAppDelegate sharedAppDelegate] mainTabBar];
		UITabBarItem *anItem = nil;
		for (UITabBarItem *item in [tabBar items]) {
			if (item.tag == 20) {
				anItem = item;
				break;
			}
		}
		if (anItem) {
			[tabBar setSelectedItem:anItem];
			[tabBar.delegate tabBar:tabBar didSelectItem:anItem];
		}
		return;
	}
	GCListingViewController *lvc = [[GCListingViewController alloc] init];
	lvc.useCheckInListings = YES;
	lvc.listingType = nil;
	lvc.currentMetro = [communicator.metros metroForIntID:communicator.myNearbyMetroID];
	[self.navigationController pushViewController:lvc animated:YES];
	[lvc release];
}

- (void)showPeopleTab
{
	UITabBar *tabBar = [[GayCitiesAppDelegate sharedAppDelegate] mainTabBar];
	UITabBarItem *anItem = nil;
	for (UITabBarItem *item in [tabBar items]) {
		if (item.tag == 40) {
			anItem = item;
			break;
		}
	}
	if (anItem) {
		[tabBar setSelectedItem:anItem];
		[tabBar.delegate tabBar:tabBar didSelectItem:anItem];
		NSLog(@"Selected Item");
	}
	return;
	
}


- (void)openProfilePageForUser:(NSString *)username
{
	showingProfilePage = YES;
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


#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger count = [self.checkinListings count];
  if (count > 0 && self.showAllNearbyVisible) count ++;
	
  return MAX(count, 1);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([self.checkinListings count] == 0) return 1;
  else if ((section == [tableView numberOfSections] - 1) && self.showAllNearbyVisible) return 1;
  return [[[self.checkinListings objectAtIndex:section] objectForKey:@"rowCount"] intValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (!communicator.listings.closeByCheckinListingsLoaded) {
		if (!communicator.noInternet) {
			return 25;
		}
	}

	if ([self.checkinListings count] == 0) {
		return 120;
	}
	
	if ((section >= [tableView numberOfSections] - 1) && self.showAllNearbyVisible) {
		return 0;
	}
	
	return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	
	if (!communicator.listings.closeByCheckinListingsLoaded) {
		if (!communicator.noInternet) {
			UIView *aView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)] autorelease];
			aView.backgroundColor = [UIColor clearColor];
			UILabel *label = [UILabel gcLabelForTableHeaderView];
			label.text = @"\n\nLoading Nearby Places...";
			label.frame = CGRectMake(0, 0, 320, 100);
			[aView addSubview:label];
			UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			activity.frame = CGRectMake(150, 80, 20, 20);
			[aView addSubview:activity];
			[activity startAnimating];
			[activity release];
			
			return aView;
		}
	}
	
  if ([self.checkinListings count] == 0) { //
		UILabel *label = [UILabel gcLabelForTableHeaderView];
		if ([communicator.listings.allCloseByCheckinListings count] > 1) {
			label.text = [NSString stringWithFormat:@"\nYou are not close enough to a listing\nto check in\n\nTap Browse or Map to see all %i listings in your area", [communicator.listings.allCloseByCheckinListings count]];
			label.font = [UIFont boldSystemFontOfSize:14];
		} else {
			label.text = @"\nYou are not close enough to a listing\nto check in";
		}
		return label;
  }
  
  if ((section >= [tableView numberOfSections] - 1) && self.showAllNearbyVisible) 
	  return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  

  UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)] autorelease];
  headerView.backgroundColor = [UIColor colorWithHue:0.577 saturation:0.186 brightness:0.867 alpha:1.000]; //[UIColor colorWithRed:.255 green:.302 blue:.326 alpha:1];
  UILabel *label = [UILabel gcLabelClearForTableHeaderView];
  label.textColor = [UIColor blackColor];
  label.text = [[self.checkinListings objectAtIndex:section] objectForKey:@"headerTitle"];
  [headerView addSubview:label];
  return headerView;		
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ([self.checkinListings count] == 0) { //
		GCSingleButtonCell *cell  = (GCSingleButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"singleButtonCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSingleButtonCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
			cell.backgroundColor = [UIColor clearColor];
			[cell.button addTarget:self action:@selector(showAllNearby) forControlEvents:UIControlEventTouchUpInside];
			//cell.button.showsTouchWhenHighlighted = YES;
		}
		[cell.button setImage:[UIImage imageNamed:@"browseAllListingsButtonCI.png"] forState:UIControlStateNormal];

		return cell;
	}
	int row = [indexPath row];
	int section = [indexPath section];
	
	if ((section >= [tableView numberOfSections] - 1) && self.showAllNearbyVisible) {
		GCSingleButtonCell *cell  = (GCSingleButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"singleButtonCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSingleButtonCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
			cell.backgroundColor = [UIColor clearColor];
			[cell.button addTarget:self action:@selector(showAllNearby) forControlEvents:UIControlEventTouchUpInside];
			//cell.button.showsTouchWhenHighlighted = YES;
		}
		[cell.button setImage:[UIImage imageNamed:@"showAllNearbyButtonCI.png"] forState:UIControlStateNormal];

		return cell;
	}
	
	
	GCListing *listing = [[[self.checkinListings objectAtIndex:section] objectForKey:@"listings"] objectAtIndex:row];

	GCListingsCell *aCell  = (GCListingsCell *)[tableView dequeueReusableCellWithIdentifier:@"listingsCell"];
	if (aCell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingsCell" owner:self options:nil];
		aCell = [[[nib objectAtIndex:0] retain] autorelease];
		aCell.listingAddress.frame = CGRectMake(16, 48, 229, 21);
	}
	
	aCell.listingName.text = listing.name;
	aCell.disclosureImageView.hidden = NO;
	
	aCell.star.image = nil;
	
	aCell.listingOneLiner.text = @"";
	NSString *aType = [listing.type capitalizedString];
	
  NSString *streetAndCity = nil;
  if (listing.street && listing.city) streetAndCity = [NSString stringWithFormat:@"%@, %@", listing.street, listing.city];
  else if (listing.street) streetAndCity = listing.street;
  else if (listing.city) streetAndCity = listing.city;
  
	if ([aType isEqualToString:@"Foursquare"]) {
		if ([[listing hood] length] > 0) {
			aCell.listingAddress.text = streetAndCity ? [NSString stringWithFormat:@"%@ - %@",[listing hood], streetAndCity] : listing.hood;
		} else {
			aCell.listingAddress.text = streetAndCity;
		}
	} else {
		aCell.listingAddress.text = streetAndCity;
	}
	
	
	double dist = [listing.distance doubleValue];
	dist = dist * 0.00062137119;
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setMaximumFractionDigits:2];
	aCell.distance.text = [NSString stringWithFormat:@"%@ mi", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:dist]]];
	[numberFormatter release];
	
	
	return aCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 62;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[GCSingleButtonCell class]]) {
		return;
	}
	if ([communicator.ul shouldCheckInToListing]) {
		int row = [indexPath row];
		int section = [indexPath section];
    GCListing *listing = [[[self.checkinListings objectAtIndex:section] objectForKey:@"listings"] objectAtIndex:row];

		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"CHECKIN_TAB-Listing selected to check-in" withParameters:nil];

		GCListingCheckinViewController *lcivc = [[GCListingCheckinViewController alloc] init];
		lcivc.listing = listing;
		lcivc.mainCheckinViewController = self;
		UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:lcivc];
		//lcivc.communicator = communicator;
		[self presentModalViewController:controller animated:YES];
		[controller release];
		[lcivc release];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
