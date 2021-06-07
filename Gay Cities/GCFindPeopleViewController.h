//
//  GCFindPeopleViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 5/5/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GCCommunicator;
@class GayCitiesAppDelegate;
#import "GCUserLogin.h"

typedef enum GCFindFriendVCType {
	GCFindFriendVCTypeNewLogin = 1,
	GCFindFriendVCTypeStandard
} GCFindFriendVCType;

@interface GCFindPeopleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GCUserLoginDelegate> {
	GayCitiesAppDelegate *gcad;
	GCCommunicator *communicator;
	UITableView *actionTable;
	GCFindFriendVCType findFriendVCType;
}

@property (nonatomic, assign) GayCitiesAppDelegate *gcad;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, retain) IBOutlet UITableView *actionTable;
@property (readwrite) GCFindFriendVCType findFriendVCType;

- (id)initAfterSignIn;
- (void)searchWithContacts;
- (void)searchWithTwitter;
- (void)searchWithFacebook;
- (void)searchByName;
- (void)didSignInToFacebook:(BOOL)success;
- (IBAction)cancelAndReturn;

@end
