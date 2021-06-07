//
//  EventViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 6/1/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCCommunicator.h"
#import "ASIHTTPRequest.h"
#import "GCImageFlipper.h"

typedef enum GCEventTabSelected{
	detailTabSelected = 0,
	attendingTabSelected = 1,
} GCEventTabSelected;

@interface GCEventViewController : UIViewController <GCCommunicatorDelegate, GCUserLoginDelegate, GCImageFlipperDelegate> {
	NSMutableDictionary *event;
	IBOutlet UITableView *tableView;
	BOOL isAttending, showingUserProfile, finishedAddingToListingImageDownLoadQueue;
	UIImage *eventPhoto;
	GCCommunicator *communicator;
	UIButton *detailButton, *attendingButton, *attendingButtonSmall;
	GCEventTabSelected tabSelected;
	UILabel *eventTitleLabel, *eventDetailsLabel, *eventAttendingLabel;
	GCImageFlipper *imageFlipper;
	NSMutableArray *allEventsImages, *eventsImages, *imageRequests;
	NSOperationQueue *downloadQueue;
	int currentImage, requestCount, completeCount;
  UIImageView *eventImageView, *eventAttendingBadge, *eventImageMagGlass;
  UIActivityIndicatorView *eventPhotoActivity;
  
}

@property (nonatomic, retain) NSMutableDictionary *event;
@property (nonatomic, retain) UITableView *tableView;
@property (readwrite) BOOL isAttending;
@property (nonatomic, retain) UIImage *eventPhoto;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, retain) IBOutlet UIButton *detailButton, *attendingButton, *attendingButtonSmall;
@property (nonatomic, retain) IBOutlet UILabel *eventTitleLabel, *eventDetailsLabel, *eventAttendingLabel;
@property (nonatomic, retain) NSMutableArray *allEventsImages, *eventsImages, *imageRequests;
@property (nonatomic, retain) IBOutlet UIImageView *eventImageView, *eventAttendingBadge, *eventImageMagGlass;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *eventPhotoActivity;

- (IBAction)attendThisEvent:(id)sender;
- (void)openProfilePageForUser:(NSString *)username;
- (IBAction)switchViews:(id)sender;
- (IBAction)showLargeEventImage:(id)sender;

@end
