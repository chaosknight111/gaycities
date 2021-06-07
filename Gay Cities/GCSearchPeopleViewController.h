//
//  GCSearchPeopleViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 6/8/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GCCommunicator;
#import "GCUserLogin.h"
@class GCFindFriendPerson;

typedef enum FriendSearchType
{
	findFriendsPhone = 1,
	findFriendsName,
	findFriendsEmail,
	findFriendsTwitter,
	findFriendsFacebook
} FriendSearchType;


@interface GCSearchPeopleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, GCUserLoginDelegate> {
	FriendSearchType searchType;
	UITableView *mainTable;
	UISearchBar *mainSearchBar;
	NSMutableDictionary *contacts;
	GCCommunicator *communicator;
	FriendActionEnum currentAction;
	GCFindFriendPerson *currentPerson;
}

@property (readwrite) FriendSearchType searchType;
@property (nonatomic, retain) IBOutlet UITableView *mainTable;
@property (nonatomic, retain) IBOutlet UISearchBar *mainSearchBar;
@property (nonatomic, retain) NSMutableDictionary *contacts;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, assign) GCFindFriendPerson *currentPerson;

- (id)initWithSearchType:(FriendSearchType)type;

@end
