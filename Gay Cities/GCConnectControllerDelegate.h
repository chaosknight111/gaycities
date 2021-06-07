//
//  GCConnectControllerDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/1/2010.
//  Copyright 2010 Obsessive Code. All rights reserved.
//


@class GCConnectController;

@protocol GCConnectControllerDelegate

@required
- (void)twitterUpdateFinished:(BOOL)status;
- (void)facebookUpdateFinished:(BOOL)status;
- (void)foursquareUpdateFinished:(BOOL)status response:(NSString *)response;

@end
