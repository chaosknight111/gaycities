//
//  GCPersonDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/30/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//


@class GCPerson;

@protocol GCPersonDelegate

@required
- (void)gcPerson:(GCPerson *)person didLoadImage:(UIImage *)image;

@optional
- (void)gcPerson:(GCPerson *)person didLoadThumbnail:(UIImage *)image;
- (void)gcPerson:(GCPerson *)person couldNotLoadImageError:(NSError *)error;

@end
