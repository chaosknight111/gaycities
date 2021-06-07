//
//  GCEventsCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/23/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCEventsCell.h"


@implementation GCEventsCell

@synthesize eventTitle, dates, numAttending, hoursLabel;
@synthesize eventSummary;
@synthesize eventImage;
@synthesize activityView;

/*
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}
*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	if (eventSummary) {
		eventSummary.delegate = nil;
		[eventSummary release];
		eventSummary = nil;
	}
	self.eventTitle = nil;
	self.dates = nil;
	self.numAttending = nil;
	self.hoursLabel = nil;
	self.eventImage = nil;
	self.activityView = nil;
    [super dealloc];
}

- (void)setEventSummary:(GCEventSummary *)newEvent
{
	if (newEvent) {
		if (eventSummary) {
			[eventSummary release];
			eventSummary = nil;
		}
		eventSummary = [newEvent retain];
		eventSummary.delegate = self;
	}
}



- (void)loadImage
{
  if (!eventSummary) {
    eventImage.image = [UIImage imageNamed:@"defaultEventImage.png"];
    [activityView stopAnimating];
  } else {
    UIImage *image = eventSummary.eventImage;
    if (image == nil) {
      eventImage.image = nil;
      [activityView startAnimating];
    } else {
      [activityView stopAnimating];
      eventImage.image = image;
    }
  }
  [self setNeedsDisplay];
}

#pragma mark -
#pragma mark GCUpdatesPeopleCellDelegate methods

- (void)gcEventSummary:(GCEventSummary *)anEvent didLoadImage:(UIImage *)image

{
  if (anEvent != self.eventSummary) return;
  eventImage.image = image;
  [activityView stopAnimating];
  [self setNeedsDisplay];

}

- (void)gcEventSummary:(GCEventSummary *)anEvent couldNotLoadImageError:(NSError *)error
{
  if (anEvent != self.eventSummary) return;
  // Here we could show a "default" or "placeholder" image...
  
	NSLog(@"Cell Load Event Image error - shouldnt get here");
  eventImage.image = [UIImage imageNamed:@"defaultEventImage.png"];
  [activityView stopAnimating];
  [self setNeedsDisplay];

}

#pragma mark -
#pragma mark UIView animation delegate methods

- (void)toggleImage:(UIImage *)image
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:eventImage cache:YES];
    //[UIView setAnimationDelegate:self];
	// [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    
    eventImage.image = image;
    
    [UIView commitAnimations];
}

- (void)animationFinished
{
    
}


@end
