//
//  GCLocateFriendsFromContactsViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 5/1/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GCCommunicator;
#import "GCUserLogin.h"
@class GCFindFriendPerson;

@interface GCFindFriendsFromContactsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GCUserLoginDelegate> {
	NSMutableDictionary *contacts;
	UITableView *mainTable;
	id delegate;
	GCCommunicator *communicator;
	FriendActionEnum currentAction;
	GCFindFriendPerson *currentPerson;
}

@property (nonatomic, retain) NSMutableDictionary *contacts;
@property (nonatomic, retain) IBOutlet UITableView *mainTable;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, assign) GCFindFriendPerson *currentPerson;

- (id)initWithContacts:(NSMutableDictionary *)newContacts;



@end
