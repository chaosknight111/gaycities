//
//  OCConstants.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/28/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCNSStringExtras.h"

//extern NSString *		const kWebTypeAttribute;
extern NSUInteger		const gcStartupKeyLastLocation;
extern NSUInteger		const gcStartupKeyCurrentLocation;
extern NSUInteger		const listingsAction;
extern NSUInteger		const startupAction;
extern NSUInteger		const locateAction;
extern float			const kDefaultCheckinDistance;

extern NSUInteger		const requiredSelectionViewType;
extern NSUInteger		const optionalSelectionViewType;

extern NSString *		const fbAPIKey;
extern NSString *		const fbSecret;
extern NSString *   const fbAPPID;
extern NSString *		const firstLaunch;
extern NSString *		const gc25FirstLaunch;
extern NSString *		const gc25DetailIndexCreated;
extern NSString *		const gc25ReviewIndexCreated;
extern NSString *		const fbConnectExtendedPermissionGranted;
extern NSString *		const fbConnectUserIDKey;
extern NSString *		const fbConnectUsernameKey;

extern NSString *		const gcTwitterUsernameKey;
extern NSString *		const gcTwitterUserDictionaryKey;

extern NSString *		const gcSavedLatitude;
extern NSString	*		const gcSavedLongitude;
extern NSString *		const gcSavedHomeMetro;
extern NSString *		const gcSavedPreviousMetro;
extern NSString *		const gcShownServerMessages;
extern NSString *		const gcPendingServerMessages;

extern NSString *		const gcUserProfileInformation;
extern NSString *		const gcUserProfileImageDataFile;
extern NSString *		const gcStartupTabSelected;

extern NSString *		const gcCheckinListingsLoadedNotification;
extern NSString *		const gcProfileDetailsUpdated;
extern NSString *		const gcCellImageUpdatedForPersonNotification;
extern NSString *		const gcCellImageUpdatedForFindFriendNotification;
extern NSString *		const gcCellImageUpdatedForEventNotification;

extern NSString *		const gcFacebookLoginStatusSuccess;
extern NSString *		const gcTwitterLoginStatusSuccess;
extern NSString *		const gcFacebookLoginStatusNone;
extern NSString *		const gcTwitterLoginStatusNone;
extern NSString *		const gcFoursquareLoginStatusSuccess;
extern NSString *		const gcFoursquareLoginStatusNone;

extern NSString *		const gcTwitterOAuthDataKey;
extern NSString *		const gcTwitterCredentialsSentKey;
extern NSString *		const gcFacebookCredentialsSentKey;
extern NSString *		const gcFoursquareTokenKey;

extern NSString *		const gc32DatabaseUpdateComplete;

extern NSString *		const gcRecentMetrosKey;

// The above is a great example of me not knowing what I was doing...
// TODO: replace above with proper defines etc... where needed.

#define kFoursquareVenueURL @"https://api.foursquare.com/v2/"
#define GCFoursquareClientID @"LSUTR4SEWTCRFIKSO00H5YNDCCSY0GOY0OUKZMX0AACYP4GO"
#define GCFoursquareSecret @"CI0NQVTOCVTM33FM3BAJEN0IVL3GTDWX0VUTMBRTIQEXL0BZ"

@interface OCConstants : NSObject {

}

+ (UIImage *)imageForType:(NSString *)type;
+ (UIImage *)starsForRating:(float)stars;
+ (UIImage *)typeImageForType:(NSString *)type;
+ (UIImage *)reviewStarsForRating:(float)stars;
+ (NSString *)monthForNumber:(int)monthNumber;

@end
