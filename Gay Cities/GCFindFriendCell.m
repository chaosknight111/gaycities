//
//  GCFindFriendCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 5/7/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCFindFriendCell.h"


@implementation GCFindFriendCell

@synthesize addOrRemoveLabel, usernameLabel, fullNameLabel;
@synthesize actionImageView, profileImageView;
@synthesize activityView;
@synthesize person;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


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
	self.addOrRemoveLabel = nil;
	self.usernameLabel = nil;
	self.fullNameLabel = nil;
	self.actionImageView = nil;
	self.profileImageView = nil;
	self.activityView = nil;
    [super dealloc];
}


- (void)setPerson:(GCFindFriendPerson *)aPerson
{
	if (aPerson) {
		if (person) {
			[person release];
			person = nil;
		}
		person = aPerson;
		[person retain];
		person.delegate = self;
	} else {
		if (person) {
			[person release];
			person = nil;
		}
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
    profileImageView.image = image;
}

#pragma mark -
#pragma mark GCUpdatesFindFriendPeopleCellDelegate methods

- (void)gcFFPerson:(GCFindFriendPerson *)aPerson didLoadImage:(UIImage *)image
{
	// profileImage.image = image;
	//  [activityView stopAnimating];
	[self loadImage];
	
}

- (void)gcFFPerson:(GCFindFriendPerson *)aPerson couldNotLoadImageError:(NSError *)error
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
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:profileImageView cache:YES];
    //[UIView setAnimationDelegate:self];
	// [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    
    profileImageView.image = image;
    
    [UIView commitAnimations];
}

- (void)animationFinished
{
    
}

@end
