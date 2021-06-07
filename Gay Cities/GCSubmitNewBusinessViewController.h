//
//  SubmitNewBuisnessViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 2/5/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCSubmitNewBusinessViewControllerDelegate.h"
#import "GCMetro.h"
#import "GCAlertTableWithChoiceView.h"


typedef enum GCSubmitBusinessRows {
	GCSubmitListingType = 101, 
	GCSubmitBusinessName = 100,
	GCSubmitAddStreet = 103,
	GCSubmitAddCity = 104,
	GCSubmitAddState = 105,
	GCSubmitAddZip = 106,
	GCSubmitPhone = 102,
	GCSubmitURL = 107,
	GCSubmitNeighborhoodName = 108,
} GCSubmitBusinessRows;

@interface GCSubmitNewBusinessViewController : UIViewController <GCAlertTableWithChoiceViewDelegate> {
	NSString *listingType, *businessName, *add_street, *add_city, *add_state, *add_zip, *phone, *url, *neighborhood_id, *metroName;
	NSArray *listingTypes, *neighborhoodNames;
	NSObject<GCSubmitNewBusinessViewControllerDelegate> *gcDelegate;
	UITableView *mainTable;
	int typeChoosing;
	GCMetro *metro;
	NSMutableSet *cells;
	id previousSender, currentSender;
}

@property (nonatomic, retain) NSString *metroName, *listingType, *businessName, *add_street, *add_city, *add_state, *add_zip, *phone, *url, *neighborhood_id;
@property (nonatomic, retain) NSArray *listingTypes, *neighborhoodNames;
@property (nonatomic, assign) NSObject<GCSubmitNewBusinessViewControllerDelegate> *gcDelegate;
@property (nonatomic, retain) IBOutlet UITableView *mainTable;
@property (nonatomic, retain) GCMetro *metro;

- (IBAction)cancelSubmitBusiness;
- (IBAction)processSubmitBusiness;
- (void)showSubmitButton:(BOOL)shouldShow;
- (void)saveInformation:(id)sender;



@end
