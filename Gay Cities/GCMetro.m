//
//  GCMetro.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/3/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCMetro.h"


@implementation GCMetro

@synthesize metro_country, metro_id, metro_lat, metro_lng, metro_name, metro_state;
@synthesize metroLocation;

- (id)init 
{
	self = [super init];
	
	metro_country = [[NSString alloc] init];
	metro_id = [[NSString alloc] init];
	metro_lat = [[NSString alloc] init];
	metro_lng = [[NSString alloc] init];
	metro_name = [[NSString alloc] init];
	metro_state = [[NSString alloc] init];
	
	return self;
}

- (id)initWithCountry:(NSString *)new_metro_country ID:(NSString *)new_metro_id lat:(NSString *)new_metro_lat lng:(NSString *)new_metro_lng name:(NSString *)new_metro_name state:(NSString *)new_metro_state
{
	self = [super init];
	
	self.metro_country = new_metro_country;
	self.metro_id = new_metro_id;
	self.metro_lat = new_metro_lat;
	self.metro_lng = new_metro_lng;
	self.metro_name = new_metro_name;
	self.metro_state = new_metro_state;
	
	metroLocation.latitude = [metro_lat doubleValue];
	metroLocation.longitude = [metro_lng doubleValue];
	
	return self;
}


- (void)dealloc
{
	self.metro_country = nil;
	self.metro_id = nil;
	self.metro_lat = nil;
	self.metro_lng = nil;
	self.metro_name = nil;
	self.metro_state = nil;
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@, %@, %@", metro_name, metro_state, metro_country];
}

@end
