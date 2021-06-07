//
//  GCFoursquareController.m
//  Gay Cities
//
//  Created by Brian on 3/9/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "GCFoursquareController.h"
#import "ASIHTTPRequest.h"
#import "GCCommunicator.h"



@implementation GCFoursquareController

@synthesize listings;
@synthesize delegate;



- (NSString *)foursquareToken {
  return [[NSUserDefaults standardUserDefaults] stringForKey:gcFoursquareTokenKey];
}

- (void)fetchListingsForLat:(NSString *)lat lng:(NSString *)lng {
  if ([lat intValue] == 0 || [lng intValue] == 0) return;
  NSString *URL = [NSString stringWithFormat:@"%@venues/search?client_id=%@&client_secret=%@&ll=%@,%@", kFoursquareVenueURL, GCFoursquareClientID, GCFoursquareSecret, lat, lng];
  NSLog(@"FS URL: %@", URL);
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URL]];
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(requestDone:)];
  [request setDidFailSelector:@selector(requestWentWrong:)];
  NSOperationQueue *queue = [GCCommunicator sharedCommunicator].downloadQueue;
  [queue addOperation:request];
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestDone:(ASIHTTPRequest *)request {
  NSData *data = [request responseData];
  if (data) {
    NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!tempString) {
      NSLog(@"Foursquare listings JSON error (no string)");
      return;
    }
    id returnedListings = [tempString JSONValueWithStrings];
    [tempString release];
    //NSLog(@"FS Listings: %@", returnedListings);
    if (![returnedListings isKindOfClass:[NSDictionary class]]) {
      if (delegate && [delegate respondsToSelector:@selector(didFetchFoursquareListings:)]) {
        [delegate didFetchFoursquareListings:nil];
      }
    }
    NSDictionary *response = [returnedListings objectForKey:@"response"];
    if (response) {
      NSArray *groups = [response objectForKey:@"groups"];
      if (groups && [groups count] > 0) {
        NSArray *items = [[groups objectAtIndex:0] objectForKey:@"items"];
        if (items) {
          if (delegate && [delegate respondsToSelector:@selector(didFetchFoursquareListings:)]) {
            [delegate didFetchFoursquareListings:[[items retain] autorelease]];
            return;
          }
        }
      }
    }
  }
  if (delegate && [delegate respondsToSelector:@selector(didFetchFoursquareListings:)]) {
    [delegate didFetchFoursquareListings:nil];
  }
}

- (void)requestWentWrong:(ASIHTTPRequest *)request {
  NSLog(@"FS Listings Fetch Error");
	
}

- (void)dealloc {
  [delegate release];
  [listings release];
  [super dealloc];
}

@end
