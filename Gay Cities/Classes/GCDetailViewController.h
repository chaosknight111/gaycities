//
//  OCDetailViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/14/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OCWebViewController;
@class OCMapViewController;
@class BAUIStarSlider;
#import "GCCommunicator.h"
#import "GCListing.h"
#import "ASIHTTPRequest.h"
#import "GCImageFlipper.h"

typedef enum {
	ratingSection = -1,
	buttonSection = 0,
	phoneSection = 1,
	addressSection = 2,
	detailsSection = 3,
	webSection = 4,
	descMgmtSection = 5,
	errorSection = 6,
	verifiedSection = 7,
} GCDetailSectionIndex;

typedef enum {
	detailTabSelected = 0,
	reviewsTabSelected = 1,
	checkinTabSelected = 2,
} GCDetailTabSelected;

@interface GCDetailViewController : UIViewController <GCCommunicatorDelegate, GCUserLoginDelegate, GCImageFlipperDelegate> {
	UIView *noInternetView;
	UITableView *detailTable;
	BOOL isBookmarked;
	NSString *savePath;
	BOOL isReviewed, isFan, finishedAddingToListingImageDownLoadQueue, reviewsLoadedWithZero, noReviewAlertShown, requestSubmitDone;
	BAUIStarSlider *starSlider;
	NSDictionary *userStatus;
	GCCommunicator *communicator;
	GCListing *listing;
	NSMutableString *extraDetails;
	UIButton *detailButton, *reviewsButton, *peopleButton, *noImageButton;
	UILabel *nameLabel, *oneLinerLabel;
	UIImageView *listingImage, *starsImage;
	NSMutableDictionary *peopleDictionary;
	float listingDistance;
	GCDetailTabSelected tabSelected;
	UIView *tableHeaderView;
	UIActivityIndicatorView *activityView;
	NSMutableArray *allListingImages, *listingImages, *imageRequests;
	NSOperationQueue *downloadQueue;
	int currentImage, requestCount, completeCount;
	GCImageFlipper *imageFlipper;
}

@property (nonatomic, retain) IBOutlet UIView *noInternetView;
@property (nonatomic, retain) IBOutlet UITableView *detailTable;
@property (nonatomic, retain) NSDictionary *userStatus;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, retain) GCListing *listing;
@property (nonatomic, retain) NSMutableString *extraDetails;
@property (nonatomic, retain) IBOutlet UIButton *detailButton, *reviewsButton, *peopleButton, *noImageButton;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel, *oneLinerLabel;
@property (nonatomic, retain) IBOutlet UIImageView *listingImage, *starsImage;
@property (nonatomic, retain) NSMutableDictionary *peopleDictionary;
@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableArray *listingImages, *allListingImages, *imageRequests;

- (IBAction)switchViews:(id)sender;
- (void)setBookmarks;
- (void)call;
//- (void)replaceReviewImages:(NSArray *)newReviews;
- (void)checkListingStatus;
- (IBAction)submitPictureAction;
-(void)submitReview;
- (void)checkInHere;
//- (void)setNewPeopleImages:(NSDictionary *)people;
- (void)openProfilePageForUser:(NSString *)username;


@end
