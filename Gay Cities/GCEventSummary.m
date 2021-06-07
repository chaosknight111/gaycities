//
//  GCEventSummary.m
//  Gay Cities
//
//  Created by Brian Harmann on 10/1/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import "GCEventSummary.h"
#import "GCCommunicator.h"


@implementation GCEventSummary

@synthesize created, eventName, shout, eventHours, event_id, photo_url, numAttending, metro_id, group, popularType;
@synthesize startDate, endDate;
@synthesize event;
@synthesize eventImage;
@synthesize delegate, popularDelegate;
@synthesize isPopular;


- (id)init {
	if (self = [super init]) {
		eventImageAlreadyRequested = NO;
		startTimeInterval = 0;
		endTimeInterval = 0;
    isPopular = NO;
	}
	
	return self;
}

- (id)initWithImage:(UIImage *)image {
	if (self = [super init]) {
		eventImageAlreadyRequested = NO;
		startTimeInterval = 0;
		endTimeInterval = 0;
		created = [[NSString alloc] init];
		eventName = [[NSString alloc] init];
		shout = [[NSString alloc] init];
		eventHours = [[NSString alloc] init];
		startDate = [[NSDate alloc] init];
		endDate = [[NSDate alloc] init];
		event = [[NSMutableDictionary alloc] init];
		event_id = [[NSString alloc] init];
		photo_url = [[NSString alloc] init];
		numAttending = [[NSString alloc] init];
		metro_id = [[NSString alloc] init];
    group = [[NSString alloc] init];
    popularType = [[NSString alloc] init];
    
		if (image) {
			self.eventImage = image;
		} else {
			self.eventImage = nil;
		}
	}
	
	
	return self;
}

- (void)dealloc
{
	if (request) {
		[request setDelegate:nil];
	}
	delegate = nil;
  popularDelegate = nil;
	self.created = nil;
	self.eventName = nil;
	self.shout = nil;
	self.eventHours = nil;
	self.startDate = nil;
	self.endDate = nil;
	self.event = nil;
	self.eventImage = nil;
	self.event_id = nil;
	self.photo_url = nil;
	self.numAttending = nil;
	self.metro_id = nil;
  self.group = nil;
  self.popularType =  nil;
	[super dealloc];
}

- (void)setStartTimeInterval:(int)seconds
{
	startTimeInterval = seconds;
	
	int secondsFromGMT = [[NSTimeZone systemTimeZone] secondsFromGMT];
	//NSLog(@"Seconds: %i", secondsFromGMT);
	double time = 0;
	time = time + startTimeInterval;
	time = time - secondsFromGMT;
	if (startDate) {
		[startDate release];
		startDate = nil;
	}
	startDate = [[NSDate alloc] initWithTimeIntervalSince1970:time];

		
}

- (int)startTimeInterval {
  return startTimeInterval;
}

- (void)setEndTimeInterval:(int)seconds
{
	endTimeInterval = seconds;
	
	if (endDate) {
		[endDate release];
		endDate = nil;
	}
	
	if (endTimeInterval <= 0) {
		endTimeInterval = 0;
		
		endDate = [[NSDate alloc] initWithTimeIntervalSince1970:endTimeInterval];
	} else {
		int secondsFromGMT = [[NSTimeZone systemTimeZone] secondsFromGMT];
		//NSLog(@"Seconds: %i", secondsFromGMT);
		double time = 0;
		time = time + endTimeInterval;
		time = time - secondsFromGMT;
		endDate = [[NSDate alloc] initWithTimeIntervalSince1970:time];
	}
}

- (int)endTimeInterval {
  return endTimeInterval;
}

- (void)setStartDate:(NSDate *)aDate
{
	if (aDate) {
		if (startDate) {
			[startDate release];
			startDate = nil;
		}
		startDate = [aDate retain];
		double time = [startDate timeIntervalSince1970];
		int secondsFromGMT = [[NSTimeZone systemTimeZone] secondsFromGMT];
		time = time + secondsFromGMT;
		startTimeInterval = [[NSString stringWithFormat:@"%1.0f", time] intValue];
	}
	
	

}

