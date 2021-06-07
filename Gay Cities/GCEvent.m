//
//  GCEvent.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/2/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCEvent.h"
#import "GCCommunicator.h"

@implementation GCEvent

@synthesize start, end, event_id, name, attendees, eventImage, one_liner, eventDescription, street, phone, hours, city, state, photo_url;
@synthesize lat, lng;
@synthesize userStatus;


- (id)init {
	self = [super init];
	
	start = [[NSDate alloc] init];
	end = [[NSDate alloc] init];
	event_id = [[NSString alloc] init];
	name = [[NSString alloc] init];
	attendees = [[NSMutableArray alloc] init];
	eventImage = [[UIImage imageNamed:@"defaultEventImage.png"] retain];
	eventImageAlreadyRequested = NO;
	one_liner = [[NSString alloc] init];
	eventDescription = [[NSString alloc] init];
	street = [[NSString alloc] init];
	phone = [[NSString alloc] init];
	hours = [[NSString alloc] init];
	city = [[NSString alloc] init];
	state = [[NSString alloc] init];
	photo_url = [[NSString alloc] init];
	lat = 0;
	lng = 0;
	userStatus = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (id)initWithImage:(UIImage *)image {
	self = [super init];
	
	start = [[NSDate alloc] init];
	end = [[NSDate alloc] init];
	event_id = [[NSString alloc] init];
	name = [[NSString alloc] init];
	attendees = [[NSMutableArray alloc] init];
	if (image) {
		eventImage = [image retain];
	} else {
		eventImage = [[UIImage imageNamed:@"defaultEventImage.png"] retain];
	}
	eventImageAlreadyRequested = NO;
	one_liner = [[NSString alloc] init];
	eventDescription = [[NSString alloc] init];
	street = [[NSString alloc] init];
	phone = [[NSString alloc] init];
	hours = [[NSString alloc] init];
	city = [[NSString alloc] init];
	state = [[NSString alloc] init];
	photo_url = [[NSString alloc] init];
	lat = 0;
	lng = 0;
	userStatus = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (UIImage *)eventImage
{
	if (eventImage == nil && !eventImageAlreadyRequested) {
		eventImageAlreadyRequested = YES;
		if ([photo_url length] > 0) {
			UIImage *image = [[[GCCommunicator sharedCommunicator] peopleImages] objectForKey:photo_url];
			if (image) {
				self.eventImage = image;
			} else {
				
				[self loadURL:[NSURL URLWithString:photo_url]];
			}
			
		} else {
			self.eventImage = [UIImage imageNamed:@"defaultEventImage.png"];
		}
	}
	return eventImage;
}

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


- (void)dealloc
{
	self.start = nil;
	self.end = nil;
	self.event_id = nil;
	self.name = nil;
	self.attendees = nil;
	self.eventImage = nil;
	one_liner = nil;
	self.eventDescription = nil;
	self.street = nil;
	self.phone = nil;
	self.hours = nil;
	self.city = nil;
	self.state = nil;
	self.photo_url = nil;
	self.userStatus = nil;
	[super dealloc];
}

@end

