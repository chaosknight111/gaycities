//
//  GCConnectController.m
//  Gay Cities
//
//  Created by Brian Harmann on 5/5/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCConnectController.h"
#import "GayCitiesAppDelegate.h"
#import "GCCommunicator.h"
#import "SA_OAuthTwitterEngine.h"
#import "GCFindPeopleViewController.h"
#import "GCFoursquareWebViewController.h"
#import "ASIHTTPRequest.h"
#import "GCListing.h"
#import "OCConstants.h"

#define kOAuthConsumerKey				@"JHfAOMzHsLNPMaIU2cemg"
#define kOAuthConsumerSecret			@"FUIoCYkSCyiVLZJa546z03y6DBuiIuOM5iGXcDWgSs"


@implementation GCConnectController

@synthesize gcad, communicator, facebook;
@synthesize twitterUsername, twitterConnectionID;
@synthesize connectionDelegate;
@synthesize hasSavedTwitter, hasSavedFacebook, fbExtendedPermission, twitterLoginSucessful, hasSavedFoursquare;
@synthesize postingURL;
@synthesize twitterCredentialsUploaded, fbCredentialsUploaded;
@synthesize findFriendsDelegate;
@synthesize checkPermissionsSilent;


- (id)init {
	
	if (self = [super init]) {
    checkPermissionsSilent = NO;
		gcad = [GayCitiesAppDelegate sharedAppDelegate];
		communicator = [GCCommunicator sharedCommunicator];

		engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
		engine.consumerKey = kOAuthConsumerKey;
		engine.consumerSecret = kOAuthConsumerSecret;
		
		hasSavedTwitter = NO;
		
		twitterLoginSucessful = NO;
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		twitterCredentialsUploaded = [defaults boolForKey:gcTwitterCredentialsSentKey];
		fbCredentialsUploaded = [defaults boolForKey:gcFacebookCredentialsSentKey];
		fbExtendedPermission = [defaults boolForKey:fbConnectExtendedPermissionGranted];
		self.twitterUsername = [defaults stringForKey:gcTwitterUsernameKey];
		NSString *twitterOAuth = [defaults stringForKey: gcTwitterOAuthDataKey];
		if ([twitterOAuth length] > 0 && [twitterUsername length] > 0) {
			hasSavedTwitter = YES;
		}
    if ([[defaults objectForKey:@"gcfbAccessToken"] length] > 0) {
      facebook = [[Facebook alloc] initWithAppId:fbAPPID andDelegate:self];
      facebook.accessToken    = [defaults stringForKey:@"gcfbAccessToken"];
      facebook.expirationDate = (NSDate *)[defaults objectForKey:@"gcfbExpirationDate"];
      if ([facebook isSessionValid] == NO) {
        hasSavedFacebook = NO;
      } else {
        hasSavedFacebook = YES;
      }
    } else {
      facebook = [[Facebook alloc] initWithAppId:fbAPPID andDelegate:self];
      hasSavedFacebook = NO;
    }
    
    if ([[defaults objectForKey:gcFoursquareTokenKey] length] > 0) {
      hasSavedFoursquare = YES;
    } else {
      hasSavedFoursquare = NO;
		[self checkForFoursquareTokenWithStatus:NO];
    }
    
		connectionDelegate = nil;
		self.twitterConnectionID = nil;
		
		postingURL = nil;
    currentFBRequest = FBRequestNone;
	}
	
	return self;
}



- (void)dealloc {
	[gcad showAdsAndTabbarAgain];

	self.twitterUsername = nil;
//	if (facebook) {
//		[session.delegates removeObject: self];
//	}
	[facebook release];
	self.twitterConnectionID = nil;
	self.postingURL = nil;
	if (engine) {
		[engine release];
	}
    [super dealloc];
}



