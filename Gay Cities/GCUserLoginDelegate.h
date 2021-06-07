//
//  GCUserLoginDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/30/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCUserLogin;

@protocol GCUserLoginDelegate

@optional
- (void)loginResult:(BOOL)result;
- (void)makeFanResult:(NSString *)result;
- (void)checkinResult:(NSMutableDictionary *)result;
- (void)attendEventResult:(BOOL)result;
- (void)loginStatusForEventResult:(BOOL)result;
- (void)friendActionResult:(BOOL)result;
- (void)findFriendSearchResults:(NSMutableDictionary *)result;
- (void)foursquareTokenResult:(NSString *)token;
@end


