//
//  GCPerson.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/17/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCPerson.h"
#import "GCCommunicator.h"

@implementation GCPerson

@synthesize created, display, shout, update_type, checkin_id, u_photo_url;
@synthesize createdTime;
@synthesize user;
@synthesize profileImage;
@synthesize delegate;


- (id)init {
	if (self = [super init]) {
		profileImageAlreadyRequested = NO;
	}
	
	return self;
}

- (id)initWithImage:(UIImage *)image {
	if (self = [super init]) {
		profileImageAlreadyRequested = NO;
		
		created = [[NSString alloc] init];
		display = [[NSString alloc] init];
		shout = [[NSString alloc] init];
		update_type = [[NSString alloc] init];
		createdTime = [[NSDate alloc] init];
		user = [[NSMutableDictionary alloc] init];
		checkin_id = [[NSString alloc] init];
		u_photo_url = [[NSString alloc] init];
		if (image) {
			self.profileImage = image;
		} else {
			self.profileImage = nil;
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
	self.created = nil;
	self.display = nil;
	self.shout = nil;
	self.update_type = nil;
	self.createdTime = nil;
	self.user = nil;
	self.profileImage = nil;
	self.checkin_id = nil;
	self.u_photo_url = nil;
	[super dealloc];
}

/*
 http://www.gaycities.com/images/sm_profile.gif
 http://www.gaycities.com/images/xsm_profile.gif
 http://www.gaycities.com/images/mini_profile.gif
 http://www.gaycities.com/images/med_profile.gif
 http://www.gaycities.com/images/profile.gif
 */


- (UIImage *)profileImage
{
	if (profileImage == nil && !profileImageAlreadyRequested) {
		profileImageAlreadyRequested = YES;
		if ([u_photo_url length] > 0) {
			UIImage *image = [[[GCCommunicator sharedCommunicator] peopleImages] objectForKey:u_photo_url];
			if (image) {
				self.profileImage = image;
			} else {
				if ([u_photo_url isEqualToString:@"http://www.gaycities.com/images/sm_profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([u_photo_url isEqualToString:@"http://www.gaycities.com/images/xsm_profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([u_photo_url isEqualToString:@"http://www.gaycities.com/images/mini_profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([u_photo_url isEqualToString:@"http://www.gaycities.com/images/med_profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([u_photo_url isEqualToString:@"http://www.gaycities.com/images/profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([u_photo_url isEqualToString:@"http://www.gaycities.com/images/v3/default_user.png"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([u_photo_url isEqualToString:@"http://gcimg.gaycities.com/v3/default_user.png"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([u_photo_url isEqualToString:@"http://www.gaycities.com/images/v4/default_user.png"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([u_photo_url isEqualToString:@"http://gcimg.gaycities.com/v4/default_user.png"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else {
					[self loadURL:[NSURL URLWithString:u_photo_url]];
				}
			}

		} else {
			self.profileImage = [UIImage imageNamed:@"default_profile40.png"];
		}
	}
	return profileImage;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"user: %@", user];
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestDone:(ASIHTTPRequest *)aRequest
{
  NSData *data = [aRequest responseData];
	UIImage *remoteImage = [UIImage imageWithData:data];

	if (data && remoteImage) {
		self.profileImage = remoteImage;
		[[[GCCommunicator sharedCommunicator] peopleImages] setObject:remoteImage forKey:u_photo_url];
		if (delegate && [delegate respondsToSelector:@selector(gcPerson:didLoadImage:)])
		 {
			[delegate gcPerson:self didLoadImage:remoteImage];
		 }
		[[NSNotificationCenter defaultCenter] postNotificationName:gcCellImageUpdatedForPersonNotification object:nil];
	}
    
	request = nil;
}

- (void)requestWentWrong:(ASIHTTPRequest *)aRequest
{
	NSLog(@"Person Image Request Error");
	UIImage *image = [UIImage imageNamed:@"default_profile40.png"];
	self.profileImage = image;
	[[[GCCommunicator sharedCommunicator] peopleImages] setObject:profileImage forKey:u_photo_url];

    if (delegate && [delegate respondsToSelector:@selector(gcPerson:didLoadImage:)])
    {
        [delegate gcPerson:self didLoadImage:image];
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:gcCellImageUpdatedForPersonNotification object:nil];
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
