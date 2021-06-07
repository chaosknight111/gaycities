//
//  GCPopularEventsView.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/6/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "GCPopularEventsView.h"
#import "GCEventSummary.h"
//#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import "OCConstants.h"
#import "GCCommunicator.h"

@implementation GCPopularEventsView

@synthesize event, loadEventButton;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

      imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 20)];
      imageView.backgroundColor = [UIColor clearColor];
      imageView.contentMode = UIViewContentModeTop;
      imageView.clipsToBounds = YES;
      popularTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, frame.size.height - 40, 60, 19)];
      popularTypeLabel.font = [UIFont boldSystemFontOfSize:10];
      popularTypeLabel.textAlignment = UITextAlignmentCenter;
      popularTypeLabel.textColor = [UIColor whiteColor];
      //popularTypeLabel.shadowColor = [UIColor darkGrayColor];
      //popularTypeLabel.shadowOffset = CGSizeMake(0, -1);
      popularTypeLabel.backgroundColor = [UIColor blackColor];
      [self addSubview:imageView];
      [self addSubview:popularTypeLabel];
      popularTypeLabel.hidden = YES;
      activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
      activityIndicator.frame = CGRectMake(frame.size.width/2 - 10, frame.size.height/2 - 13, 20, 20);
      activityIndicator.hidesWhenStopped = YES;
      [activityIndicator startAnimating];
      [self addSubview:activityIndicator];
      self.loadEventButton = [UIButton buttonWithType:UIButtonTypeCustom];
      loadEventButton.frame = imageView.frame;
      [loadEventButton addTarget:self action:@selector(loadEventDetails) forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:loadEventButton];
      self.clipsToBounds = NO;
      self.backgroundColor = [UIColor clearColor];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadImage:) name:gcCellImageUpdatedForEventNotification object:nil];
    }
    return self;
}

//- (void)layoutSubviews {
//  [super layoutSubviews];
//}


//- (void)drawRect:(CGRect)rect {
//  CGContextRef context = UIGraphicsGetCurrentContext();
//  CGColorRef shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5].CGColor;    
//  CGContextSetShadowWithColor(context, CGSizeMake(-2, 2), 3.0, shadowColor);
//  [super drawRect:rect];
//}

- (void)setEvent:(GCEventSummary *)newEvent {
  [event release];
  [newEvent retain];
  event = newEvent;
  event.popularDelegate = self;
  popularTypeLabel.text = [event.popularType uppercaseString];
  //popularTypeLabel.text = @"NOW";
  CGSize width = [event.popularType sizeWithFont:[UIFont boldSystemFontOfSize:10]];
  popularTypeLabel.frame = CGRectMake(popularTypeLabel.frame.origin.x, popularTypeLabel.frame.origin.y, 20 + width.width, popularTypeLabel.frame.size.height);
  [self setNeedsDisplay];
  [self loadImage:nil];
}

- (void)loadImage:(NSNotification *)note
{
  UIImage *image = event.eventImage;
  if (image == nil)
	 {
    imageView.image = nil;
    [activityIndicator startAnimating];
	 } else {
    [activityIndicator stopAnimating];
     imageView.image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:imageView.frame.size interpolationQuality:kCGInterpolationHigh];
     popularTypeLabel.hidden = NO;
	 }
  [self setNeedsDisplay];
}

- (void)loadEventDetails {
  if (!event) return;
  
  [[GCCommunicator sharedCommunicator] loadEventDetails:event.event_id processing:YES];

}

#pragma mark -
#pragma mark GCUpdatesPeopleCellDelegate methods

- (void)gcEventSummary:(GCEventSummary *)anEvent didLoadImage:(UIImage *)image

{
	[self loadImage:nil];
	
}

- (void)gcEventSummary:(GCEventSummary *)anEvent couldNotLoadImageError:(NSError *)error
{
  [self loadImage:nil];

}

- (void)dealloc {
  event.popularDelegate = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self name:gcCellImageUpdatedForEventNotification object:nil];
  [imageView release];
  [event release];
  [popularTypeLabel release];
  [activityIndicator release];
  self.loadEventButton = nil;
  [super dealloc];
}


@end
