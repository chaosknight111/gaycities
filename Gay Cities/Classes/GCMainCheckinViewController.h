//
//  GCMainCheckinViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 2/7/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCCommunicator.h"


@interface GCMainCheckinViewController : UIViewController <GCCommunicatorDelegate, GCUserLoginDelegate> {
	GCCommunicator *communicator;
	UITableView *mainTable;
	NSMutableArray *checkinListings;
	UIView *processingView;
	UIActivityIndicatorView *activityView, *refreshActivity;
	BOOL showingProfilePage, showAlertMessage, alertShown;
  BOOL arrowIsPointingDown, arrowIsRotating, isUpdatingListings, processingShown, showAllNearbyVisible;
  UILabel *refreshLabel;
}

@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, retain) IBOutlet UITableView *mainTable;
@property (nonatomic, retain) NSMutableArray *checkinListings;
@property (nonatomic, retain) IBOutlet UIView *processingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView, *refreshActivity;
@property (readwrite) BOOL showingProfilePage, showAllNearbyVisible;
@property (nonatomic, retain) IBOutlet UILabel *refreshLabel;

- (IBAction)showAllNearby;

- (void)openProfilePageForUser:(NSString *)username;
- (void)showProcessing;
- (void)hideProcessing;
- (void)showPeopleTab;
- (void)showProcessingInTable;
- (void)hideProcessingInTable;

@end
