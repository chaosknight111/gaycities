//
//  GCFoursquareController.h
//  Gay Cities
//
//  Created by Brian on 3/9/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GCFoursquareControllerDelegate

- (void)didFetchFoursquareListings:(NSArray *)newListings;

@end

@interface GCFoursquareController : NSObject {
  NSArray *listings;
  NSObject<GCFoursquareControllerDelegate> *delegate;
}

@property (nonatomic, retain) NSArray *listings;
@property (nonatomic, readonly) NSString *foursquareToken;
@property (nonatomic, retain) NSObject<GCFoursquareControllerDelegate> *delegate;

- (void)fetchListingsForLat:(NSString *)lat lng:(NSString *)lng;

@end
