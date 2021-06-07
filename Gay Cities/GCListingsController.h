//
//  OCBrowseListings.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/7/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

// This entire class needs to be refactored - it's soooooo ugly.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class OCFMDatabase;
#import "GCListingHood.h"
#import "GCMyList.h"
#import "GCListing.h"
@class GCEventsController;

extern int const sortAlphabetical;
extern int const sortNeighborhood;
extern int const sortRating;
extern int const sortDistance;


@interface GCListingsController : NSObject {
	NSMutableArray *listingTypes, *neighborhoods, *listings, *listingTags, *events, *popularListings, *closeByCheckinListings, *allCloseByCheckinListings, *allCloseByCheckinTypes;
	int sortValue;
	NSString *dbPath, *directoryPath;
	NSMutableArray *filteredNeighborhoods, *filteredListings, *filteredTags, *allFilteredListings, *allFilteredHoods;
	GCMyList *myList;
	BOOL bookmarksLoaded, closeByCheckinListingsLoaded, closeByCheckinListingsAreLoadingNow, cachedCheckinListingsLoaded;
  GCEventsController *eventsController;
  NSMutableSet *foursquareIds;
}

@property (readwrite) int sortValue;
@property (nonatomic, retain) NSMutableArray *listingTypes, *neighborhoods, *listings, *listingTags, *events, *popularListings, *closeByCheckinListings, *allCloseByCheckinListings, *allCloseByCheckinTypes;
@property (nonatomic, retain) NSString *dbPath, *directoryPath;
@property (nonatomic, retain) NSMutableArray *filteredNeighborhoods, *filteredListings, *filteredTags, *allFilteredListings, *allFilteredHoods;
@property (nonatomic, retain) GCMyList *myList;
@property (readwrite) BOOL bookmarksLoaded, closeByCheckinListingsLoaded, cachedCheckinListingsLoaded;
@property (nonatomic, retain) GCEventsController *eventsController;
@property (nonatomic, retain) NSMutableSet *foursquareIds;

- (id)initWithMetroID:(int)metroID lat:(double)aLat lng:(double)aLng;
- (BOOL)loadNewMetroID:(int)metroID;
-(void)setNewListings:(NSMutableDictionary *)dict forMetroID:(int)metroID lat:(double)aLat lng:(double)aLng addPopular:(BOOL)addPopular;
//-(void)setNewCheckInListings:(NSMutableDictionary *)dict lat:(double)aLat lng:(double)aLng;
-(void)loadCheckinListingsFromDatabaseKnowingCurrentMetroID:(NSString *)currentID;
- (void)loadBookmarks;

-(int)numberOfTypes;
-(int)numberOfListings;
-(int)numberOfNeighborhoods;
-(int)numberOfTags;

- (void)setFilteredListingsKeepingTags:(NSMutableArray *)newFilteredListings usingAllTags:(BOOL)usingAllTags;
- (void)filterListingsForFilteredTags;
- (void)setNewFilteredTags:(NSMutableArray *)someListings;
- (void)setNewFilteredHoods;
- (void)setAllFilteredListings:(NSMutableArray *)newFilteredListings withLocation:(CLLocation *)location;

-(void)sortFilteredListingsAlphabetical;
-(void)sortFilteredListingsRating;
-(void)sortFilteredListingsDistance;

//-(NSArray *)listingsForKeyword:(NSString *)searchString andType:(NSString *)type;
-(void)filterListingsForKeyword:(NSString *)searchString withListings:(NSMutableArray *)someListings usingAllTags:(BOOL)usingAllTags;

- (BOOL)loadListingDetails:(GCListing *)listing;
- (BOOL)loadListingReviews:(GCListing *)listing;
-(void)saveReviewsToDatabase:(GCListing *)listing;

- (void)updateCheckinListingsForNewLocation:(CLLocation *)location;
- (BOOL)copyDefaultListingDBToDocumentsWithPath:(NSString *)newDBPath;


@end
