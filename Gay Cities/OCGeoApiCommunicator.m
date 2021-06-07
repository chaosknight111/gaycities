//
//  OCGeoApiCommunicator.m
//  BreadcrumbTrail-iPad
//
//  Created by Brian Harmann on 4/11/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import "OCGeoApiCommunicator.h"
#import "GAParent.h"
#import "GAPlace.h"
#import <CoreLocation/CoreLocation.h>
#import "GCCommunicator.h"
#import "JSON.h"

@implementation OCGeoApiCommunicator

@synthesize delegate;
@synthesize verticals;

- (id)init
{
	if (self = [super init]) {
		connectionManager = [[GAConnectionManager alloc] initWithAPIKey:@"vZWZZJhtfw" 
																delegate:self];
		self.delegate = nil;
		verticals = [[NSArray alloc] initWithObjects:@"arts-entertainment-and-nightlife", @"banks", @"event-and-party-planning", @"food-and-drink", @"kids-and-child-care", @"local-gems", @"media-companies", @"pets", @"public-and-social-services", @"university-housing", @"religious-and-spiritual", @"restaurants", @"shopping", @"sports-the-outdoors-and-recreation", @"tourist-center", nil];
	}
	
	return self;
}

- (id)initWithDelegate:(id)newDelegate
{
	if (self = [super init]) {
		connectionManager = [[GAConnectionManager alloc] initWithAPIKey:@"vZWZZJhtfw" 
															   delegate:self];
		verticals = [[NSArray alloc] initWithObjects:@"arts-entertainment-and-nightlife", @"banks", @"event-and-party-planning", @"food-and-drink", @"kids-and-child-care", @"local-gems", @"media-companies", @"pets", @"public-and-social-services", @"university-housing", @"religious-and-spiritual", @"restaurants", @"shopping", @"sports-the-outdoors-and-recreation", @"tourist-center", nil];
		self.delegate = newDelegate;
	}
	
	return self;
}

- (void)requestBusinessesNear:(double)lat lng:(double)lng
{
	CLLocationCoordinate2D coords;
	coords.latitude = lat;
	coords.longitude = lng;
	//[connectionManager requestBusinessesNearCoords:coords withinRadius:50 maxResults:20];
	
	NSMutableDictionary *entityDict =
	[[[NSMutableDictionary alloc] init] autorelease];
	[entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:@"business" forKey:@"type"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:@"1" forKey:@"pretty"];
	//[entityDict setValue:[NSNull null] forKey:@"geom"];
	NSMutableDictionary *listingDict =
	[[[NSMutableDictionary alloc] init] autorelease];
	[listingDict setValue:[NSNull null] forKey:@"name"];
	//[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"address"];
	//[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	//[listingDict setValue:[NSNull null] forKey:@"hours"];
	[listingDict setValue:[NSNull null] forKey:@"verticals"];
	
	[entityDict setValue:listingDict forKey:@"view.listing"];
	
	requestType = kGeoNearLocSearch;
	[connectionManager requestPlacesNearCoords:coords
								  withinRadius:600
									maxResults:50
								withEntityDict:entityDict];
	
	
}

- (void)requestBusiness:(NSString *)name near:(double)lat lng:(double)lng
{
	CLLocationCoordinate2D coords;
	coords.latitude = lat;
	coords.longitude = lng;
	//[connectionManager requestBusinessesNearCoords:coords withinRadius:50 maxResults:20];
	
	NSMutableDictionary *entityDict =
	[[[NSMutableDictionary alloc] init] autorelease];
	[entityDict setValue:[NSNull null] forKey:@"guid"];
	[entityDict setValue:@"business" forKey:@"type"];
	[entityDict setValue:[NSNull null] forKey:@"geom"];
	[entityDict setValue:@"1" forKey:@"pretty"];
	NSMutableDictionary *listingDict =
	[[[NSMutableDictionary alloc] init] autorelease];
	[listingDict setValue:name forKey:@"name"];
	//[listingDict setValue:[NSNull null] forKey:@"phone"];
	[listingDict setValue:[NSNull null] forKey:@"address"];
	//[listingDict setValue:[NSNull null] forKey:@"listing-url"];
	//[listingDict setValue:[NSNull null] forKey:@"hours"];
	[listingDict setValue:[NSNull null] forKey:@"verticals"];
	[entityDict setValue:listingDict forKey:@"view.listing"];
	
	requestType = kGeoNameSearch;
	[connectionManager requestPlacesNearCoords:coords
								  withinRadius:600
									maxResults:50
								withEntityDict:entityDict]; 
}


- (void)receivedResponseString:(NSString *)responseString {
	//NSLog(@"GEO Received response: %@", responseString);
	NSDictionary *dict = [responseString JSONValueWithStrings];
	//NSLog(@"\nGEO Received JSON Dictionary: %@\n\n", dict);

	if (dict) {
		//NSLog(@"GEO Received response: %@", responseString);

		NSArray *places = [dict objectForKey:@"entity"];
		if (places) {
			if ([places count] > 0) {
				
				if (delegate) {
					if (requestType == kGeoNearLocSearch) {
						if ([delegate respondsToSelector:@selector(recievedNearbyGeoResults:)]) {
							//[NSThread detachNewThreadSelector:@selector(recievedNearbyGeoResults:) toTarget:(GCCommunicator *)delegate withObject:[[places retain] autorelease]];
							return;
						}
					} else if (requestType == kGeoNameSearch) {
						if ([delegate respondsToSelector:@selector(recievedKeywordGeoResults:)]) {
							//[(GCCommunicator *)delegate recievedKeywordGeoResults:[[places retain] autorelease]];
							return;
						}
					}
				}
			}
			 
		}
	}

	if (delegate) {
		//NSLog(@"GEO Received response (error): %@", responseString);

		if ([delegate respondsToSelector:@selector(errorGeoResults)]) {
			//[(GCCommunicator *)delegate errorGeoResults];
		}
	}
}

- (void)requestFailed:(NSError *)error {
	NSLog(@"GeoApi Request Failed: %@", [error localizedDescription]);
	if (delegate) {
		if ([delegate respondsToSelector:@selector(errorGeoResults)]) {
			//[(GCCommunicator *)delegate errorGeoResults];
		}
	}
}


- (void)dealloc {
	[connectionManager release];
	self.verticals = nil;
	[super dealloc];
}

@end