- (void)signInOrLogoutFacebook
{
	if (hasSavedFacebook) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Sign Out" message:@"Are you sure you want to sign out of your facebook account?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
		alert.tag = 20;
		[alert show];
		[alert release];
    currentFBRequest = FBRequestNone;
	} else {
//		[gcad.mainTabBar setHidden:YES];
//		[gcad.adBackgroundView setHidden:YES];
//		gcad.shouldShowAdView = NO;
		[facebook authorize:[NSArray arrayWithObjects:@"publish_stream", @"friends_events", @"offline_access", @"user_hometown", @"user_location",  @"user_birthday", @"user_checkins", nil]]; 
    currentFBRequest = FBLoginRequest;
	}
	
	
	
}

- (void)signInOrLogoutTwitter
{
	
	if (![engine isAuthorized] && !hasSavedTwitter) {
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: engine delegate: self];
	
		if (controller) {
			[gcad.mainTabBar setHidden:YES];
			[gcad.adBackgroundView setHidden:YES];
			gcad.shouldShowAdView = NO;
			if (gcad.navigationController.topViewController.modalViewController) {
				[gcad.navigationController.topViewController.modalViewController presentModalViewController: controller animated: YES];
			} else {
				[gcad.navigationController.topViewController  presentModalViewController: controller animated: YES];
			}
			
			

		}
		/*else {
			[engine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
		}*/
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Sign Out" message:@"Are you sure you want to sign out of your twitter account?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
		alert.tag = 10;
		[alert show];
		[alert release];
		
		
	}
	
	
	
}

- (void)signInOrLogoutFoursquare:(UIViewController *)senderViewController {
  if (hasSavedFoursquare) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Foursquare Sign Out" message:@"Are you sure you want to sign out of your Foursquare account?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
		alert.tag = 40;
		[alert show];
		[alert release];
  } else {
//#warning *****Check if there is a reason this isn't being released*****
	  
	  if (!communicator.ul.currentLoginStatus) {
		  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Required" message:@"You need to login with your GayCities account before connecting with Foursquare" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		  [alert show];
		  [alert release];
		  return;
	  }
    
    GCFoursquareWebViewController	*webViewController = [[GCFoursquareWebViewController alloc] initWithNibName:@"GCFoursquareWebViewController" bundle:nil];
    [[senderViewController navigationController] pushViewController:webViewController animated:YES];
    [webViewController autorelease];
  }

}

- (void)setFoursquareToken:(NSString *)token {
  if ([token length] > 0) {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:gcFoursquareTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    hasSavedFoursquare = YES;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In Successful!" message:@"You are now signed into your Foursquare account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//		[alert show];
//		[alert release];
    [[NSNotificationCenter defaultCenter] postNotificationName:gcFoursquareLoginStatusSuccess object:nil];

  } else {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:gcFoursquareTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    hasSavedFoursquare = NO;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In Error" message:@"You are not signed into foursquare." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//		[alert show];
//		[alert release];
    [[NSNotificationCenter defaultCenter] postNotificationName:gcFoursquareLoginStatusNone object:nil];

  }
  
//  if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(twitterUpdateFinished:)]) {
//    [connectionDelegate twitterUpdateFinished:NO];
//  }
  
}

- (void)checkForFoursquareTokenWithStatus:(BOOL)flag
{
	self.communicator.ul.delegate = self;
	[self.communicator.ul checkFoursquareLoginWithStatus:flag];
}

