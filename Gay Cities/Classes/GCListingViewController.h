//
//  OCBrowseListController.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/10/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GCCommunicator.h"
#import "GCListingType.h"
#import "GCMetro.h"

typedef enum {
	gcSortName = 0,
	gcSortRating,
	gcSortDist,
	gcSortHood
} GCListingsSortValues;

@interface GCListingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	 UIView *filterView, *headerView;
	 UITableView *listingTable, *tagTable;
	 UILabel *headerLabel, *filterLabel;
	UISegmentedControl *browseSortControl; //, *filterButton;
	 UIPickerView *neighborhoodPicker;
	UISearchBar *filterSearchBar;
	UIButton *filterButton;
	GCCommunicator *communicator;
	GCListingType *listingType;
	BOOL isAllListings, usesCurrentLocation, allTagsSelected, isLoading, isReloadingSegments, useCheckInListings;
	int neighborhoodSelectedIndex;
	GCListingsSortValues sortBy;
	GCMetro *currentMetro;
}

@property (nonatomic, retain) IBOutlet UIView *filterView, *headerView;
@property (nonatomic, retain) IBOutlet UITableView *listingTable, *tagTable;
@property (nonatomic, retain) IBOutlet UILabel *headerLabel, *filterLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *browseSortControl; //, *filterButton;
@property (nonatomic, retain) IBOutlet UIButton *filterButton;
@property (nonatomic, retain) IBOutlet UIPickerView *neighborhoodPicker;
@property (nonatomic, retain) IBOutlet UISearchBar *filterSearchBar;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, assign) GCListingType *listingType;
@property (readwrite) BOOL useCheckInListings;
@property (nonatomic, retain) GCMetro *currentMetro;



-(IBAction)closeNeighborhoodPicker:(id)sender;
-(IBAction)closeTagPicker:(id)sender;

- (void)reloadSegments;
- (IBAction)changeSort:(id)sender;
- (IBAction)filterListings;
- (IBAction)closeFilterListings;


@end
