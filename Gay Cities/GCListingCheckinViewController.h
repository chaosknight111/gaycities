//
//  GCListingCheckinViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/15/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTwitterEngine.h"
#import "GCCommunicator.h"
#import "GCLoginViewConroller.h"
#import "GCMainCheckinViewController.h"
@class GayCitiesAppDelegate;
#import "GCConnectController.h"

typedef enum GCCheckinType {
  GCCheckinTypeListing,
  GCCheckinTypeEvent
} GCCheckinType;

@interface GCListingCheckinViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, GCUserLoginDelegate, UIAlertViewDelegate, GCConnectControllerDelegate> {
	UITextView *shoutTextView;
	BOOL isClosing;
	GCCommunicator *communicator;
	UILabel *listingNameLabel;
	NSString *shoutText, *urlToSend;
	GCListing *listing;
  NSDictionary *event;
	UIActionSheet *logoutSheet;
	NSMutableArray *tweetsToSend, *fbToSend;
	GCMainCheckinViewController *mainCheckinViewController;
	GayCitiesAppDelegate *gcad;
  GCCheckinType checkinType;
  NSString *placeHolderText;
  UIButton *facebookButton, *twitterButton, *foursquareButton;
}

@property (nonatomic, retain) IBOutlet UITextView *shoutTextView;
@property (nonatomic, retain) IBOutlet UILabel *listingNameLabel;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, retain) GCListing *listing;
@property (nonatomic, copy) NSString *shoutText, *urlToSend;
@property (nonatomic, retain) NSMutableArray *tweetsToSend, *fbToSend;
@property (nonatomic, assign) GCMainCheckinViewController *mainCheckinViewController;
@property (nonatomic, assign) GayCitiesAppDelegate *gcad;
@property (nonatomic, retain) NSDictionary *event;
@property (nonatomic) GCCheckinType checkinType;
@property (nonatomic, retain) NSString *placeHolderText;
@property (nonatomic, retain) IBOutlet UIButton *facebookButton, *twitterButton, *foursquareButton;
@property (nonatomic, retain) IBOutlet UIImageView *bgImageView;

- (IBAction)closeMe;
- (IBAction)checkinNow:(id)sender;
- (IBAction)changeFacebookStatus:(id)sender;
- (IBAction)changeTwitterStatus:(id)sender;
- (IBAction)changeFoursquareStatus:(id)sender;
- (IBAction)cancelAndClose;

- (void)sendFBUpdate;
- (void)sendFoursquareUpdate;

@end