- (void)foursquareTokenResult:(NSString *)token
{
	[self setFoursquareToken:token];
	self.communicator.ul.delegate = self.communicator;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 10) {
		if (buttonIndex == 1) {
			NSLog(@"twitter logout YES");
			[engine clearAccessToken];
			hasSavedTwitter = NO;
			twitterLoginSucessful = NO;
			self.twitterUsername = @"";
			twitterCredentialsUploaded = NO;
			
			NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
			
			[defaults setObject:@"" forKey: gcTwitterOAuthDataKey];
			[defaults setObject:@"" forKey:gcTwitterUsernameKey];
			[defaults setObject:@"0" forKey:gcTwitterCredentialsSentKey];
			[defaults synchronize];
      [[NSNotificationCenter defaultCenter] postNotificationName:gcTwitterLoginStatusNone object:nil];
		} else {
			NSLog(@"twitter logout Cancel/No");
		}
	} else if (alertView.tag == 20) {
		if (buttonIndex == 1) {
			NSLog(@"facebook logout YES");
			[self logoutFBConnect];
			currentFBRequest = FBRequestNone;
		} else {
			NSLog(@"facebook logout Cancel/No");
		}
	} else if (alertView.tag == 30) {
		[self sendSocialData];
	} else if (alertView.tag == 40) {
    if (buttonIndex == 1) {
			NSLog(@"foursquare logout YES");
      NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
      [defaults setObject:@"" forKey:gcFoursquareTokenKey];
      [defaults synchronize];
      hasSavedFoursquare = NO;
      [[NSNotificationCenter defaultCenter] postNotificationName:gcFoursquareLoginStatusNone object:nil];
    }
	}
	
	
	
	
}

- (void)logoutOfAccounts
{
	if ([engine isAuthorized] && hasSavedTwitter) {
		NSLog(@"twitter logout YES");
		[engine clearAccessToken];
		hasSavedTwitter = NO;
		twitterLoginSucessful = NO;
		self.twitterUsername = @"";
		twitterCredentialsUploaded = NO;
		
		NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
		
		[defaults setObject:@"" forKey: gcTwitterOAuthDataKey];
		[defaults setObject:@"" forKey:gcTwitterUsernameKey];
		[defaults setObject:@"0" forKey:gcTwitterCredentialsSentKey];
		[defaults synchronize];
	}
	
	if (hasSavedFacebook) {
		[self logoutFBConnect];
	}
  
  if (hasSavedFoursquare) {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:gcFoursquareTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    hasSavedFoursquare = NO;
  }
}

- (void)sendSocialData
{
	
	
	if (!twitterCredentialsUploaded && hasSavedTwitter) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *twitterOAuth = [defaults objectForKey:gcTwitterOAuthDataKey];
		NSString *twitterOAuthToken = nil;
		NSString *twitterOAuthSecret = nil;
		NSString *twitterID = nil;
		NSArray	*tuples = [twitterOAuth componentsSeparatedByString: @"&"];
		if (tuples.count < 1) {
			return;
		}
		
		for (NSString *tuple in tuples) {
			NSArray *keyValueArray = [tuple componentsSeparatedByString: @"="];
			
			if (keyValueArray.count == 2) {
				NSString				*key = [keyValueArray objectAtIndex: 0];
				NSString				*value = [keyValueArray objectAtIndex: 1];
				
				if ([key isEqualToString:@"oauth_token"]) {
					twitterOAuthToken = value;
				}
				
				if ([key isEqualToString:@"user_id"]) {
					twitterID = value;
				}
				
				if ([key isEqualToString:@"oauth_token_secret"]) {
					twitterOAuthSecret = value;
				}
			}
		}
		
		if ([twitterUsername length] > 0 && [twitterOAuthToken length] > 0 && [twitterID length] > 0 && [twitterOAuthSecret length] > 0) {
			[communicator.ul submitTwitterInfoWithUsername:twitterUsername oAuth:twitterOAuthToken andID:twitterID andSecret:twitterOAuthSecret];
		}
		
	}
	
	if (!fbCredentialsUploaded && hasSavedFacebook) {
		NSString *fb_uid = [self facebook_uid];
		NSString *fb_session = [facebook accessToken];
		
		
		if ([fb_uid length] > 0 && [fb_session length] > 0) {
			[communicator.ul submitFacebookInfoWithSession:fb_session andfbUID:fb_uid];
		}
		
	}
	
}

- (NSString *)facebook_uid
{
	NSString *fb_uid = [[NSUserDefaults standardUserDefaults] stringForKey:fbConnectUserIDKey];
//  NSLog(@"facebook UserId: %@", fb_uid);
	if (fb_uid) {
		return fb_uid;
	}
	return @"";
}
- (NSString *)facebook_token
{
	NSString *fb_session = [facebook accessToken];
//  NSLog(@"facebook Token: %@", fb_session);
	if (fb_session) {
		return fb_session;
	}
	return @"";
}

