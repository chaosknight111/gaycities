//
//  OCGeoApiCommunicator.h
//  BreadcrumbTrail-iPad
//
//  Created by Brian Harmann on 4/11/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAConnectionDelegate.h"
#import "GAConnectionManager.h"


typedef enum {
	kGeoNearLocSearch,
	kGeoNameSearch
} RequestType;


@interface OCGeoApiCommunicator : NSObject <GAConnectionDelegate> {
	GAConnectionManager *connectionManager;
	RequestType requestType;
	id delegate;
	NSArray *verticals;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSArray *verticals;

- (void)receivedResponseString:(NSString *)responseString;
- (void)requestFailed:(NSError *)error;

//- (void)sendNextRequest;
- (id)initWithDelegate:(id)newDelegate;
- (void)requestBusinessesNear:(double)lat lng:(double)lng;



@end
