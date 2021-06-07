//
//  OCBrowseListController.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/10/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import "GCListingViewController.h"
#import "GCListingsController.h"
#import "GCListingsCell.h"
#import "GCDetailViewController.h"
#import "GayCitiesAppDelegate.h"
#import "GCListing.h"
#import "GCListingTag.h"
#import "OCConstants.h"
#import "GCBrowseViewCell.h"
#import "GCUILabelExtras.h"
#import "GCSingleButtonCell.h"
#import "GCGeneralTextCell.h"

@interface UITableViewCell (Private)
-(UILabel *)listingName;
-(UILabel *)listingOneLiner;
@end

@implementation GCListingViewController

@synthesize listingTable, tagTable, headerLabel, browseSortControl, neighborhoodPicker;
@synthesize communicator, listingType;
@synthesize filterView, headerView, filterLabel;
@synthesize filterSearchBar;
@synthesize filterButton;
@synthesize useCheckInListings;
@synthesize currentMetro;


- (id)init
{
	if (self = [super init]) {
		self.communicator = [GCCommunicator sharedCommunicator];
		useCheckInListings = NO;
		self.currentMetro = nil;
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	allTagsSelected = YES;
	
	[browseSortControl setTintColor:[UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1]];

	neighborhoodSelectedIndex = 0;
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	isLoading = YES;
	isReloadingSegments = NO;
	if (communicator.currentLocation) {
		usesCurrentLocation = YES;
		sortBy = gcSortDist;
	} else {
		usesCurrentLocation = NO;
		sortBy = gcSortName;
	}
	
	if (useCheckInListings) {
		isAllListings = YES;
		usesCurrentLocation = YES;
		sortBy = gcSortDist;
		[communicator.listings setAllFilteredListings:communicator.listings.allCloseByCheckinListings withLocation:communicator.previousLocation];
		if (!currentMetro) {
			self.currentMetro = communicator.metros.currentMetro;
		}
	} else if (listingType) {
		self.currentMetro = communicator.metros.currentMetro;
		isAllListings = NO;
		if (usesCurrentLocation) {
			[communicator.listings setAllFilteredListings:listingType.listings withLocation:communicator.currentLocation];
		} else {
			[communicator.listings setAllFilteredListings:listingType.listings withLocation:nil];
		}		
	} else {
		self.currentMetro = communicator.metros.currentMetro;
		isAllListings = YES;
		if (usesCurrentLocation) {
			[communicator.listings setAllFilteredListings:communicator.listings.listings withLocation:communicator.currentLocation];
		} else {
			[communicator.listings setAllFilteredListings:communicator.listings.listings withLocation:nil];
		}
	}
	filterSearchBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1]; 
	//filterButton.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1]; 

	
	filterSearchBar.translucent = YES;
	listingTable.tableHeaderView = headerView;
	/*UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(filterListings)];
	self.navigationItem.rightBarButtonItem = filterButton;
	[filterButton release];*/
	filterLabel.frame = CGRectMake(0, 73, 320, 21);
	tagTable.backgroundColor = [UIColor clearColor];
	if (useCheckInListings) {
		headerLabel.text = @"All Nearby";
	} else if (!isAllListings) {
		headerLabel.text = [NSString stringWithFormat:@"%@ in %@", [listingType.name capitalizedString], currentMetro.metro_name];
		
	} else {
		headerLabel.text = [NSString stringWithFormat:@"All in %@", currentMetro.metro_name];
	}
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"LISTINGS_LIST-Viewed" withParameters:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	
	//communicator.listingDelegate = self;
	if (isLoading) {
		isLoading = NO;
		[self reloadSegments];
	}
	

	
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);

}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	/*if (communicator.listingDelegate == self) {
		communicator.listingDelegate = nil;
	}*/
	
}


- (void)didReceiveMemoryWarning {
	
	//[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	if ([[self navigationController] visibleViewController]==self) {
		return;
	}
   
    // Release anything that's not essential, such as cached data
	
	
}


