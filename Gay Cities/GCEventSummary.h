//
//  GCEventSummary.h
//  Gay Cities
//
//  Created by Brian Harmann on 10/1/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "GCEventSummaryDelegate.h"

@interface GCEventSummary : NSObject {
	NSString *eventName, *shout, *eventHours, *event_id, *photo_url, *numAttending, *metro_id, *group, *popularType;
	NSDate *startDate, *endDate;
	NSMutableDictionary *event;
	UIImage *eventImage;
	NSObject<GCEventSummaryDelegate> *delegate, *popularDelegate;
	ASIHTTPRequest *request;
	BOOL eventImageAlreadyRequested, isPopular;
	int startTimeInterval, endTimeInterval;
}

@property (nonatomic, copy) NSString *created, *eventName, *shout, *eventHours, *event_id, *photo_url, *numAttending, *metro_id, *group, *popularType;
@property (nonatomic, retain) NSDate *startDate, *endDate;
@property (nonatomic, retain) NSMutableDictionary *event;
@property (nonatomic, retain) UIImage *eventImage;
@property (nonatomic, assign) NSObject<GCEventSummaryDelegate> *delegate, *popularDelegate;
@property (readwrite) int startTimeInterval, endTimeInterval;
@property (readwrite) BOOL isPopular;

- (id)initWithImage:(UIImage *)image;
- (void)loadURL:(NSURL *)url;

@end
