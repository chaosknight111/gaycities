//
//  MyListViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/28/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCCommunicator.h"

@interface GCMyListViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource> {
	UITableView *mainTableView;
	GCMyList *myList;
	GCCommunicator *communicator;
}

@property (nonatomic, retain) IBOutlet UITableView *mainTableView;
@property (nonatomic, assign) GCMyList *myList;
@property (nonatomic, assign) GCCommunicator *communicator;

@end
