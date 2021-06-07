//
//  GCFindFriendCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 5/7/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCFindFriendPerson.h"

@interface GCFindFriendCell : UITableViewCell <GCFindFriendPersonDelegate> {
	UILabel *usernameLabel, *fullNameLabel, *addOrRemoveLabel;
	UIImageView *actionImageView, *profileImageView;
	UIActivityIndicatorView *activityView;
	GCFindFriendPerson *person;
}

@property (nonatomic, retain) IBOutlet UILabel *usernameLabel, *fullNameLabel, *addOrRemoveLabel;
@property (nonatomic, retain) IBOutlet UIImageView *actionImageView, *profileImageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, retain) GCFindFriendPerson *person;

- (void)loadImage;

@end