- (void)setEndDate:(NSDate *)aDate
{
	if (aDate) {
		if (endDate) {
			[endDate release];
			endDate = nil;
		}
		endDate = [aDate retain];
		double time = [endDate timeIntervalSince1970];
		int secondsFromGMT = [[NSTimeZone systemTimeZone] secondsFromGMT];
		time = time + secondsFromGMT;
		endTimeInterval = [[NSString stringWithFormat:@"%1.0f", time] intValue];
	}
	
	
	
}

/*
 http://www.gaycities.com/images/sm_profile.gif
 http://www.gaycities.com/images/xsm_profile.gif
 http://www.gaycities.com/images/mini_profile.gif
 http://www.gaycities.com/images/med_profile.gif
 http://www.gaycities.com/images/profile.gif
 */


- (UIImage *)eventImage
{
	if (eventImage == nil && !eventImageAlreadyRequested) {
		if ([photo_url length] > 0) {
			UIImage *image = [[[GCCommunicator sharedCommunicator] peopleImages] objectForKey:photo_url];
			if (image) {
        //NSLog(@"Using cached image: %@ url: %@", eventName, photo_url);
				self.eventImage = image;
			} else {
        //NSLog(@"Loading image: %@ url: %@", eventName, photo_url);
        eventImageAlreadyRequested = YES;
				[self loadURL:[NSURL URLWithString:photo_url]];
			}
			
		} else {
      //NSLog(@"Default image: %@ url: %@", eventName, photo_url);
			self.eventImage = [UIImage imageNamed:@"defaultEventImage.png"];
		}
	}
	return eventImage;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Event: startDate: %@\nendDate: %@%@\n",startDate, endDate, event];
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestDone:(ASIHTTPRequest *)aRequest
{
    NSData *data = [aRequest responseData];
	UIImage *remoteImage = [UIImage imageWithData:data];
	
	if (data && remoteImage) {
		self.eventImage = remoteImage;
		[[[GCCommunicator sharedCommunicator] peopleImages] setObject:remoteImage forKey:photo_url];
		if (delegate && [delegate respondsToSelector:@selector(gcEventSummary:didLoadImage:)])
		 {
			[delegate gcEventSummary:self didLoadImage:remoteImage];
		 }
    if (popularDelegate && [popularDelegate respondsToSelector:@selector(gcEventSummary:didLoadImage:)])
		 {
			[popularDelegate gcEventSummary:self didLoadImage:remoteImage];
		 }
	} else {
    self.eventImage = [UIImage imageNamed:@"defaultEventImage.png"];
    if (delegate && [delegate respondsToSelector:@selector(gcEventSummary:didLoadImage:)])
    {
			[delegate gcEventSummary:self didLoadImage:self.eventImage];
    }
    if (popularDelegate && [popularDelegate respondsToSelector:@selector(gcEventSummary:didLoadImage:)])
    {
			[popularDelegate gcEventSummary:self didLoadImage:self.eventImage];
    }
  }
  //[[NSNotificationCenter defaultCenter] postNotificationName:gcCellImageUpdatedForEventNotification object:nil];
    
	request = nil;
}

- (void)requestWentWrong:(ASIHTTPRequest *)aRequest
{
	NSLog(@"Event Image Request Error");
	UIImage *image = [UIImage imageNamed:@"defaultEventImage.png"];
	self.eventImage = image;
	
    if (delegate && [delegate respondsToSelector:@selector(gcEventSummary:didLoadImage:)])
	 {
        [delegate gcEventSummary:self didLoadImage:image];
	 }
  if (popularDelegate && [popularDelegate respondsToSelector:@selector(gcEventSummary:didLoadImage:)])
	 {
    [popularDelegate gcEventSummary:self didLoadImage:image];
	 }
	//[[NSNotificationCenter defaultCenter] postNotificationName:gcCellImageUpdatedForEventNotification object:nil];
	request = nil;
}

#pragma mark Image URL Methods

- (void)loadURL:(NSURL *)url
{
	if (request) {
		return;
	}
    request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    NSOperationQueue *queue = [GCCommunicator sharedCommunicator].downloadQueue;
    [queue addOperation:request];
    [request release];    
}


@end
