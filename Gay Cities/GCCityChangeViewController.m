//
//  OCCityViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/28/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCCityChangeViewController.h"
#import "OCConstants.h"
#import "GCGeneralTextCell.h"
#import "GCCommunicator.h"
#import "GCMetrosController.h"

@implementation GCCityChangeViewController

@synthesize delegate;
@synthesize nearbyButton, cancelButton;
@synthesize instructionLabel;
@synthesize viewType;
@synthesize instructionText;
@synthesize citySearchBar;
@synthesize searchResults;
@synthesize mainTable;
@synthesize previousSearchText;
@synthesize allButton, recentButton;
@synthesize currentTab;


- (id)init
{
	self = [super init];
	instructionText = [[NSString alloc] init];

	return self;
}

- (GCMetrosController *)metros {
  return [[GCCommunicator sharedCommunicator] metros];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  currentTab = GCCitySelectorCurrentTabAll;
	searchResults = [[NSMutableArray alloc] init];
	isSearching = NO;
  self.navigationController.navigationBar.hidden = YES;
	allButton.selected = YES;
  recentButton.selected = NO;
}



- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
	mainTable.tableHeaderView = citySearchBar;
	if (viewType == requiredSelectionViewType) {
		nearbyButton.hidden = YES;
		cancelButton.hidden = YES;
		instructionLabel.hidden = NO;
		instructionLabel.text = instructionText;
	} else if (viewType == optionalSelectionViewType) {
		nearbyButton.hidden = NO;
		cancelButton.hidden = NO;
		instructionLabel.hidden = YES;
		instructionLabel.text = @"";
	}
  [mainTable reloadData];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
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


- (IBAction)toggleCurrentCities:(id)sender {
  if (sender == allButton) {
    currentTab = GCCitySelectorCurrentTabAll;
    mainTable.tableHeaderView = citySearchBar;
    allButton.selected = YES;
    recentButton.selected = NO;
  } else {
    currentTab = GCCitySelectorCurrentTabRecent;
    mainTable.tableHeaderView = nil;
    allButton.selected = NO;
    recentButton.selected = YES;
    
  }
  [mainTable reloadData];
}






- (IBAction)cityViewDidCancel
{
	if ([delegate respondsToSelector:@selector(cityViewDidCancel)]) {
		[delegate cityViewDidCancel];
	} else {
		NSLog(@"Delegate does not respond to cancel");
	}

	
}


