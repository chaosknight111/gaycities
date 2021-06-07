//
//  GCUpdatesPeopleCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/13/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCPerson.h"
#import "GCLabel.h"

@interface GCUpdatesPeopleCell : UITableViewCell <GCPersonDelegate> {
	UIImageView *profileImage;
	UILabel *userDetails, *createdTime, *updateType;
	GCLabel *displayLabel, *shoutLabel;
	UIActivityIndicatorView *activityView;
	GCPerson *person;
}

@property (nonatomic, retain) IBOutlet UIImageView *profileImage;
@property (nonatomic, retain) IBOutlet UILabel *userDetails, *createdTime, *updateType;
@property (nonatomic, retain) IBOutlet GCLabel *displayLabel, *shoutLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) GCPerson *person;

- (void)loadImage;

@end
