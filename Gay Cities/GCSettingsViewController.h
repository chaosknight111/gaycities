//
//  GCSettingsViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 3/27/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCUserLogin.h"
#import "IASKAppSettingsViewController.h"

@class GCCommunicator, GCConnectController;

@interface GCSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, GCUserLoginDelegate, IASKSettingsDelegate> {
  UITableView *settingsTable;
  GCCommunicator *_communicator;
  GCConnectController *_connectController;
  BOOL showingAction;
  IASKAppSettingsViewController *_appSettingsViewController;
  NSString *_saveUserName, *_savedPassword;
}

@property (nonatomic, retain) IBOutlet UITableView *settingsTable;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, assign) GCConnectController *connectController;
@property (nonatomic, readonly) BOOL twitterSaved, facebookSaved, foursquareSaved, isAuthenticatedToGC;
@property (nonatomic, readonly) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, copy) NSString *savedUserName, *savedPassword;

@end
