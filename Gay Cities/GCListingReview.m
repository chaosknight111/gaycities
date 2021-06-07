//
//  GCListingReview.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/8/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCListingReview.h"
#import "GCCommunicator.h"

@implementation GCListingReview

@synthesize r_rating, r_id, r_date, r_title, r_text, username, u_age, u_gender, u_num_reviews, u_photo;
@synthesize stars, profileImage;
@synthesize delegate;

/*
- (id)init
{
	self = [super init];
	
	r_rating = [[NSString alloc] init];
	r_id = [[NSString alloc] init];
	r_date = [[NSString alloc] init];
	r_title = [[NSString alloc] init];
	r_text = [[NSString alloc] init];
	username = [[NSString alloc] init];
	u_age = [[NSString alloc] init];
	u_gender = [[NSString alloc] init];
	u_num_reviews = [[NSString alloc] init];
	u_photo = [[NSString alloc] init];
	stars = [[UIImage alloc] init];
	//NSString *bundlePath = [[NSBundle mainBundle] bundlePath];	
	//NSString *defaultProfilePath = [bundlePath stringByAppendingPathComponent:@"default_profile40.png"];
	//userImage = [[UIImage alloc] initWithContentsOfFile:defaultProfilePath];
	return self;
}*/

- (id)initWithImage:(UIImage *)image
{
	self = [super init];
	r_rating = [[NSString alloc] init];
	r_id = [[NSString alloc] init];
	r_date = [[NSString alloc] init];
	r_title = [[NSString alloc] init];
	r_text = [[NSString alloc] init];
	username = [[NSString alloc] init];
	u_age = [[NSString alloc] init];
	u_gender = [[NSString alloc] init];
	u_num_reviews = [[NSString alloc] init];
	u_photo = [[NSString alloc] init];
	stars = [[UIImage alloc] init];
	self.profileImage = image;
	return self;
}

- (void)dealloc
{
	if (request) {
		[request setDelegate:nil];
	}
	delegate = nil;
	self.r_rating = nil;
	self.r_id = nil;
	self.r_date = nil;
	self.r_title = nil;
	self.r_text = nil;
	self.username = nil;
	self.u_age = nil;
	self.u_gender = nil;
	self.u_num_reviews = nil;
	self.u_photo = nil;
	self.stars = nil;
	self.profileImage = nil;
	[super dealloc];
}


- (UIImage *)profileImage
{
	if (profileImage == nil) {
		if ([u_photo length] > 0) {
			UIImage *image = [[[GCCommunicator sharedCommunicator] peopleImages] objectForKey:u_photo];
			if (image) {
				self.profileImage = image;
			} else {
				[self loadURL:[NSURL URLWithString:u_photo]];
			}
			
		} else {
			self.profileImage = [UIImage imageNamed:@"default_profile40.png"];
		}
	}
	return profileImage;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"revewer: %@", username];
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestDone:(ASIHTTPRequest *)aRequest
{
  NSData *data = [aRequest responseData];
  UIImage *remoteImage = [[UIImage alloc] initWithData:data];
  self.profileImage = remoteImage;
  if (remoteImage) {
    [[[GCCommunicator sharedCommunicator] peopleImages] setObject:remoteImage forKey:u_photo];
  }
  if (delegate && [delegate respondsToSelector:@selector(gcReviewer:didLoadImage:)])
  {
      [delegate gcReviewer:self didLoadImage:remoteImage];
  }
  [remoteImage release];
	request = nil;
}

- (void)requestWentWrong:(ASIHTTPRequest *)aRequest
{
	NSLog(@"Person Image Request Error");
	UIImage *image = [UIImage imageNamed:@"default_profile40.png"];
	self.profileImage = image;
	[[[GCCommunicator sharedCommunicator] peopleImages] setObject:profileImage forKey:u_photo];
	
    if (delegate && [delegate respondsToSelector:@selector(gcReviewer:didLoadImage:)])
    {
        [delegate gcReviewer:self didLoadImage:image];
    }
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