#pragma mark FBConnect Delegates



- (void)logoutFBConnect
{
	[facebook logout:self];	
  [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"gcfbAccessToken"];
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
	facebook.accessToken = accessToken;
	facebook.expirationDate = expiresAt;
	[[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"gcfbAccessToken"];
	[[NSUserDefaults standardUserDefaults] setObject:expiresAt forKey:@"gcfbExpirationDate"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	fbCredentialsUploaded = NO;
	[self sendSocialData];
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"gcfbAccessToken"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"gcfbExpirationDate"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	fbCredentialsUploaded = NO;
	hasSavedFacebook = NO;
	fbExtendedPermission = NO;
}


/**
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser,
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url {
  //TODO: use internal browser
  return YES;
}


- (void)dialogDidComplete:(FBDialog *)dialog {

	NSLog(@"FBDialog succeeded");
	if (currentFBRequest == FBPublishRequest) {
    
  }
  currentFBRequest = FBRequestNone;
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
//	NSLog(@"FBDialog cancel");
  currentFBRequest = FBRequestNone;
}
  
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
  NSLog(@"FBDialog error:%@", [error localizedDescription]);
  currentFBRequest = FBRequestNone;
}


- (void)fbDidLogin {
	NSLog(@"fb User logged in.");
  [[NSUserDefaults standardUserDefaults] setObject:self.facebook.accessToken forKey:@"gcfbAccessToken"];
  [[NSUserDefaults standardUserDefaults] setObject:self.facebook.expirationDate forKey:@"gcfbExpirationDate"];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fbConnectExtendedPermissionGranted];
  hasSavedFacebook = YES;
  fbExtendedPermission = YES;
  [[NSUserDefaults standardUserDefaults] synchronize];
	
  [[NSNotificationCenter defaultCenter] postNotificationName:gcFacebookLoginStatusSuccess object:nil];
  currentFBRequest = FBGetUserRequest;
  [facebook requestWithGraphPath:@"me" andDelegate:self];
  
  if (findFriendsDelegate) {
    if ([findFriendsDelegate respondsToSelector:@selector(didSignInToFacebook:)]) {
      [(GCFindPeopleViewController *)findFriendsDelegate didSignInToFacebook:YES];
    }
  }
  self.findFriendsDelegate = nil;
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"fb Session did not login");
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  hasSavedFacebook = NO;
  fbExtendedPermission = NO;
  [defaults setBool:NO forKey:fbConnectExtendedPermissionGranted];
  [defaults setObject:@"" forKey:fbConnectUserIDKey];
	fbCredentialsUploaded = NO;
	[defaults setObject:@"0" forKey:gcFacebookCredentialsSentKey];
	[defaults synchronize];
  [[NSNotificationCenter defaultCenter] postNotificationName:gcFacebookLoginStatusNone object:nil];
		
	if (findFriendsDelegate) {
		if ([findFriendsDelegate respondsToSelector:@selector(didSignInToFacebook:)]) {
			[(GCFindPeopleViewController *)findFriendsDelegate didSignInToFacebook:NO];
			
		}
	}
  self.findFriendsDelegate = nil;
  
  currentFBRequest = FBRequestNone;

}

- (void)fbDidLogout {
  hasSavedFacebook = NO;
	fbExtendedPermission = NO;
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
  
	[defaults setBool:NO forKey:fbConnectExtendedPermissionGranted];
  
	NSLog(@"Logout facebook successful");
	[defaults setObject:@"" forKey:fbConnectUserIDKey];
	fbCredentialsUploaded = NO;
	[defaults setObject:@"0" forKey:gcFacebookCredentialsSentKey];
	[defaults synchronize];
  
	[[NSNotificationCenter defaultCenter] postNotificationName:gcFacebookLoginStatusNone object:nil];
  currentFBRequest = FBRequestNone;
}


- (void)request:(FBRequest*)request didLoad:(id)result
{
	NSLog(@"GC FB result: %@", result);
  [[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];

  if (currentFBRequest == FBLoginRequest) {
    
  } else if (currentFBRequest == FBPublishRequest) {
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(facebookUpdateFinished:)]) {
      [connectionDelegate facebookUpdateFinished:YES];
    }
  } else if (currentFBRequest == FBGetUserRequest) {
    if ([result isKindOfClass:[NSDictionary class]]) {
      NSString *fbUID = [result objectForKey:@"id"];
      if (fbUID) [[NSUserDefaults standardUserDefaults] setObject:fbUID forKey:fbConnectUserIDKey];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self sendSocialData];
  }
  
  currentFBRequest = FBRequestNone;

	// facebook.Users.hasAppPermission
	
//	if ([request.httpMethod isEqualToString:@"facebook.Users.hasAppPermission"]) {
//		if ([(NSNumber *)result intValue] == 1) {
//			if (!fbExtendedPermission) {
//			}
  
  
  
  
//      }
			
//		} else {
//			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:fbConnectExtendedPermissionGranted];
//			fbExtendedPermission = NO;
//
//			if (!checkPermissionsSilent) {
//        /*
//        FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
//        dialog.delegate = self;
//        dialog.permission = @"publish_stream,user_events,offline_access,user_hometown,user_location,user_birthday,user_checkins";
//        [dialog show];
//         */
//        checkPermissionsSilent = NO;
//      }
//			
//			
//			return;
//		}
//	} else if ([request.httpMethod isEqualToString:@"facebook.Stream.publish"]) {
//		if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(facebookUpdateFinished:)]) {
//			[connectionDelegate facebookUpdateFinished:YES];
//		}
//		return;
//		
//	} else if ([request.httpMethod isEqualToString:@"facebook.fql.query"]) {
//		[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
//		NSArray* users = result;
//		if ([users count] > 0) {
//			NSDictionary* user = [users objectAtIndex:0];
//			NSString* name = [user objectForKey:@"name"];
//			if (name) {
//				NSLog(@"FB Query returned %@", name);
//				[[NSUserDefaults standardUserDefaults] setObject:name forKey:fbConnectUsernameKey];
//			}
//		}
//	} else {
//		[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
//	}
	
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
	[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
	NSLog(@"FBRequest failed: %@\n\n%@", [error userInfo], [error description]);
  
  if (currentFBRequest == FBLoginRequest) {
    
  } else if (currentFBRequest == FBPublishRequest) {
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(facebookUpdateFinished:)]) {
      [connectionDelegate facebookUpdateFinished:NO];
    }
  } else if (currentFBRequest == FBGetUserRequest) {
    
  }
  [facebook logout:self];
  
  currentFBRequest = FBRequestNone;
}



