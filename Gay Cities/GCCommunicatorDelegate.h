//
//  GCCommunicatorDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/30/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCCommunicator;

@protocol GCCommunicatorDelegate

@optional
//delegate methods (rootviewcontroller, myListController, BrowseListiController)
- (void)didUpdateListings;
- (void)didUpdateMetros;
- (void)didUpdateEvents;
- (void)didUpdateLocation;
- (void)didFinishLocationUpdates; // to stop the nearby spinner
- (void)didCancelLocationUpdates; // to stop the nearby spinner
- (void)didChangeCurrentMetro;
- (void)noInternetErrorLocation;
- (void)noInternetErrorListings;
- (void)didFailLoadListings;
- (void)locationError;

//event delegate methods  (just for eventViewController/eventsViewCOntroller)
- (void)didLoadEventDetails:(NSMutableDictionary *)event;
- (void)didFailLoadEventDetails;
- (void)didUpdateAttendees;
//reviewDelegate methods (just detailViewController
- (void)didUpdateReviews:(NSMutableArray *)listingReviews;
//listingPeopleDelegate methods (just detailViewController)
- (void)listingPeopleUpdated:(NSMutableDictionary *)listingPeople;
- (void)errorListingPeopleUpdate;
//reviews&people update error
- (void)errorListingPeopleReviewsUpdate;
//peopleDelegateMethods - (peopleViewController)
- (void)didRecievePeopleUpdates;
- (void)errorRecievingPeopleUpdates;
//listing photos
- (void)didRecieveListingPhoto:(NSArray *)listingPhotos;
//checkinandpopulardelegates
- (void)didRecieveCheckInUpdates;
- (void)errorRecievingCheckInUpdates;
//NewConnectionDelegates
- (void)didRecieveNewConnections;
- (void)errorRecievingNewConnections;
@end