- (void)dealloc {	
	self.listingTable = nil;
	self.tagTable = nil;
	self.browseSortControl = nil;
	self.neighborhoodPicker = nil;
	self.headerLabel = nil;
	self.filterView = nil;
	self.filterSearchBar = nil;
	self.filterButton = nil;
	self.headerView = nil;
	self.filterLabel = nil;
	self.currentMetro = nil;
  [super dealloc];
}



- (void)submitBusiness
{
	if (!communicator.noInternet) {
		NSMutableSet *listingTypes = [[NSMutableSet alloc] init];
		NSMutableSet *neighborhoodNames = [[NSMutableSet alloc] init];
		if (useCheckInListings) {
			for (GCListingType *aType in communicator.listings.allCloseByCheckinTypes) {
				[listingTypes addObject:[aType.name capitalizedString]];
			}
			for (GCListing *aListing in communicator.listings.allCloseByCheckinListings) {
				if (![aListing.hood isEqualToString:@"zzzOther" ]) {
					[neighborhoodNames addObject:aListing.hood];
				}
			}
		} else {
			for (GCListingType *aType in communicator.listings.listingTypes) {
				[listingTypes addObject:[aType.name capitalizedString]];
			}
			for (GCListing *aListing in communicator.listings.listings) {
				if (![aListing.hood isEqualToString:@"zzzOther" ]) {
					[neighborhoodNames addObject:aListing.hood];
				}
			}
		}
		
		
		
		
		if ([filterSearchBar.text length] > 0) {
			[communicator.ul submitNewBusiness:filterSearchBar.text forMetro:currentMetro withTypes:[listingTypes allObjects] andHoods:[neighborhoodNames allObjects]];
		} else {
			[communicator.ul submitNewBusiness:@"" forMetro:currentMetro withTypes:[listingTypes allObjects] andHoods:[neighborhoodNames allObjects]];
		}
		[listingTypes release];
		[neighborhoodNames release];
	}
	
}




#pragma mark Sort  Methods

- (IBAction)changeSort:(id)sender
{
	if (isReloadingSegments) {
		return;
	}
	if (sender == browseSortControl) {
		int index = [browseSortControl selectedSegmentIndex];
		
		NSString *sortTitle = [browseSortControl titleForSegmentAtIndex:index];
		
		if ([sortTitle isEqualToString:@"Name"]) {
			[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"LISTINGS_LIST-Sort name" withParameters:nil];
			sortBy = gcSortName;
			[communicator.listings sortFilteredListingsAlphabetical];
			
		} else if ([sortTitle isEqualToString:@"Rating"]) {
			[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"LISTINGS_LIST-Sort rating" withParameters:nil];
			sortBy = gcSortRating;
			[communicator.listings sortFilteredListingsRating];
			
		} else if ([sortTitle isEqualToString:@"Dist"]) {
			[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"LISTINGS_LIST-Sort distance" withParameters:nil];
			sortBy = gcSortDist;
			[communicator.listings sortFilteredListingsDistance];
		} else if ([sortTitle isEqualToString:@"Hood"]) {
			[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"LISTINGS_LIST-Sort hood" withParameters:nil];
			sortBy = gcSortHood;
			
		}
		[listingTable reloadData];
	}
	
				
}

- (IBAction)filterListings
{
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"LISTINGS_LIST-Filter Button Pressed" withParameters:nil];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.navigationItem.prompt = nil;

	
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	gcad.mainTabBar.hidden = YES;
	self.view.frame = CGRectMake(0, 0, 320, 416);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.6];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];;
	[self.view addSubview:filterView];
	[UIView commitAnimations];
	
	[neighborhoodPicker selectRow:neighborhoodSelectedIndex inComponent:0 animated:NO];

	self.navigationItem.hidesBackButton = YES;
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeFilterListings)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	
	[tagTable reloadData];
	
	
}