-(void)sendFBMessage:(NSMutableDictionary *)params
{
  currentFBRequest = FBPublishRequest;

	if ([params count] > 0) {
		NSLog(@"Send fb message");
    //[facebook requestWithMethodName:@"stream.publish" andParams:params andHttpMethod:@"POST" andDelegate:self];
		[facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];

    //		[facebook dialog:@"feed"
//            andParams:params
//          andDelegate:self];
		//[[FBRequest requestWithDelegate:self] call:@"facebook.Stream.publish" params:params];
	}
	
}

/*
 - (void)getFBUserName 
 {
 [[GayCitiesAppDelegate sharedAppDelegate] showProcessing:@"Getting Facebook Username..."];
 NSString* fql = @"select name from user where uid == 1234";
 NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
 [[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
 }
 
 */


#pragma mark Foursquare

- (void)sendFoursquareUpdate:(id)venue shout:(NSString *)shout {
  NSString *token = [communicator.foursquareController foursquareToken];
  if (!token || [token length] == 0) {
    NSLog(@"Send FS message but no token");
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(foursquareUpdateFinished:response:)]) {
      [connectionDelegate foursquareUpdateFinished:NO response:nil];
    }
    return;
  }
  //client_id=%@&client_secret=%@&
  //GCFoursquareClientID    GCFoursquareSecret
  
  NSString *finalURL = nil;
  NSMutableString *URL = [NSMutableString stringWithFormat:@"%@checkins/add?oauth_token=%@&broadcast=public", kFoursquareVenueURL, token];

  
  
  if ([venue isKindOfClass:[GCListing class]]) {
    GCListing *listing = (GCListing *)venue;
    if ([shout length] > 0) {
      [URL appendFormat:@"&shout=%@", shout];
    }
    
    if (listing) {
      if (listing.foursquareId) [URL appendFormat:@"&venueId=%@", listing.foursquareId];
      
      if (listing.name) [URL appendFormat:@"&venue=%@", listing.name];
      
      if (listing.lat && listing.lng) [URL appendFormat:@"&ll=%@,%@", listing.lat, listing.lng];
      else if (communicator.currentLocation) {
        [URL appendFormat:@"&ll=%f,%f", communicator.currentLocation.coordinate.latitude, communicator.currentLocation.coordinate.longitude];
      } else if (communicator.previousLocation) {
        [URL appendFormat:@"&ll=%f,%f", communicator.previousLocation.coordinate.latitude, communicator.previousLocation.coordinate.longitude];
      }
    }
  } else if ([venue isKindOfClass:[NSDictionary class]]) {
    NSDictionary *event = (NSDictionary *)venue;

    if ([shout length] > 0) {
      [URL appendFormat:@"&shout=%@", shout];
    }
    
    if (event) {
//      if (listing.foursquareId) [URL appendFormat:@"&venueId=%@", listing.foursquareId];
      
      if ([event objectForKey:@"name"]) [URL appendFormat:@"&venue=%@", [event objectForKey:@"name"]];
      
      if (communicator.currentLocation) {
        [URL appendFormat:@"&ll=%f,%f", communicator.currentLocation.coordinate.latitude, communicator.currentLocation.coordinate.longitude];
      } else if (communicator.previousLocation) {
        [URL appendFormat:@"&ll=%f,%f", communicator.previousLocation.coordinate.latitude, communicator.previousLocation.coordinate.longitude];
      }
//      if (listing.lat && listing.lng) [URL appendFormat:@"&ll=%@,%@", listing.lat, listing.lng];
    }
  }
  
  finalURL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSLog(@"FS Final URL: %@", finalURL);
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:finalURL]];
  [request setRequestMethod:@"POST"];
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(requestFinished:)];
  [request setDidFailSelector:@selector(requestFailed:)];
  NSOperationQueue *queue = communicator.downloadQueue;
  [queue addOperation:request];

}

