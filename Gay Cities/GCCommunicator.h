//
//  GCCommunicator.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/30/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GCMetrosController.h"
#import "GCListingsController.h"
#import "GCMetro.h"
#import "GCUserLogin.h"
#import "GCCommunicatorDelegate.h"
#import "GCURLConnection.h"
#import "GCFoursquareController.h"

typedef enum {
  GCLocationSearchGlobal = 1,
  GCLocationSearchMapCoordinates = 2,
  GCLocationSearchCheckins = 3,
  GCLocationSearchNone = 4
} GCLocationSearchType;


@interface GCCommunicator : NSObject <CLLocationManagerDelegate, GCUserLoginDelegate, GCFoursquareControllerDelegate> {
	GCMetrosController *metros;
	GCListingsController *listings;
	BOOL noInternet, findBetterLocation, findBetterLocation2, isUpdatingLocation, metrosDownloaded, messagesRecieved, currentlyUpdatingListings;
	CLLocationCoordinate2D savedLocationCoordinate;
	CLLocation *currentLocation, *updatedLocation, *previousLocation;
	CLLocationManager *locationMgr;
	NSTimer	*timer;
	NSObject<GCCommunicatorDelegate> *delegate, *listingDelegate, *eventDelegate, *peopleDelegate, *checkinAndPopularDelegate;
	int myNearbyMetroID, year, today;
	GCUserLogin *ul;
	NSMutableArray *nearbyUpdates, *friendUpdates;
	NSMutableDictionary *connections, *listingConnections, *otherConnections, *peopleUpdateConnections, *peopleImages, *checkinConnections;
	NSOperationQueue *downloadQueue;
	NSDate *lastLocationUpdateTime;
  GCFoursquareController *foursquareController;
  NSArray *foursquareListings;
  GCLocationSearchType currentLocationSearch;
}

@property (nonatomic, retain) GCMetrosController *metros;
@property (nonatomic, retain) GCListingsController *listings;
@property (readwrite) CLLocationCoordinate2D savedLocationCoordinate;
@property (nonatomic, retain) CLLocationManager *locationMgr;
@property (readwrite) BOOL noInternet, isUpdatingLocation, messagesRecieved, metrosDownloaded, currentlyUpdatingListings;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, assign) NSObject<GCCommunicatorDelegate> *delegate, *listingDelegate, *eventDelegate, *peopleDelegate, *checkinAndPopularDelegate;
@property (readwrite) int currentMetroID, myNearbyMetroID, year, today;
@property (nonatomic, retain) GCUserLogin *ul;
@property (nonatomic, retain) NSMutableArray *nearbyUpdates, *friendUpdates;
@property (nonatomic, retain) NSMutableDictionary *connections, *listingConnections, *peopleUpdateConnections, *otherConnections, *peopleImages, *checkinConnections;
@property (nonatomic, retain) NSOperationQueue *downloadQueue;
@property (nonatomic, retain) CLLocation *currentLocation, *updatedLocation, *previousLocation;
@property (nonatomic, retain) NSDate *lastLocationUpdateTime;
@property (nonatomic, retain) GCFoursquareController *foursquareController;
@property (nonatomic, retain) NSArray *foursquareListings;

@property (nonatomic) GCLocationSearchType currentLocationSearch;

+ (GCCommunicator *)sharedCommunicator;

- (NSString*) md5Digest:(NSString*)str;
- (BOOL)isThereNoInternet;
- (float)distanceFromLocation:(double)lat lng:(double)lng;
- (void)findMe:(GCLocationSearchType)searchType;
- (void)updateListingsForLastLocation;
- (void)locateListingsForMetroID:(int)metro_id orLocation:(CLLocationCoordinate2D)myLocation;
- (void)locateMetros;
- (void)locateCity:(GCMetro *)newMetro;
- (void)calculateMetroDistance;
-(void)loadEventDetails:(NSString *)event_id processing:(BOOL)showProcessing;
//- (void)loadDetailsForListing:(GCListing *)listing;
//- (void)loadReviewsForListing:(GCListing *)listing;
- (void)updateListingPeople:(GCListing *)listing;
- (void)loadReviewsAndPeopleForListing:(GCListing *)listing;
- (void)getPeopleUpdates;
-(NSString *)getSearchString;
- (void)hideProcessing;
- (void)showProcessing:(NSString *)text;

- (void)cancelAllPendingRequests;
- (void)cancelListingRequests;
- (void)cancelCheckinListingRequests;
- (void)cancelPeopleUpdateRequests;
- (void)cancelOtherRequests;
- (BOOL)distanceFromLocationMetroCenter;

- (void)sendFailedRequestWithType:(GCRequestType)aType;
- (void)updateListingsForCurrentMetro;
- (void)showNoInternetAlertGeneric;

- (void)refreshCheckinsAndLocation;

- (void)updateFoursquareListings;

-(void)locateCheckinListingsForLocation:(CLLocationCoordinate2D)myLocation;
- (void)processCheckinData:(NSData *)receivedData;

@end
