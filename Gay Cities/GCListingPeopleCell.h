//
//  GCListingPeopleCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/11/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCPerson.h"

@interface GCListingPeopleCell : UITableViewCell <GCPersonDelegate> {
	UIImageView *profileImage, *disclosureImage;
	UILabel *userName, *shout, *userDetails, *checkinDate, *noKingMessage;
	UIActivityIndicatorView *activityView;
	GCPerson *person;
}

@property (nonatomic, retain) IBOutlet UIImageView *profileImage, *disclosureImage;
@property (nonatomic, retain) IBOutlet UILabel *userName, *shout, *userDetails, *checkinDate, *noKingMessage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) GCPerson *person;

- (void)loadImage;

@end
