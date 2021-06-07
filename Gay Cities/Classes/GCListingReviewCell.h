//
//  OCDetailCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/14/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCListingReview.h"

@interface GCListingReviewCell : UITableViewCell <GCListingReviewDelegate> {
	IBOutlet UILabel *reviewTitle, *userDetails, *postDate;
	IBOutlet UIImageView *userImage, *starsImage;
	IBOutlet UILabel *reviewText;
	GCListingReview *person;
	UIActivityIndicatorView *activityView;
}

@property (nonatomic, retain) UILabel *reviewTitle, *userDetails, *postDate;
@property (nonatomic, retain) UILabel *reviewText;
@property (nonatomic, retain) UIImageView *userImage, *starsImage;
@property (nonatomic, retain) GCListingReview *person;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

- (void)loadImage;

@end
