//
//  BrowseViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/28/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCBrowseViewController.h"
#import "GCListingViewController.h"
#import "GCEventsViewController.h"
#import "GayCitiesAppDelegate.h"
#import "OCConstants.h"
#import "Reachability.h"
#import "GCMetro.h"
#import "GCBrowseViewCell.h"
#import "GCUILabelExtras.h"

@implementation GCBrowseViewController

@synthesize browseTableView;
@synthesize communicator;

- (id)init
{
	if (self = [super init]) {
		self.communicator = [GCCommunicator sharedCommunicator];
		communicator.delegate = self;
	}
	return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:@"Places"];
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	browseTableView.backgroundColor = [UIColor colorWithRed:.706 green:.792 blue:.867 alpha:1];
	[browseTableView reloadData];

}
 


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//[self.navigationController setNavigationBarHidden:NO];

	
	UIBarButtonItem *cityButton = [[UIBarButtonItem alloc] initWithTitle:@"Pick City" style:UIBarButtonItemStyleBordered target:self action:@selector(changeCity)];
	
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = cityButton;
	[cityButton release];
	//communicator.delegate = self;
	//communicator.listingDelegate = nil;
	
}
 

- (void)viewDidAppear:(BOOL)animated {
	 [super viewDidAppear:animated];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
}
 

- (void)viewWillDisappear:(BOOL)animated {
	 [super viewWillDisappear:animated];
}
 
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.browseTableView = nil;
  [super dealloc];
}

- (void)changeCity
{
	[communicator.locationMgr stopUpdatingLocation];
	[communicator isThereNoInternet];
	if ([communicator isThereNoInternet]) {
		UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:@"Since there appears to be no network connection, the current city cannot be changed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noInternetAlert show];
		[noInternetAlert release];
		return;
	}
	
	GCCityChangeViewController *cvc = [[GCCityChangeViewController alloc] init];
	cvc.viewType = optionalSelectionViewType;
	cvc.delegate = self;
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	
	
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	gcad.mainTabBar.hidden = YES;
  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:cvc];
  [cvc release];

	[self.navigationController presentModalViewController:nc animated:YES];
	[nc release];
	
}

- (void)cityViewDidSelectMetro:(GCMetro *)newMetro;
{
	GCMetro *prevMetro = communicator.metros.currentMetro;
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	if (newMetro && prevMetro) {
		if (newMetro.metro_id && newMetro.metro_name && prevMetro.metro_id && prevMetro.metro_name) {
			[gcad logEventForFlurry:@"BROWSE-City_Change-New Metro selected" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:newMetro.metro_id, @"new_metro_id", newMetro.metro_name, @"new_metro_name",prevMetro.metro_id, @"from_Previous_metro_id", prevMetro.metro_name,@"from_Previous_metro_name", nil]];
			
		}
	}
	[communicator locateCity:newMetro];
	NSLog(@"metro: %@", newMetro.metro_name);
	
	[self dismissModalViewControllerAnimated:YES];
	
	gcad.adBackgroundView.hidden = NO;
	gcad.mainTabBar.hidden = NO;
	gcad.shouldShowAdView = YES;

	
	
}

- (void)cityViewDidCancel
{
	[self dismissModalViewControllerAnimated:YES];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	[gcad logEventForFlurry:@"BROWSE-City_Change-Cancel pressed" withParameters:nil];

	gcad.adBackgroundView.hidden = NO;
	gcad.mainTabBar.hidden = NO;
	gcad.shouldShowAdView = YES;
}

- (void)cityViewDidSelectNearby {
	[communicator findMe:GCLocationSearchGlobal];
	[self dismissModalViewControllerAnimated:YES];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	[gcad logEventForFlurry:@"BROWSE-City_Change-Nearby pressed" withParameters:nil];

	gcad.adBackgroundView.hidden = NO;
	gcad.mainTabBar.hidden = NO;
	gcad.shouldShowAdView = YES;
}




#pragma mark Communicator delegates

- (void)didUpdateListings
{
	[browseTableView reloadData];
	
}

- (void)didUpdateMetros
{
	
}


