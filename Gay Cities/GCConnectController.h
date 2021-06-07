//
//  GCConnectController.h
//  Gay Cities
//
//  Created by Brian Harmann on 5/5/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

typedef enum {
  FBRequestNone,
  FBLoginRequest,
  FBGetUserRequest,
  FBPublishRequest
} GCFBRequestCurrent;

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "FBRequest.h"
#import "SA_OAuthTwitterController.h"
#import "GCConnectControllerDelegate.h"
#import "GCUserLoginDelegate.h"

@class GCCommunicator;
@class GayCitiesAppDelegate;
@class SA_OAuthTwitterEngine;
@class GCListing;

@interface GCConnectController : NSObject <FBRequestDelegate, FBSessionDelegate, FBDialogDelegate, SA_OAuthTwitterControllerDelegate, GCUserLoginDelegate>{
	GayCitiesAppDelegate *gcad;
	GCCommunicator *communicator;
	Facebook *facebook;
	BOOL hasSavedTwitter, hasSavedFacebook, fbExtendedPermission, twitterLoginSucessful, twitterCredentialsUploaded, fbCredentialsUploaded, checkPermissionsSilent, hasSavedFoursquare;
	NSString *twitterUsername, *twitterConnectionID, *postingURL;
	NSObject<GCConnectControllerDelegate> *connectionDelegate;
	SA_OAuthTwitterEngine				*engine;
	id findFriendsDelegate;
  GCFBRequestCurrent currentFBRequest;
}

@property (nonatomic, assign) GayCitiesAppDelegate *gcad;
@property (nonatomic, assign) GCCommunicator *communicator;
@property (nonatomic, assign) Facebook *facebook;
@property (nonatomic, copy) NSString *twitterUsername, *twitterConnectionID, *postingURL;
@property (nonatomic, assign) NSObject<GCConnectControllerDelegate> *connectionDelegate;
@property (nonatomic, readonly) BOOL hasSavedTwitter, hasSavedFacebook, fbExtendedPermission, twitterLoginSucessful, checkPermissionsSilent, hasSavedFoursquare;
@property (nonatomic, readwrite) BOOL twitterCredentialsUploaded, fbCredentialsUploaded;
@property (nonatomic, assign) id findFriendsDelegate;


- (void)signInOrLogoutFacebook;
- (void)signInOrLogoutTwitter;
- (void)signInOrLogoutFoursquare:(UIViewController *)senderViewController;
- (void)logoutFBConnect;
- (void)setFoursquareToken:(NSString *)token;
- (void)checkForFoursquareTokenWithStatus:(BOOL)flag;

- (BOOL)twitterIsAuthorized;
- (void)checkTwitterCredentials;
- (void)sendTwitterUpdate:(NSString *)twitterUpdate;
- (void)sendFBMessage:(NSMutableDictionary *)params;
- (void)sendFoursquareUpdate:(id)venue shout:(NSString *)shout;
- (void)sendSocialData;

- (NSString *)facebook_uid;
- (NSString *)facebook_token;
- (void)logoutOfAccounts;

@end
