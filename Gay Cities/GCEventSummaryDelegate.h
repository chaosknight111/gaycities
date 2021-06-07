//
//  GCEventSummaryDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/30/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//


@class GCEventSummary;

@protocol GCEventSummaryDelegate

@required
- (void)gcEventSummary:(GCEventSummary *)anEvent didLoadImage:(UIImage *)image;

@optional
- (void)gcEventSummary:(GCEventSummary *)anEvent didLoadThumbnail:(UIImage *)image;
- (void)gcEventSummary:(GCEventSummary *)anEvent couldNotLoadImageError:(NSError *)error;

@end
