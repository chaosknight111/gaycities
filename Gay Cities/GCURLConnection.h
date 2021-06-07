//
//  GCURLConnection.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/30/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum GCRequestType {
	GCRequestTypeMetros = 1,
	GCRequestTypeListings,
  GCRequestTypeCheckinListings,
	GCRequestTypeEvents,
	GCRequestTypeListingsAndEvents,
	GCRequestTypeEventDetails,
	GCRequestTypeListingPeople,
	GCRequestTypeListingPeopleAndReviews,
	GCRequestTypePeopleUpdates,
	GCRequestTypeListingPhotos,
	GCRequestTypeListingsCheckInAndPopular
} GCRequestType;


@interface GCURLConnection : NSURLConnection {
    NSMutableData *data;                   
    GCRequestType requestType;      
    NSString *identifier;
}

@property (nonatomic, retain) NSMutableData *data;  
@property (nonatomic, retain) NSString *identifier;
@property (readonly) GCRequestType requestType;

// Initializer
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(GCRequestType)newRequestType;

- (void)resetDataLength;
- (void)appendData:(NSData *)newData;

- (NSString *)description;

@end
