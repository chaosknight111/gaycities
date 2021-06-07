//
//  OCConstants.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/28/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "OCConstants.h"

//NSString *		const kWebTypeAttribute		= @"kWebTypeAttribute";
NSUInteger			const gcStartupKeyLastLocation = 1;
NSUInteger			const gcStartupKeyCurrentLocation = 0;
float				const kDefaultCheckinDistance = 1.5;  //1.5

NSUInteger			const listingsAction = 2;
NSUInteger			const startupAction = 3;
NSUInteger			const locateAction = 4;

NSUInteger		const requiredSelectionViewType = 1;
NSUInteger		const optionalSelectionViewType = 2;

NSString *		const fbAPIKey = @"b18ecff22f69423c5e07fcaf5d5268fb";
NSString *		const fbSecret = @"083fa2ab1fb1809ffb55a02ba084bf91";
NSString *    const fbAPPID = @"203568195269";

NSString *		const firstLaunch = @"firstLaunch";
NSString *		const gc25FirstLaunch = @"gc25FirstLaunch";
NSString *		const gc25DetailIndexCreated = @"gc25DetailIndexCreated";
NSString *		const gc25ReviewIndexCreated = @"gc25ReviewIndexCreated";
NSString *		const fbConnectExtendedPermissionGranted = @"fbConnectExtendedPermissionGranted";
NSString *		const fbConnectUserIDKey = @"gcfbConnectUserID";
NSString *		const fbConnectUsernameKey = @"fbConnectUsername";
NSString *		const gcTwitterUsernameKey = @"gcTwitterUsername";
NSString *		const gcTwitterUserDictionaryKey = @"gcTwitterUserDictionary";


NSString *		const gcSavedLatitude = @"gcSavedLatitude";
NSString *		const gcSavedLongitude = @"gcSavedLongitude";
NSString *		const gcSavedHomeMetro = @"gcSavedHomeMetro"; 
NSString *		const gcSavedPreviousMetro = @"gcSavedPreviousMetro"; 
NSString *		const gcShownServerMessages = @"gcShownServerMessages";
NSString *		const gcPendingServerMessages = @"gcPendingServerMessages";

NSString *		const gcUserProfileInformation = @"gcUserProfileInformation";
NSString *		const gcUserProfileImageDataFile = @"gcUserProfileImageDataFile";
NSString *		const gcStartupTabSelected = @"gcStartupTabSelected";

NSString *		const gcFacebookLoginStatusSuccess = @"gcFacebookLoginStatusSuccess";
NSString *		const gcFacebookLoginStatusNone = @"gcFacebookLoginStatusNone";
NSString *		const gcTwitterLoginStatusNone = @"gcTwitterLoginStatusNone";
NSString *		const gcTwitterLoginStatusSuccess = @"gcTwitterLoginStatusSuccess";
NSString *		const gcFoursquareLoginStatusSuccess = @"gcFoursquareLoginStatusSuccess";
NSString *		const gcFoursquareLoginStatusNone = @"gcFoursquareLoginStatusNone";

NSString *		const gcCheckinListingsLoadedNotification = @"gcCheckinListingsLoadedNotification";
NSString *		const gcProfileDetailsUpdated = @"gcProfileDetailsUpdated";
NSString *		const gcCellImageUpdatedForPersonNotification = @"gcCellImageUpdatedForPersonNotification";
NSString *		const gcCellImageUpdatedForFindFriendNotification = @"gcCellImageUpdatedForFindFriendNotification";
NSString *		const gcCellImageUpdatedForEventNotification = @"gcCellImageUpdatedForEventNotification";

NSString *		const gcTwitterOAuthDataKey		= @"gcTwitterOAuthData";

NSString *		const gcTwitterCredentialsSentKey = @"gcTwitterCredentialsSent";
NSString *		const gcFacebookCredentialsSentKey = @"gcFacebookCredentialsSent";
NSString *		const gcFoursquareTokenKey = @"gcFoursquareTokenKey";
NSString *		const gc32DatabaseUpdateComplete = @"gc32DatabaseUpdateComplete";

NSString *		const gcRecentMetrosKey = @"gcRecentMetrosKey";

@implementation OCConstants

