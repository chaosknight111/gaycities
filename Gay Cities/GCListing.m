//
//  GCListing.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/30/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCListing.h"


@implementation GCListing

@synthesize stars, city, hood, lat, lng, listing_id, name, one_liner, rating, state, street, tags, type, cross_street, desc_editorial, enhanced_listing, former_names, hours, last_verified, num_fans, num_reviews, phone, photo_url, website, desc_mgmt, username;
@synthesize listingType;
@synthesize tagsArray;
@synthesize listingHood;
@synthesize distance;
@synthesize reviews;
@synthesize foursquareId;

- (id)init {
	self = [super init];
	
	stars = [[UIImage alloc] init];
	city = [[NSString alloc] init];
	hood = [[NSString alloc] init];
	lat = [[NSString alloc] init];
	lng = [[NSString alloc] init];
	listing_id = [[NSString alloc] init];
	name = [[NSString alloc] init];
	one_liner = [[NSString alloc] init];
	rating = [[NSString alloc] init];
	state = [[NSString alloc] init];
	street = [[NSString alloc] init];
	tags = [[NSString alloc] init];
	type = [[NSString alloc] init];
	cross_street = [[NSString alloc] init];
	desc_editorial = [[NSString alloc] init];
	enhanced_listing = [[NSString alloc] init];
	former_names = [[NSString alloc] init];
	hours = [[NSString alloc] init];
	last_verified = [[NSString alloc] init];
	num_fans = [[NSString alloc] init];
	num_reviews = [[NSString alloc] init];
	phone = [[NSString alloc] init];
	photo_url = [[NSString alloc] init];
	website = [[NSString alloc] init];
	desc_mgmt = [[NSString alloc] init];
	username = [[NSString alloc] init];
	tagsArray = [[NSArray alloc] init];
	distance = [[NSString alloc] initWithString:@"-1"];
	reviews = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
  [foursquareId release];
	self.stars = nil;
	self.city = nil;
	self.hood = nil;
	self.lat = nil;
	self.lng = nil;
	self.listing_id = nil;
	self.name = nil;
	self.one_liner = nil;
	self.rating = nil;
	self.state = nil;
	self.street = nil;
	self.tags = nil;
	self.cross_street = nil;
	self.desc_editorial = nil;
	self.enhanced_listing = nil;
	self.former_names = nil;
	self.hours = nil;
	self.last_verified = nil;
	self.num_fans = nil;
	self.num_reviews = nil;
	self.phone = nil;
	self.photo_url = nil;
	self.website = nil;
	self.type = nil;
	self.tagsArray = nil;
	self.reviews = nil;
	self.desc_mgmt = nil;
	self.username = nil;
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"name:%@, distance:%@, lat:%@, lng%@", self.name, self.distance, self.lat, self.lng];
}

@end