- (IBAction)closeFilterListings
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	
	
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;

	gcad.mainTabBar.hidden = NO;
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);

	
	
	
	int row = [neighborhoodPicker selectedRowInComponent:0];
	if ([filterSearchBar.text length] > 0) {
		if (row == 0) {
			[communicator.listings filterListingsForKeyword:filterSearchBar.text withListings:communicator.listings.allFilteredListings  usingAllTags:allTagsSelected];
		} else {
			[communicator.listings filterListingsForKeyword:filterSearchBar.text withListings:[[communicator.listings.allFilteredHoods objectAtIndex:row - 1] listings]  usingAllTags:allTagsSelected];
		}
	} else {
		if (row == 0) {
			[communicator.listings setFilteredListingsKeepingTags:communicator.listings.allFilteredListings usingAllTags:allTagsSelected];
		} else {
			[communicator.listings setFilteredListingsKeepingTags:[[communicator.listings.allFilteredHoods objectAtIndex:row - 1] listings] usingAllTags:allTagsSelected];
		}
	}
	
	if (row == 0 && allTagsSelected) {
		[filterLabel removeFromSuperview];
		headerView.frame = CGRectMake(0, 0, 320, 76);
		listingTable.tableHeaderView = headerView;

		
	} else {
		headerView.frame = CGRectMake(0, 0, 320, 95);
		[headerView addSubview:filterLabel];
		//[headerView sendSubviewToBack:filterLabel];
		listingTable.tableHeaderView = headerView;
	}
	
	[self reloadSegments];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.6];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:gcad.window cache:YES];;
	[filterView removeFromSuperview];
	[UIView commitAnimations];
	
	
	
	self.navigationItem.hidesBackButton = NO; 
	self.navigationItem.rightBarButtonItem = nil;
	
/*	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3) {
		NSArray *subviews = filterSearchBar.subviews;
		[[subviews objectAtIndex:0] setHidden:YES];
	}*/

}


-(void)reloadSegments
{
	isReloadingSegments = YES;
	[browseSortControl setSelectedSegmentIndex:0];
	while ([browseSortControl numberOfSegments] > 1) {
		[browseSortControl removeSegmentAtIndex:1 animated:NO];
	}
	
	
	
	
	if (usesCurrentLocation) {
		[browseSortControl setTitle:@"Dist" forSegmentAtIndex:0];
		[browseSortControl insertSegmentWithTitle:@"Name" atIndex:1 animated:NO];
		[browseSortControl insertSegmentWithTitle:@"Rating" atIndex:2 animated:NO];
		if ([communicator.listings.filteredNeighborhoods count] >1) {
			[browseSortControl insertSegmentWithTitle:@"Hood" atIndex:3 animated:NO];
			if (sortBy == gcSortHood) {
				[browseSortControl setSelectedSegmentIndex:3];
			} 
		} else {
			[browseSortControl setSelectedSegmentIndex:0];
		}
		if (sortBy == gcSortRating) {
				[browseSortControl setSelectedSegmentIndex:2];
		} else if (sortBy == gcSortName) {
				[browseSortControl setSelectedSegmentIndex:1];
		} else if (sortBy == gcSortDist) {
			[browseSortControl setSelectedSegmentIndex:0];
		}

	} else {
		[browseSortControl setTitle:@"Name" forSegmentAtIndex:0];
		[browseSortControl insertSegmentWithTitle:@"Rating" atIndex:1 animated:NO];
		if ([communicator.listings.filteredNeighborhoods count] >1) {
			[browseSortControl insertSegmentWithTitle:@"Hood" atIndex:2 animated:NO];
			if (sortBy == gcSortHood) {
				[browseSortControl setSelectedSegmentIndex:2];
			} 
		} else {
			[browseSortControl setSelectedSegmentIndex:0];
		}
		if (sortBy == gcSortRating) {
			[browseSortControl setSelectedSegmentIndex:1];
		} else if (sortBy == gcSortName) {
			[browseSortControl setSelectedSegmentIndex:0];
		} 
	}
	
	
	isReloadingSegments = NO;
	[self changeSort:browseSortControl];


}



-(IBAction)closeNeighborhoodPicker:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(closeNeighborhoodPickerThread) toTarget:self withObject:nil];

}

