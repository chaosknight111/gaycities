//
//  BrowseViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/28/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCCityChangeViewController.h"
#import "GCCommunicator.h"

@interface GCBrowseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GCCityViewControllerDelegate, GCCommunicatorDelegate> {
	UITableView *browseTableView;
	GCCommunicator *communicator;
}

@property (nonatomic, retain) IBOutlet UITableView *browseTableView;
@property (nonatomic, assign) GCCommunicator *communicator;

@end
