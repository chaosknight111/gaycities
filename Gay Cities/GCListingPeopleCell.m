//
//  GCListingPeopleCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/11/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCListingPeopleCell.h"


@implementation GCListingPeopleCell

@synthesize profileImage, userName, shout, userDetails, checkinDate, noKingMessage, disclosureImage, activityView;
@synthesize person;


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	if (person) {
		person.delegate = nil;
		[person release];
		person = nil;
	}
	self.profileImage = nil;
	self.userName = nil;
	self.shout = nil;
	self.userDetails = nil;
	self.checkinDate = nil;
	self.noKingMessage = nil;
	self.disclosureImage = nil;
	self.activityView = nil;
    [super dealloc];
}


- (void)setPerson:(GCPerson *)aPerson
{
	if (aPerson) {
		if (person) {
			[person release];
			person = nil;
		}
		person = aPerson;
		[person retain];
		person.delegate = self;
	}
}



- (void)loadImage
{
    UIImage *image = person.profileImage;
    if (image == nil)
    {
        [activityView startAnimating];
    } else {
		[activityView stopAnimating];
	}
    profileImage.image = image;
}

#pragma mark -
#pragma mark GCUpdatesPeopleCellDelegate methods

- (void)gcPerson:(GCPerson *)aPerson didLoadImage:(UIImage *)image
{
    profileImage.image = image;
    [activityView stopAnimating];
	
}

- (void)gcPerson:(GCPerson *)aPerson couldNotLoadImageError:(NSError *)error
{
    // Here we could show a "default" or "placeholder" image...
	NSLog(@"Cell Load Image error - shouldnt get here");
    [activityView stopAnimating];
}

#pragma mark -
#pragma mark UIView animation delegate methods

- (void)toggleImage:(UIImage *)image
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:profileImage cache:YES];
    //[UIView setAnimationDelegate:self];
	// [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    
    profileImage.image = image;
    
    [UIView commitAnimations];
}

- (void)animationFinished
{
    
}


@end