+ (UIImage *)imageForType:(NSString *)type
{
	if ([type isEqualToString:@"bars"]) {
		return [UIImage imageNamed:@"bars-marker.png"];
	}
	else if ([type isEqualToString:@"restaurants"]) {
		return [UIImage imageNamed:@"restaurants-marker.png"];
	}
	else if ([type isEqualToString:@"hotels"]) {
		return [UIImage imageNamed:@"hotels-marker.png"];
	}
	else if ([type isEqualToString:@"beaches"]) {
		return [UIImage imageNamed:@"beaches-marker.png"];
	}
	else if ([type isEqualToString:@"arts"]) {
		return [UIImage imageNamed:@"arts-marker.png"];
	}
	else if ([type isEqualToString:@"gyms"]) {
		return [UIImage imageNamed:@"gyms-marker.png"];
	}
	else if ([type isEqualToString:@"bathhouses"]) {
		return [UIImage imageNamed:@"bathhouses-marker.png"];
	}
	else if ([type isEqualToString:@"shops"]) {
		return [UIImage imageNamed:@"shops-marker.png"];
	}
	else if ([type isEqualToString:@"events"]) {
		return [UIImage imageNamed:@"events-marker.png"];
	}
	else if ([type isEqualToString:@"organizations"]) {
		return [UIImage imageNamed:@"organizations-marker.png"];
	}
	else if ([type isEqualToString:@"parking"]) {
		return [UIImage imageNamed:@"parking-marker.png"];
	}
	else if ([type isEqualToString:@"wineries"]) {
		return [UIImage imageNamed:@"wineries-marker.png"];
	}
	else if ([type isEqualToString:@"rentals"]) {
		return [UIImage imageNamed:@"rentals-marker.png"];
	}
	else {
		return [UIImage imageNamed:@"marker-grey.png"]; 
	}
	return [UIImage imageNamed:@"marker-grey.png"]; 
}

+ (UIImage *)typeImageForType:(NSString *)type
{
	NSString *imageName = [NSString stringWithFormat:@"%@.png", type];
	UIImage *image = [UIImage imageNamed:imageName];
	if (!image) {
		return [UIImage imageNamed:@"defaultBrowseIcon.png"];
	}
	return image; 
}

+ (UIImage *)starsForRating:(float)stars
{	
	if (stars < .49) {
		return [UIImage imageNamed:@"0.png"];
	}
	else if (stars >= .49 && stars < 1) {
		return [UIImage imageNamed:@"half.png"];
	}
	else if (stars >= 1 && stars <= 1.49) {
		return [UIImage imageNamed:@"1.png"];
	}
	else if (stars > 1.49 && stars < 2) {
		return [UIImage imageNamed:@"1half.png"];
	}
	else if (stars >= 2 && stars <= 2.49) {
		return [UIImage imageNamed:@"2.png"];
	}
	else if (stars > 2.49 && stars < 3) {
		return [UIImage imageNamed:@"2half.png"];
	}
	else if (stars >= 3 && stars <= 3.49) {
		return [UIImage imageNamed:@"3.png"];
	}
	else if (stars >3.49 && stars < 4) {
		return [UIImage imageNamed:@"3half.png"];
	}
	else if (stars >= 4 && stars <= 4.49) {
		return [UIImage imageNamed:@"4.png"];
	}
	else if (stars > 4.49 && stars < 4.9) {
		return [UIImage imageNamed:@"4half.png"];
	}
	else if (stars >= 4.9) {
		return [UIImage imageNamed:@"5.png"];
	}
	return [UIImage imageNamed:@"0.png"];
}

+ (UIImage *)reviewStarsForRating:(float)stars
{	
	if (stars < .49) {
		return [UIImage imageNamed:@"r-0.png"];
	}
	else if (stars >= .49 && stars < 1) {
		return [UIImage imageNamed:@"r-half.png"];
	}
	else if (stars >= 1 && stars <= 1.49) {
		return [UIImage imageNamed:@"r-1.png"];
	}
	else if (stars > 1.49 && stars < 2) {
		return [UIImage imageNamed:@"r-1half.png"];
	}
	else if (stars >= 2 && stars <= 2.49) {
		return [UIImage imageNamed:@"r-2.png"];
	}
	else if (stars > 2.49 && stars < 3) {
		return [UIImage imageNamed:@"r-2half.png"];
	}
	else if (stars >= 3 && stars <= 3.49) {
		return [UIImage imageNamed:@"r-3.png"];
	}
	else if (stars >3.49 && stars < 4) {
		return [UIImage imageNamed:@"r-3half.png"];
	}
	else if (stars >= 4 && stars <= 4.49) {
		return [UIImage imageNamed:@"r-4.png"];
	}
	else if (stars > 4.49 && stars < 4.9) {
		return [UIImage imageNamed:@"r-4half.png"];
	}
	else if (stars >= 4.9) {
		return [UIImage imageNamed:@"r-5.png"];
	}
	return [UIImage imageNamed:@"r-0.png"];
}


+ (NSString *)monthForNumber:(int)monthNumber
{
	NSString *month = nil;
	
	if (monthNumber >= 1 && monthNumber <=13) {
		switch (monthNumber) {
			case 1:
				month = @"January";
				break;
			case 2:
				month = @"February";
				break;
			case 3:
				month = @"March";
				break;
			case 4:
				month = @"April";
				break;
			case 5:
				month = @"May";
				break;
			case 6:
				month = @"June";
				break;
			case 7:
				month = @"July";
				break;
			case 8:
				month = @"August";
				break;
			case 9:
				month = @"September";
				break;
			case 10:
				month = @"October";
				break;
			case 11:
				month = @"November";
				break;
			case 12:
				month = @"December";
				break;
				

		}
	} else {
		month = @"";
	}
	
	return month;
	
}

@end
