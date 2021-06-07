//
//  GCListingReview.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/8/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCListingReviewDelegate.h"
#import "ASIHTTPRequest.h"

@interface GCListingReview : NSObject {
	NSString *r_rating, *r_id, *r_date, *r_title, *r_text, *username, *u_age, *u_gender, *u_num_reviews, *u_photo;
	UIImage *stars, *profileImage;
	NSObject<GCListingReviewDelegate> *delegate;
	ASIHTTPRequest *request;
}

@property (nonatomic, copy) NSString *r_rating, *r_id, *r_date, *r_title, *r_text, *username, *u_age, *u_gender, *u_num_reviews, *u_photo;
@property (nonatomic, retain) UIImage *stars, *profileImage;
@property (nonatomic, assign) NSObject<GCListingReviewDelegate> *delegate;

- (void)loadURL:(NSURL *)url;


@end
