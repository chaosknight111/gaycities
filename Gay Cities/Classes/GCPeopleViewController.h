//
//  GCPeopleViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/9/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCCommunicator.h"

typedef enum {
	nearbyTabSelected = 0,
	friendsTabSelected = 1,
	whosWhereTabSelected = 2
} tabSelectedPeopleEnum;

@interface GCPeopleViewController : UIViewController <GCCommunicatorDelegate, GCUserLoginDelegate> {
	GCCommunicator *communicator;
	UITableView *mainTable;
	UIButton *recentButton, *friendsButton, *whosWhereButton;
	int tabSelected;
	UIView *headerView;
	UIImageView *profileImageView, *refreshArrowImageView;
	UILabel *profileTextLabel, *refreshLabel;
	UIActivityIndicatorView *refreshActivity;
	BOOL arrowIsPointingDown, arrowIsRotating, isUpdatingPeople, processingShown, profileLoaded;
}

@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, retain) IBOutlet UITableView *mainTable;
@property (nonatomic, retain) IBOutlet UIButton *recentButton, *friendsButton, *whosWhereButton;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIImageView *profileImageView, *refreshArrowImageView;
@property (nonatomic, retain) IBOutlet UILabel *profileTextLabel, *refreshLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *refreshActivity;

- (IBAction)changeTable:(id)sender;
- (void)openProfilePageForUser:(NSString *)username;
- (IBAction)profileDetailsPressed;
- (IBAction)uploadProfilePicture;
- (void)updatePeopleNow;

- (void)showProcessing;
- (void)hideProcessing;
- (void)updateProfileDisplay:(NSNotification *)note;

@end