- (void)didUpdateLocation
{
	[browseTableView reloadData];
}

- (void)didChangeCurrentMetro
{
	[browseTableView reloadData];
}

- (void)noInternetErrorLocation
{
	
}

- (void)noInternetErrorListings
{
	
}

- (void)locationError
{
	
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
		if ([communicator.listings.events count] > 0) {
			return 1; //changed for events tab
		}
		else {
			return 1;
		}
	}
	if (communicator.listings && section == 1)
		return ([communicator.listings numberOfTypes]);
	
	return 0;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	if (section == 1)
		return @"";
	else if (section == 0)
		return communicator.metros.currentMetro.metro_name;

	
	return @"";
}*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return 34;
	}
	
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		UILabel *label = [UILabel gcLabelForTableHeaderView];

		label.text = communicator.metros.currentMetro.metro_name;
		return label;
	}
	
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
	
	GCBrowseViewCell *cell  = (GCBrowseViewCell *)[tableView dequeueReusableCellWithIdentifier:@"browseViewCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCBrowseViewCell" owner:self options:nil];
		cell = (GCBrowseViewCell *)[[[nib objectAtIndex:0] retain] autorelease];
	}
	
	int row = [indexPath row];
    
    if ([indexPath section] == 0){
		if (row == 0) {
			if ([[communicator.listings listings] count] == 0 || [[communicator.listings listingTypes] count] == 0) {
				cell.typeName.text = @"No Listings";
				cell.typeImage.image = [UIImage imageNamed:@"nearby.png"];
			}else if (communicator.currentLocation) {
				cell.typeName.text = @"All Nearby";
				cell.typeImage.image = [UIImage imageNamed:@"nearby.png"];
			} else {
				cell.typeName.text = @"All Listings";
				cell.typeImage.image = [UIImage imageNamed:@"nearby.png"];
			}
		} /*else if (row == 1) {
			if ([communicator.listings.events count] > 0) {
				cell.typeName.text = [NSString stringWithFormat:@"Events"];
				cell.typeImage.image = [UIImage imageNamed:@"events.png"];
			}
		}*/
		
		//else if (noInternet) {
		//cell.text = @"Events (0)";
		//}
		
	}
	else if ([indexPath section] ==1) {
		if (communicator.listings) {
			if (row >= [[communicator.listings listingTypes] count]) {
				cell.typeName.text = @"";
				cell.typeImage.image = nil;
			} else {
				cell.typeName.text = [[[[communicator.listings listingTypes]objectAtIndex:row] name] capitalizedString];
				cell.typeImage.image = [[[communicator.listings listingTypes]objectAtIndex:row] typeImage];
			}
		}
	} else {
		cell.typeName.text = @"";
		cell.typeImage.image = nil;
	}
	
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int row = [indexPath row];

	if ([indexPath section] ==1) {
		if (row < [[communicator.listings listingTypes] count]) {
			GCListingViewController *lvc = [GCListingViewController new];
			lvc.listingType = [communicator.listings.listingTypes objectAtIndex:row];
			[self.navigationController pushViewController:lvc animated:YES];
			[lvc release];
		}
		
	}
	else if ([indexPath section]==0) {
		if ([indexPath row] == 0) {
			if ([[communicator.listings listings] count] == 0) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Listings" message:@"There aren't any listings yet for the chosen city." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
				
			} else {
				GCListingViewController *lvc = [GCListingViewController new];
				lvc.listingType = nil;
				[self.navigationController pushViewController:lvc animated:YES];
				[lvc release];
			}
			


		}/* else if ([indexPath row] == 1) {
			if ([communicator.listings.events count] > 0) {
				GCEventsViewController *evc = [[GCEventsViewController alloc] init];
				//evc.communicator = communicator;
				
				[self.navigationController pushViewController:evc animated:YES];
				[evc release];
			}
			else {
				UIAlertView *noEvents = [[UIAlertView alloc] initWithTitle:@"No Events" message:@"There are currently no events listed for the selected city.  Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[noEvents show];
				[noEvents release];
			}
		}*/
		
	}
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	
}




- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}


@end
