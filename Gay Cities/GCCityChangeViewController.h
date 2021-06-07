//
//  OCCityViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/28/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCMetro.h"
#import "GCCityViewControllerDelegate.h"

@class GCMetrosController;

typedef enum GCCitySelectorCurrentTab {
  GCCitySelectorCurrentTabAll,
  GCCitySelectorCurrentTabRecent
} GCCitySelectorCurrentTab;


@interface GCCityChangeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSObject<GCCityViewControllerDelegate> *delegate;
	UIButton *nearbyButton, *cancelButton, *allButton, *recentButton;
	UILabel *instructionLabel;
	NSString *instructionText;
	int viewType;
	UISearchBar *citySearchBar;
	BOOL isSearching;
	NSMutableArray *searchResults;
	UITableView *mainTable;
	NSString *previousSearchText;
  GCCitySelectorCurrentTab currentTab;
}

@property (nonatomic, readonly) GCMetrosController *metros;
@property (nonatomic, assign) NSObject<GCCityViewControllerDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UIButton *nearbyButton, *cancelButton, *allButton, *recentButton;
@property (nonatomic, retain) IBOutlet UILabel *instructionLabel;
@property (readwrite) int viewType;
@property (nonatomic, retain) NSString *instructionText;
@property (nonatomic, retain) IBOutlet UISearchBar *citySearchBar;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) IBOutlet UITableView *mainTable;
@property (nonatomic, retain) NSString *previousSearchText;
@property (nonatomic) GCCitySelectorCurrentTab currentTab;


- (IBAction)cityViewDidCancel;
- (IBAction)cityViewDidSelectNearby;
- (IBAction)toggleCurrentCities:(id)sender;

@end
