//
//  EventsViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 6/1/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCCommunicator.h"
@class GCCityChangeViewController, GayCitiesAppDelegate;
#import "GCCityViewControllerDelegate.h"
#import "GCEventsController.h"

@interface GCEventsViewController : UIViewController <GCCommunicatorDelegate, GCCityViewControllerDelegate> {
	IBOutlet UITableView *eventsTable;
	GCCommunicator *communicator;
  GCEventsController *eventsController;
  BOOL popularListShown;
  GayCitiesAppDelegate *gcad;
  UIView *processingView;
  UIActivityIndicatorView *activityView;
}

@property (nonatomic, retain) UITableView *eventsTable;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, retain) GCEventsController *eventsController;
@property (nonatomic, assign) GayCitiesAppDelegate *gcad;
@property (nonatomic, retain) IBOutlet UIView *processingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;


- (void)changeCityNow;
- (void)updateTableHeaderText;
- (void)showProcessing;
- (void)hideProcessing;


@end
