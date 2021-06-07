//
//  GCEventsCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 6/23/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCEventSummary.h"

@interface GCEventsCell : UITableViewCell <GCEventSummaryDelegate> {
	UILabel *eventTitle, *dates, *numAttending, *hoursLabel;
	GCEventSummary *eventSummary;
	
	UIImageView *eventImage;
	UIActivityIndicatorView *activityView;
}

@property (nonatomic, retain) IBOutlet UILabel *eventTitle, *dates, *numAttending, *hoursLabel;
@property (nonatomic, retain)  GCEventSummary *eventSummary;
@property (nonatomic, retain) IBOutlet UIImageView *eventImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

- (void)loadImage;


@end