- (IBAction)cityViewDidSelectNearby
{
	if ([delegate respondsToSelector:@selector(cityViewDidSelectNearby)]) {
		[delegate cityViewDidSelectNearby];
	} else {
		NSLog(@"Delegate does not respond to nearby");
	}
	
	
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (currentTab == GCCitySelectorCurrentTabRecent) {
    return 1;
  } else if (isSearching) {
		if ([searchResults count] == 0) {
			return 1;
		}
		return [searchResults count];
	}
    
  return [self.metros numberOfStates];

	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (currentTab == GCCitySelectorCurrentTabRecent) {
    return [self.metros.recents count];
  } else if (isSearching) {
		if ([searchResults count] == 0) {
			return 0;
		}
		return [[[searchResults objectAtIndex:section] objectForKey:@"metros"] count];
	}
	if (self.metros)
		return [self.metros numberOfCitiesInState:section];
	
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (currentTab == GCCitySelectorCurrentTabRecent) {
    return nil;
  } else if (isSearching) {
		if ([searchResults count] == 0) {
			return @"";
		}
		return [[searchResults objectAtIndex:section] objectForKey:@"name"];
	}
	if (self.metros)
		return [[self.metros.metros objectAtIndex:section] objectForKey:@"name"];
	
	return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	GCGeneralTextCell *cell  = (GCGeneralTextCell *)[tableView dequeueReusableCellWithIdentifier:@"generalTextCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCGeneralTextCell" owner:self options:nil];
		cell = [[[nib objectAtIndex:0] retain] autorelease];
	}
  if (currentTab == GCCitySelectorCurrentTabRecent) {
    GCMetro *metro = [self.metros.recents objectAtIndex:[indexPath row]];
		cell.cellLabel.text = [NSString stringWithFormat:@"%@, %@", metro.metro_name, metro.metro_state];

  } else if (isSearching) {
		if ([searchResults count] == 0) {
			cell.cellLabel.text = @"";
		} else {
			cell.cellLabel.text = [[[[searchResults objectAtIndex:[indexPath section]] objectForKey:@"metros"] objectAtIndex:[indexPath row]] metro_name];
		}
		
	} else {
		cell.cellLabel.text = [[[self.metros citiesForStateIndex:[indexPath section]] objectAtIndex:[indexPath row]] metro_name];
	}
	
	
    return cell;
}

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	
}
*/


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (currentTab == GCCitySelectorCurrentTabRecent) {
    GCMetro *metro = [self.metros.recents objectAtIndex:[indexPath row]];
    self.metros.currentMetro = metro;
  } else if (isSearching) {
    GCMetro *metro = [[[searchResults objectAtIndex:[indexPath section]] objectForKey:@"metros"] objectAtIndex:[indexPath row]];
		self.metros.currentMetro = metro;
    [self.metros addRecent:metro];
    
	} else {
    GCMetro *metro = [[self.metros citiesForStateIndex:[indexPath section]] objectAtIndex:[indexPath row]];
		self.metros.currentMetro = metro;
    [self.metros addRecent:metro];

	}
	
	
	
	if ([delegate respondsToSelector:@selector(cityViewDidSelectMetro:)]) {
		[delegate cityViewDidSelectMetro:self.metros.currentMetro];
	} else {
		NSLog(@"Delegate does not respond to didselectMetroID");
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
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


- (void)dealloc {
	delegate = nil;
	self.nearbyButton = nil;
	self.cancelButton = nil;
	self.instructionLabel = nil;
	self.instructionText = nil;
	self.citySearchBar = nil;
	self.searchResults = nil;
	self.mainTable = nil;
	self.previousSearchText = nil;
  self.allButton = nil;
  self.recentButton = nil;
    [super dealloc];
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
	if ([searchBar.text length] == 0) {
		[searchResults setArray:self.metros.metros];
	}
	self.previousSearchText = searchBar.text;
	mainTable.frame = CGRectMake(0, 66, 320, 178);
	isSearching = YES;
	[mainTable reloadData];
	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	mainTable.frame = CGRectMake(0, 94, 320, 366);
	[searchBar resignFirstResponder];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	//[mainTable reloadData];
	if ([searchText length] == 0) {
		[searchResults setArray:self.metros.metros];
		[mainTable reloadData];
		self.previousSearchText = searchText;
		return;
	} else if ([previousSearchText length] > [searchText length]) {
		[searchResults setArray:self.metros.metros];
		[mainTable reloadData];
	}
	self.previousSearchText = searchText;
	NSArray *keywords = [searchText componentsSeparatedByString:@" "];
	NSMutableArray *tempSearchResults = [[NSMutableArray alloc] init];
	for (NSMutableDictionary *state in searchResults) {
		NSMutableSet *tempSet = [[NSMutableSet alloc] init];
		for (GCMetro *metro in [state objectForKey:@"metros"]) {
			for (NSString *word in keywords) {
				if ([word length] > 0) {
					NSRange rr = [metro.metro_name rangeOfString:word options:NSCaseInsensitiveSearch];
					if (rr.length > 0) {
						[tempSet addObject:metro];
					} else {
						rr = [metro.metro_state rangeOfString:word options:NSCaseInsensitiveSearch];
						if (rr.length > 0) {
							[tempSet addObject:metro];
						} else {
							rr = [metro.metro_country rangeOfString:word options:NSCaseInsensitiveSearch];
							if (rr.length > 0) {
								[tempSet addObject:metro];
							} else {
								[tempSet removeObject:metro];
								break;
							}
						}
					}
				}
			}
		}
		if ([tempSet count] > 0) {
			NSSortDescriptor *metroName = [[NSSortDescriptor alloc]
										   initWithKey:@"metro_name"
										   ascending:YES
										   selector:@selector(caseInsensitiveCompare:)];
			NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:metroName, nil];
			NSArray *cities = [[tempSet allObjects] sortedArrayUsingDescriptors:sortDescriptors];
			[metroName release];
			[sortDescriptors release];
			NSDictionary *aState = [[NSDictionary alloc] initWithObjectsAndKeys:[state objectForKey:@"name"], @"name", cities, @"metros", nil];
			[tempSearchResults addObject:aState];
			[aState release];
			
		}
		[tempSet release];
	}
	[searchResults setArray:tempSearchResults];
	[tempSearchResults release];
	[mainTable reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = @"";
	if ([searchBar respondsToSelector:@selector(setShowsCancelButton:animated:)]) {
		[searchBar setShowsCancelButton:NO animated:YES];
	} else {
		searchBar.showsCancelButton = NO;
	}
	
	[searchBar resignFirstResponder];
	mainTable.frame = CGRectMake(0, 94, 320, 366);
	isSearching = NO;
	[searchResults removeAllObjects];
	[mainTable reloadData];

	
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	
	[searchBar resignFirstResponder];
	mainTable.frame = CGRectMake(0, 94, 320, 366);
	[mainTable reloadData];

	
}


@end

