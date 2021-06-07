//
//  GCFindFriendPersonDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/1/2010.
//  Copyright 2010 Obsessive Code. All rights reserved.
//


@class GCFindFriendPerson;

@protocol GCFindFriendPersonDelegate

@required
- (void)gcFFPerson:(GCFindFriendPerson *)person didLoadImage:(UIImage *)image;

@optional
- (void)gcFFPerson:(GCFindFriendPerson *)person didLoadThumbnail:(UIImage *)image;
- (void)gcFFPerson:(GCFindFriendPerson *)person couldNotLoadImageError:(NSError *)error;

@end
