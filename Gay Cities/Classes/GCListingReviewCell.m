//
//  OCDetailCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/14/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import "GCListingReviewCell.h"


@implementation GCListingReviewCell

@synthesize reviewTitle, userDetails, postDate, reviewText, userImage, starsImage;
@synthesize person;
@synthesize activityView;

/*
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {        // Initialization code
    }
    return self;
}*/


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
	self.reviewTitle = nil;
	self.activityView = nil;
	self.userDetails = nil;
	self.postDate = nil;
	self.reviewText = nil;
	self.userImage = nil;
	self.starsImage = nil;
    [super dealloc];
}


- (void)setPerson:(GCListingReview *)aPerson
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
    userImage.image = image;
}

#pragma mark -
#pragma mark GCUpdatesPeopleCellDelegate methods

- (void)gcReviewer:(GCListingReview *)aPerson didLoadImage:(UIImage *)image
{
	//NSLog(@"loaded new thumb for cell");
    self.userImage.image = image;
    [self.activityView stopAnimating];
	
}

- (void)gcReviewer:(GCListingReview *)aPerson couldNotLoadImageError:(NSError *)error
{
    // Here we could show a "default" or "placeholder" image...
	NSLog(@"Cell Load Image error - shouldnt get here");
    [self.activityView stopAnimating];
}

#pragma mark -
#pragma mark UIView animation delegate methods

- (void)toggleImage:(UIImage *)image
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:userImage cache:YES];
    //[UIView setAnimationDelegate:self];
	// [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    
    userImage.image = image;
    
    [UIView commitAnimations];
}


- (void)animationFinished
{
    
}


@end