-(IBAction)closeTagPicker:(id)sender
{

	[NSThread detachNewThreadSelector:@selector(closeTagPickerThread) toTarget:self withObject:nil];

}



#pragma mark TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {  
	if (tableView==listingTable) {
		switch (sortBy) {
			case gcSortName:
				return 2;
			case gcSortRating:
				return 2;
			case gcSortDist:
				return 2;
			case gcSortHood:
				if ([communicator.listings.filteredNeighborhoods count] == 0) {
					return 2;
				}
				return [communicator.listings.filteredNeighborhoods count] + 1;
		}
	}
	else if (tableView == tagTable) {
		return 1;
	}
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView==listingTable) {
		if ([communicator.listings.filteredListings count] == 0) {
			return 1;
		}
		switch (sortBy) {
			case gcSortName:
				if (section == 1) {
					return 1;
				}
				return [communicator.listings.filteredListings count];
			case gcSortRating:
				if (section == 1) {
					return 1;
				}
				return [communicator.listings.filteredListings count];
			case gcSortDist:
				if (section == 1) {
					return 1;
				}
				return [communicator.listings.filteredListings count];
			case gcSortHood:
				if ([communicator.listings.filteredNeighborhoods count] == 0 && section == 1) {
					return 1;  //dont think i need this, nut just in case
				}
				else if (section == [communicator.listings.filteredNeighborhoods count]) {
					return 1;
				}
				return [[[communicator.listings.filteredNeighborhoods objectAtIndex:section] listings] count];
		}
		
	}
	else if (tableView == tagTable) {
		return [communicator.listings.filteredTags count] + 1;;
	}
	return 0;	
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (tableView==listingTable) {
		if ([communicator.listings.filteredListings count] == 0) {
			return @"";
		}
		switch (sortBy) {
			case gcSortName:
				return @"";
				break;
			case gcSortRating:
				return @"";
				break;
			case gcSortDist:
				return @"";
				break;
			case gcSortHood:
				return [[communicator.listings.filteredNeighborhoods objectAtIndex:section] name];
				break;
		}
	}
	else if (tableView == tagTable) {
		return @"";
	}
	return @"";
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (tableView==listingTable) {
		/*	if ([communicator.listings.filteredListings count] == 0) {
		 return nil;
		 }*/
		switch (sortBy) {
			case gcSortName:
				if (section == 1) {
					return 30;
				}
				return 0;
			case gcSortRating:
				if (section == 1) {
					return 30;
				}
				return 0;
			case gcSortDist:
				if (section == 1) {
					return 30;
				}
				return 0;
			case gcSortHood: {
				int count = [communicator.listings.filteredNeighborhoods count];
				if (count == 0 && section == 0) {
					return 0;
				}
				return 30;
			}
		}
	}
	else if (tableView == tagTable) {
		return 0;
	}
	return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	
	if (tableView==listingTable) {
	/*	if ([communicator.listings.filteredListings count] == 0) {
			return nil;
		}*/
		switch (sortBy) {
			case gcSortName:
				if (section == 1) {
					UILabel *label = [UILabel gcLabelWhiteForTableHeaderView];
					label.text = @"Can't Find What You're Looking For?";
					return label;
				}
				return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
			case gcSortRating:
				if (section == 1) {
					UILabel *label = [UILabel gcLabelWhiteForTableHeaderView];
					label.text = @"Can't Find What You're Looking For?";
					return label;
				}
				return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
			case gcSortDist:
				if (section == 1) {
					UILabel *label = [UILabel gcLabelWhiteForTableHeaderView];
					label.text = @"Can't Find What You're Looking For?";
					return label;
				}
				return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
			case gcSortHood: {
				int count = [communicator.listings.filteredNeighborhoods count];
				if (count == 0 && section == 1) {
					UILabel *label = [UILabel gcLabelWhiteForTableHeaderView];
					label.text = @"Can't Find What You're Looking For?";
					return label;
				} else if (count == 0 && section == 0) {
					return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
				} else if (section == count) {
					UILabel *label = [UILabel gcLabelWhiteForTableHeaderView];
					label.text = @"Can't Find What You're Looking For?";
					return label;
				}
				UILabel *label = [UILabel gcLabelWhiteForTableHeaderView];
				label.text = [[communicator.listings.filteredNeighborhoods objectAtIndex:section] name];
				if ([label.text isEqualToString:@"zzzOther"]) {
					label.text = @"Other"; //hack
				}
				return label;
			}
		}
	}
	else if (tableView == tagTable) {
		return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	}
	return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = [indexPath section];
	
	 if (tableView == listingTable) {
		 BOOL submitButtonCell = NO;
		 switch (sortBy) {
			 case gcSortName:
				 if (section == 1) {
					 submitButtonCell = YES;
				 }
				 break;
			 case gcSortRating:
				 if (section == 1) {
					 submitButtonCell = YES;
				 }
				 break;
			 case gcSortDist:
				 if (section == 1) {
					 submitButtonCell = YES;
				 }
				 break;
			 case gcSortHood: {
				 int count = [communicator.listings.filteredNeighborhoods count];
				 if (count == 0 && section == 1) {
					 submitButtonCell = YES;
					 break;
				 } else if (count == 0 && section == 0) {
					 submitButtonCell = NO;
					 break;
				 } else if (section == count) {
					 submitButtonCell = YES;
					 break;
				 }
				 break;
			 }
		 }
		 
		 if (submitButtonCell) {
			 GCSingleButtonCell *cell  = (GCSingleButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"singleButtonCell"];
			 if (cell == nil) {
				 NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSingleButtonCell" owner:self options:nil];
				 cell = [[[nib objectAtIndex:0] retain] autorelease];
				 [cell.button setImage:[UIImage imageNamed:@"submitBusinessOrangeLong.png"] forState:UIControlStateNormal];
				 cell.backgroundColor = [UIColor clearColor];
				 [cell.button addTarget:self action:@selector(submitBusiness) forControlEvents:UIControlEventTouchUpInside];
			 }
			 
			 
			 return cell;
		 } else {
			 GCListingsCell *aCell  = (GCListingsCell *)[tableView dequeueReusableCellWithIdentifier:@"listingsCell"];
			 if (aCell == nil) {
				 NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingsCell" owner:self options:nil];
				 aCell = [[[nib objectAtIndex:0] retain] autorelease];
			 }
			 if ([communicator.listings.filteredListings count] == 0 && section == 0) {
				 aCell.listingName.text = @"";
				 
				 [aCell.star setImage:nil];
				 
				 aCell.listingOneLiner.text = @"Please broaden your search";
				 aCell.disclosureImageView.hidden = YES;
				 aCell.listingAddress.text = @"";
				 
				 aCell.distance.text = @"";
				 
				 
				 aCell.selectionStyle = UITableViewCellSelectionStyleNone;
			 } else{
				 GCListing *listing;
				 switch (sortBy) {
					 case gcSortName:
						 listing = [communicator.listings.filteredListings objectAtIndex:[indexPath row]];
						 break;
					 case gcSortRating:
						 listing = [communicator.listings.filteredListings objectAtIndex:[indexPath row]];
						 break;
					 case gcSortDist:
						 listing = [communicator.listings.filteredListings objectAtIndex:[indexPath row]];
						 break;
					 case gcSortHood:
						 listing = [[[communicator.listings.filteredNeighborhoods objectAtIndex:[indexPath section]] listings] objectAtIndex:[indexPath row]];
						 break;
				 }
				 
				 aCell.listingName.text = listing.name;
				 aCell.disclosureImageView.hidden = NO;

				 [aCell.star setImage:listing.stars];
				 
				 aCell.listingOneLiner.text = listing.one_liner;
				 NSString *aType = [listing.type capitalizedString];
				 
				 aCell.listingAddress.text = [NSString stringWithFormat:@"%@ - %@, %@, %@",aType, listing.street, 
											  listing.city, listing.state];
				 if (usesCurrentLocation) {
					 if ([listing.distance isEqualToString:@"10000"]) {
						 aCell.distance.text = @"";
						 aCell.listingAddress.frame = CGRectMake(16, 48, 280, 21);
					 } else {
						 double dist = [listing.distance doubleValue];
						 dist = dist * 0.00062137119;
						 NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
						 [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
						 [numberFormatter setMaximumFractionDigits:2];
						 aCell.distance.text = [NSString stringWithFormat:@"%@ mi", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:dist]]];
						 [numberFormatter release];
						 aCell.listingAddress.frame = CGRectMake(16, 48, 229, 21);
					 }
					 
					 
				 }
				 else {
					 aCell.distance.text = @"";
					 aCell.listingAddress.frame = CGRectMake(16, 48, 280, 21);
					 
				 }
				 
				 aCell.selectionStyle = UITableViewCellSelectionStyleBlue;
				 
			 }
			 
			 return aCell;
		 }
	 }
	 
	 else if (tableView == tagTable) {

		 GCGeneralTextCell *cell  = (GCGeneralTextCell *)[tableView dequeueReusableCellWithIdentifier:@"generalTextCell"];
		 if (cell == nil) {
			 NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCGeneralTextCell" owner:self options:nil];
			 cell = [[[nib objectAtIndex:0] retain] autorelease];
			 cell.cellLabel.font = [UIFont boldSystemFontOfSize:13];
		 }
		 if ([indexPath row]==0) {
			 cell.cellLabel.text = @"All";
			 if (allTagsSelected) {
				 cell.accessoryType = UITableViewCellAccessoryCheckmark;
			 }
			 else {
				 cell.accessoryType = UITableViewCellAccessoryNone;
			 }
		 }
		 else {
			 cell.cellLabel.text = [[communicator.listings.filteredTags objectAtIndex:([indexPath row]-1)] name];
			 if (allTagsSelected) {
				 cell.accessoryType = UITableViewCellAccessoryNone;
			 }
			 else if ([[communicator.listings.filteredTags objectAtIndex:([indexPath row]-1)] isEnabled]) {
				 cell.accessoryType = UITableViewCellAccessoryCheckmark;

			 } else {
				 cell.accessoryType = UITableViewCellAccessoryNone;

			 }
		 }

		 return cell; 

	 }

	

	return nil; 
	 
	
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView==listingTable) {

		
		return 76;
		
	}
	if (tableView==tagTable) {
		return 30;
	}
	
	return 69;
}







- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	
	if (tableView == listingTable) {
		if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[GCSingleButtonCell class]]) {
			return;
		}
		if ([[[[tableView cellForRowAtIndexPath:indexPath] listingOneLiner] text] isEqualToString: @"Please broaden your search"]) {
			[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
			return;
		}
		if ([communicator.listings.filteredListings count] == 0) {
			return;
		}
		GCListing *listing;
		int section = [indexPath section];
		switch (sortBy) {
			case gcSortName:
				if (section == 1) {
					return;
				}
				listing = [communicator.listings.filteredListings objectAtIndex:[indexPath row]];
				break;
			case gcSortRating:
				if (section == 1) {
					return;
				}
				listing = [communicator.listings.filteredListings objectAtIndex:[indexPath row]];
				break;
			case gcSortDist:
				if (section == 1) {
					return;
				}
				listing = [communicator.listings.filteredListings objectAtIndex:[indexPath row]];
				break;
			case gcSortHood: {
				int count = [communicator.listings.filteredNeighborhoods count];
				if (count == 0 && section == 1) {
					return;
				} else if (count == 0 && section == 0) {
					return;
				} else if (section == count) {
					return;
				}
				listing = [[[communicator.listings.filteredNeighborhoods objectAtIndex:section] listings] objectAtIndex:[indexPath row]];
				break;
			}
		}
		
		//[communicator loadDetailsForListing:listing];
		GCDetailViewController *dvc = [[GCDetailViewController alloc] init];
		//dvc.communicator = communicator;
		dvc.listing = listing;
		[self.navigationController pushViewController:dvc animated:YES];
		[dvc release];

		
	}
	else if (tableView == tagTable) {
		int row = [indexPath row];
		
		if (row == 0){
			allTagsSelected = !allTagsSelected;
			for (GCListingTag *tag in communicator.listings.filteredTags) {
				tag.isEnabled = !allTagsSelected;
			}
		}
		else {
			allTagsSelected = NO;
			[[communicator.listings.filteredTags objectAtIndex:row-1] setIsEnabled: ![[communicator.listings.filteredTags objectAtIndex:row-1] isEnabled]];
		}

		[tagTable reloadData];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark PICKER VIEW Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [communicator.listings.allFilteredHoods count] + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (row == 0) {
		return @"   All";
	} else {
		if ([[[communicator.listings.allFilteredHoods objectAtIndex:row - 1] name] isEqualToString:@"zzzOther"]) {
			return @"   Other"; //hack
		}
		return [NSString stringWithFormat:@"   %@",[[communicator.listings.allFilteredHoods objectAtIndex:row - 1] name]];
	}
	return @"   ";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (row == 0) {
		[communicator.listings setNewFilteredTags:communicator.listings.allFilteredListings];
	} else {
		[communicator.listings setNewFilteredTags:[[communicator.listings.allFilteredHoods objectAtIndex:row - 1] listings]];
	}
	neighborhoodSelectedIndex = row;
	allTagsSelected = YES;
	[tagTable reloadData];
}


