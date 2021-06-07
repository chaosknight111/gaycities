//
//  FindFriendPerson.m
//  Gay Cities
//
//  Created by Brian Harmann on 7/1/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCFindFriendPerson.h"
#import "GCCommunicator.h"

@implementation GCFindFriendPerson

@synthesize username, email, first_name, last_name, twitter_name, profile_image_url, passed_full_name, facebook_uid;
@synthesize profileImage;
@synthesize delegate;
@synthesize already_friend, invite_sent;

- (id)init {
	if (self = [super init]) {
		profileImageAlreadyRequested = NO;
		already_friend = NO;
		invite_sent = NO;
	}
	
	return self;
}

- (id)initWithImage:(UIImage *)image {
	if (self = [super init]) {
		profileImageAlreadyRequested = NO;
		already_friend = NO;
		invite_sent = NO;
		username = [[NSString alloc] init];
		email = [[NSString alloc] init];
		first_name = [[NSString alloc] init];
		last_name = [[NSString alloc] init];
		twitter_name = [[NSString alloc] init];
		profile_image_url = [[NSString alloc] init];
		passed_full_name = [[NSString alloc] init];
		facebook_uid = [[NSString alloc] init];
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
	self.username = nil;
	self.email = nil;
	self.first_name = nil;
	self.last_name = nil;
	self.profileImage = nil;
	self.twitter_name = nil;
	self.passed_full_name = nil;
	self.profile_image_url = nil;
	self.facebook_uid = nil;
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
		if ([profile_image_url length] > 0) {
			UIImage *image = [[[GCCommunicator sharedCommunicator] peopleImages] objectForKey:profile_image_url];
			if (image) {
				self.profileImage = image;
			} else {
				if ([profile_image_url isEqualToString:@"http://www.gaycities.com/images/sm_profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([profile_image_url isEqualToString:@"http://www.gaycities.com/images/xsm_profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([profile_image_url isEqualToString:@"http://www.gaycities.com/images/mini_profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([profile_image_url isEqualToString:@"http://www.gaycities.com/images/med_profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([profile_image_url isEqualToString:@"http://www.gaycities.com/images/profile.gif"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([profile_image_url isEqualToString:@"http://www.gaycities.com/images/v3/default_user.png"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([profile_image_url isEqualToString:@"http://gcimg.gaycities.com/v3/default_user.png"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([profile_image_url isEqualToString:@"http://www.gaycities.com/images/v4/default_user.png"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else if ([profile_image_url isEqualToString:@"http://gcimg.gaycities.com/v4/default_user.png"]) {
					self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
				} else {
					[self loadURL:[NSURL URLWithString:profile_image_url]];
				}
			}
			
		} else {
			self.profileImage = [UIImage imageNamed:@"defaultProfile.png"];
		}
	}
	return profileImage;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"email: %@, profile Image: %@", email, profile_image_url ? profile_image_url : @"no profile image url"];
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestDone:(ASIHTTPRequest *)aRequest
{
    NSData *data = [aRequest responseData];
	UIImage *remoteImage = [UIImage imageWithData:data];
	
	if (data && remoteImage) {
		self.profileImage = remoteImage;
		[[[GCCommunicator sharedCommunicator] peopleImages] setObject:remoteImage forKey:profile_image_url];
		if (delegate && [delegate respondsToSelector:@selector(gcFFPerson:didLoadImage:)])
		 {
			[delegate gcFFPerson:self didLoadImage:remoteImage];
		 }
		[[NSNotificationCenter defaultCenter] postNotificationName:gcCellImageUpdatedForFindFriendNotification object:nil];
	}
    
	request = nil;
}

- (void)requestWentWrong:(ASIHTTPRequest *)aRequest
{
	NSLog(@"Person Image Request Error");
	UIImage *image = [UIImage imageNamed:@"default_profile40.png"];
	self.profileImage = image;
	[[[GCCommunicator sharedCommunicator] peopleImages] setObject:profileImage forKey:profile_image_url];
	
    if (delegate && [delegate respondsToSelector:@selector(gcFFPerson:didLoadImage:)])
	 {
        [delegate gcFFPerson:self didLoadImage:image];
	 }
	[[NSNotificationCenter defaultCenter] postNotificationName:gcCellImageUpdatedForFindFriendNotification object:nil];
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