- (void)requestFinished:(ASIHTTPRequest *)request {
  NSString *response = [request responseString];
  NSLog(@"FS Success Post Response: %@", response);
//  NSLog(@"FS Post Success");
  if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(foursquareUpdateFinished:response:)]) {
    [connectionDelegate foursquareUpdateFinished:YES response:response];
  }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
  NSLog(@"FS Post Failed");

  if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(foursquareUpdateFinished:)]) {
    [connectionDelegate foursquareUpdateFinished:NO response:nil];
  }
}

#pragma mark Twitter OAuth

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) aUsername {
	NSLog(@"Store twitter oauth data for username %@\n%@", aUsername, data);
	if (aUsername && data){
		NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject: data forKey: gcTwitterOAuthDataKey];
		[defaults setObject:aUsername forKey:gcTwitterUsernameKey];
		[defaults synchronize];
		hasSavedTwitter = YES;
		self.twitterUsername = aUsername;
	}
	
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) aUsername {
	NSLog(@"fetch & return twitter oauth data for username %@", aUsername);
  NSString *data = [[NSUserDefaults standardUserDefaults] objectForKey: gcTwitterOAuthDataKey];
  if (!data) hasSavedTwitter = NO;
	return data;
}

- (void) twitterOAuthConnectionFailedWithData: (NSData *) data {
  if (!data) return;
  
  NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
  NSLog(@"OAuth Request failed: %@", dataString);

}
//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) aUsername {
	NSLog(@"Twitter Authenicated for %@", aUsername);
	hasSavedTwitter = YES;
	twitterLoginSucessful = YES;
	
	NSString *pin = engine.pin;
	if (pin) {
		NSLog(@"Twitter Pin: %@", pin);
	}
	NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:aUsername forKey:gcTwitterUsernameKey];
	self.twitterUsername = aUsername;
	[defaults synchronize];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"You have sucessfully signed into Twitter as %@", twitterUsername] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	alert.tag = 30;
	[alert show];
	[alert release];
	[[NSNotificationCenter defaultCenter] postNotificationName:gcTwitterLoginStatusSuccess object:nil];

	
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"TWITTER Authentication Failed!");
	hasSavedTwitter = NO;
	twitterLoginSucessful = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:gcTwitterLoginStatusNone object:nil];

}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"TWITTER Authentication Canceled.");
	hasSavedTwitter = NO;
	twitterLoginSucessful = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:gcTwitterLoginStatusNone object:nil];

}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"TWITTER Request %@ succeeded", requestIdentifier);
	if ([twitterConnectionID isEqualToString:requestIdentifier]) {
		self.twitterConnectionID = nil;
		if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(twitterUpdateFinished:)]) {
			[connectionDelegate twitterUpdateFinished:YES];
		}
	}
	
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"TWITTER Request %@ failed with error: %@\n\n%@", requestIdentifier, [error userInfo], [error description]);
	
	if ([twitterConnectionID isEqualToString:requestIdentifier]) {
		self.twitterConnectionID = nil;
		if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(twitterUpdateFinished:)]) {
			[connectionDelegate twitterUpdateFinished:NO];
		}
	}
  if ([error code] == 403) {
    [engine clearAccessToken];
    hasSavedTwitter = NO;
		twitterLoginSucessful = NO;
  }
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
	NSLog(@"TWITTER Got statuses for %@", connectionIdentifier);
	[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
	
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier
{
	NSLog(@"TWITTER Got direct messages for %@", connectionIdentifier);
	[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
	
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier
{
	NSLog(@"TWITTER Got user info for %@\n\n%@", connectionIdentifier, userInfo);
	[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];


	
}


#pragma mark GC TWITTER Methods

- (BOOL)twitterIsAuthorized
{
  if (!hasSavedTwitter) {
    NSLog(@"twitter NOT saved");
    return NO;
  } else if (![engine isAuthorized]) {
		NSLog(@"twitter NOT Authorized");
		return NO;
	}
	NSLog(@"twitter saved");
	return YES;
}

- (void)checkTwitterCredentials
{
	NSLog(@"TWITTER just quickly verify they are still valid and if so, remember for the whole session");
	if (hasSavedTwitter && !twitterLoginSucessful) {
		[[GayCitiesAppDelegate sharedAppDelegate] showProcessing:@"Checking Twitter Login..."];

		[engine checkUserCredentials];
	} else {
		hasSavedTwitter = NO;
		twitterLoginSucessful = NO;
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: engine delegate: self];
		
		if (controller) {
			[gcad.mainTabBar setHidden:YES];
			[gcad.adBackgroundView setHidden:YES];
			gcad.shouldShowAdView = NO;
			if (gcad.navigationController.topViewController.modalViewController) {
				[gcad.navigationController.topViewController.modalViewController presentModalViewController: controller animated: YES];
			} else {
				[gcad.navigationController.topViewController  presentModalViewController: controller animated: YES];
			}
		} else {
			NSLog(@"check twitter login - I shouldnt get here...");
		}

	}
}

- (void)sendTwitterUpdate:(NSString *)twitterUpdate
{	
	if (twitterUpdate) {
	
		self.twitterConnectionID = [engine sendUpdate:twitterUpdate];
	} else {
		self.twitterConnectionID = nil;
		if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(twitterUpdateFinished:)]) {
			[connectionDelegate twitterUpdateFinished:NO];
		}
	}
			
}
	




@end