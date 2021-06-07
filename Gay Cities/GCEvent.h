//
//  GCEvent.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/2/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"


@interface GCEvent : NSObject {
	NSDate *start, *end;
	NSString *event_id, *name, *photo_url, *one_liner, *eventDescription, *street, *phone, *hours, *city, *state;
	NSMutableArray *attendees;
	NSMutableDictionary *userStatus;
	UIImage *eventImage;
	ASIHTTPRequest *request;
	BOOL eventImageAlreadyRequested;
	double lat, lng;

}

@property (nonatomic, retain) NSDate *start, *end;
@property (nonatomic, retain) NSString *event_id, *name, *photo_url, *one_liner, *eventDescription, *street, *phone, *hours, *city, *state;
@property (nonatomic, retain) NSMutableArray *attendees;
@property (nonatomic, retain) UIImage *eventImage;
@property (readwrite) double lat, lng;
@property (nonatomic, retain) NSMutableDictionary *userStatus;

- (id)initWithImage:(UIImage *)image;
- (void)loadURL:(NSURL *)url;

@end
