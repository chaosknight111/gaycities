//
//  GCListing.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/30/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCListingType.h"
#import "GCListingHood.h"

@interface GCListing : NSObject {
	NSString *city, *hood, *lat, *lng, *listing_id, *name, *one_liner, *rating, *state, *street, *type, *cross_street, *desc_editorial, *enhanced_listing, *former_names, *hours, *last_verified, *num_fans, *num_reviews, *phone, *photo_url, *website, *desc_mgmt, *username, *foursquareId;
	NSString *tags;
	NSArray *tagsArray;
	UIImage *stars;
	GCListingType *listingType;
	GCListingHood *listingHood;
	NSString *distance;
	NSMutableArray *reviews;
   
}

@property (nonatomic, copy) NSString *city, *hood, *lat, *lng, *listing_id, *name, *one_liner, *rating, *state, *street, *type, *cross_street, *desc_editorial, *enhanced_listing, *former_names, *hours, *last_verified, *num_fans, *num_reviews, *phone, *photo_url, *website,  *desc_mgmt, *username, *foursquareId;
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, retain) UIImage *stars;
@property (nonatomic, copy) NSArray *tagsArray;
@property (nonatomic, assign) GCListingType *listingType;
@property (nonatomic, assign) GCListingHood *listingHood;
@property (nonatomic, retain) NSString *distance;
@property (nonatomic, retain) NSMutableArray *reviews;

@end
