//
//  GCListingReviewDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/31/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

@class GCListingReview;



@protocol GCListingReviewDelegate

@required
- (void)gcReviewer:(GCListingReview *)person didLoadImage:(UIImage *)image;

@optional
- (void)gcReviewer:(GCListingReview *)person didLoadThumbnail:(UIImage *)image;
- (void)gcReviewer:(GCListingReview *)person couldNotLoadImageError:(NSError *)error;

@end