#pragma mark Search Delegates

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	if (searchBar.showsCancelButton == NO) {
		if ([searchBar respondsToSelector:@selector(setShowsCancelButton:animated:)]) {
			[searchBar setShowsCancelButton:YES animated:YES];
		} else {
			searchBar.showsCancelButton = YES;
		}
	}

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if ([searchText length] > 0) {
		if (searchBar.showsCancelButton == NO) {
			if ([searchBar respondsToSelector:@selector(setShowsCancelButton:animated:)]) {
				[searchBar setShowsCancelButton:YES animated:YES];
			} else {
				searchBar.showsCancelButton = YES;
			}
		}
	} else {
		
		//[searchBar setShowsCancelButton:NO animated:YES];
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = @"";
	if ([searchBar respondsToSelector:@selector(setShowsCancelButton:animated:)]) {
		[searchBar setShowsCancelButton:NO animated:YES];
	} else {
		searchBar.showsCancelButton = NO;
	}
	int row = [neighborhoodPicker selectedRowInComponent:0];
	if (row == 0) {
		[communicator.listings setFilteredListingsKeepingTags:communicator.listings.allFilteredListings usingAllTags:allTagsSelected];
	} else {
		[communicator.listings setFilteredListingsKeepingTags:[[communicator.listings.allFilteredHoods objectAtIndex:row - 1] listings] usingAllTags:allTagsSelected];
	}
	[self reloadSegments];
	[listingTable reloadData];
	[searchBar resignFirstResponder];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	int row = [neighborhoodPicker selectedRowInComponent:0];
	if ([searchBar.text length] > 0) {
		if (searchBar.showsCancelButton == NO) {
			if ([searchBar respondsToSelector:@selector(setShowsCancelButton:animated:)]) {
				[searchBar setShowsCancelButton:YES animated:YES];
			} else {
				searchBar.showsCancelButton = YES;
			}
		}
		if (row == 0) {
			[communicator.listings filterListingsForKeyword:searchBar.text withListings:communicator.listings.allFilteredListings  usingAllTags:allTagsSelected];
		} else {
			[communicator.listings filterListingsForKeyword:searchBar.text withListings:[[communicator.listings.allFilteredHoods objectAtIndex:row - 1] listings]  usingAllTags:allTagsSelected];
		}
	} else {
		if ([searchBar respondsToSelector:@selector(setShowsCancelButton:animated:)]) {
			[searchBar setShowsCancelButton:NO animated:YES];
		} else {
			searchBar.showsCancelButton = NO;
		}
	}
	[self reloadSegments];
	[listingTable reloadData];
	[searchBar resignFirstResponder];

}

@end
