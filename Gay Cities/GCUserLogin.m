//
//  UserLogin.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/13/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCUserLogin.h"
#import <CommonCrypto/CommonDigest.h>
#import "DDXML.h"
#import "GayCitiesAppDelegate.h"
#import "BAUIStarSlider.h"
#import "GCNSStringExtras.h"
#import "OCConstants.h"
#import "GCCommunicator.h"
#import <AddressBook/AddressBook.h>
#import "GCFindPeopleViewController.h"
#import "GCFindFriendPerson.h"
#import "GCSubmitPhotoViewController.h"
#import "GCDataReportVC.h"
#import "GCReviewVC.h"
#import "GCFindPeopleViewController.h"
#import "Flurry.h"

@implementation GCUserLogin

@synthesize reviewListingID, reviewType, reviewYear, reviewMonth;
@synthesize photoListingID, photoType;
@synthesize photoCaption;
@synthesize photo, profileImageSaved;
@synthesize loginChecked, currentLoginStatus;
@synthesize delegate, checkinDelegate;
@synthesize authToken, gcLoginUsername;
@synthesize userProfileInformation;


-(id)init
{
	self = [super init];
	
	
	currentPhotoType = 0;
	reviewVisitedShown = NO;
	loginChecked = NO;
	currentLoginStatus = NO;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if ([[defaults stringForKey:@"authToken"] length] > 0) {
		self.authToken = [defaults stringForKey:@"authToken"];
	} else {
		self.authToken = nil;

	}
	
	if ([[defaults stringForKey:@"gcUserIDKey"] length] > 0) {
		self.gcLoginUsername = [defaults stringForKey:@"gcUserIDKey"];
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"STARTUP-SAVED GC.com login" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:gcLoginUsername, @"GC_USER_NAME", nil]];
	} else {
		self.gcLoginUsername = nil;
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"STARTUP - NO - GC.com login" withParameters:nil];

		
	}
	
	profileImageSaved = nil;

	if ([defaults objectForKey:gcUserProfileInformation]) {
		self.userProfileInformation = [defaults objectForKey:gcUserProfileInformation];
	} else {
		self.userProfileInformation = nil;
	}
	
	if (userProfileInformation) {
		if ([[userProfileInformation objectForKey:@"profile_image_url"] isEqualToString:@"http://www.gaycities.com/images/sm_profile.gif"]) {
			self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
		} else if ([[userProfileInformation objectForKey:@"profile_image_url"] isEqualToString:@"http://www.gaycities.com/images/v3/default_user.png"]) {
			self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
		} else if ([[userProfileInformation objectForKey:@"profile_image_url"] isEqualToString:@"http://gcimg.gaycities.com/v3/default_user.png"]) {
			self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
		} else if ([[userProfileInformation objectForKey:@"profile_image_url"] isEqualToString:@"http://www.gaycities.com/images/v4/default_user.png"]) {
			self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
		} else if ([[userProfileInformation objectForKey:@"profile_image_url"] isEqualToString:@"http://gcimg.gaycities.com/v4/default_user.png"]) {
			self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
		} else if ([[userProfileInformation objectForKey:@"profile_image_url"] isEqualToString:@"http://www.gaycities.com/images/xsm_profile.gif"]) {
			self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
		} else if ([[userProfileInformation objectForKey:@"profile_image_url"] isEqualToString:@"http://www.gaycities.com/images/mini_profile.gif"]) {
			self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
		} else if ([[userProfileInformation objectForKey:@"profile_image_url"] isEqualToString:@"http://www.gaycities.com/images/med_profile.gif"]) {
			self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
		} else if ([[userProfileInformation objectForKey:@"profile_image_url"] isEqualToString:@"http://www.gaycities.com/images/profile.gif"]) {
			self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
		}
	}
	
	if (!profileImageSaved) {
		NSObject *data = [[NSUserDefaults standardUserDefaults] objectForKey:gcUserProfileImageDataFile];
		
		if (data) {
			if ([data isKindOfClass:[NSData class]]) {
				if ([(NSData *)data length] > 0) {
					UIImage *image = [[UIImage alloc] initWithData:(NSData *)data];
					if (image) {
						self.profileImageSaved = image;
						[image release];
					}
				}
			}
		}
	}
	
	
	return self;
}

-(void)resign:(id)sender
{
	[sender resignFirstResponder];
}



-(void)dealloc
{
	delegate = nil;
	checkinDelegate = nil;

	self.reviewListingID = nil;
	self.reviewType = nil;
	self.reviewYear = nil;
	self.reviewMonth = nil;
	self.photoType = nil;
	self.photoListingID = nil;
	self.photo = nil;
	self.authToken = nil;
	self.gcLoginUsername = nil;
	self.userProfileInformation = nil;
	self.profileImageSaved = nil;
	[super dealloc];
}

#pragma mark check login & status

- (BOOL)isSignedIn {
	if (self.authToken && self.gcLoginUsername) {
		return YES;
	}
	return NO;
}

- (void)processNewLogin
{
	[self showProcessing:@"Checking Login..."];
	[NSThread detachNewThreadSelector:@selector(checkLoginThread) toTarget:self withObject:nil];
}

- (void)checkChangedLogin {
  [self showProcessing:@"Checking Login..."];
	[NSThread detachNewThreadSelector:@selector(checkChangedLoginThread) toTarget:self withObject:nil];
}

- (void)checkChangedLoginThread
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSString *status = [NSString stringWithString:[self checkLogin]];
  
	[self performSelectorOnMainThread:@selector(reportChangedLoginResults:) withObject:status waitUntilDone:NO];
	[aPool release];
}

- (void)reportChangedLoginResults:(NSString *)status
{
	[self hideProcessing];
	if ([status isEqualToString:@"OK"]) {
		// Do Nothing
	}
	else if ([status isEqualToString:@"noData"]) {
		[self showAlertWithTitle:@"No Data" message:@"No data was recieved from the server.  Please try again later."];
	}
	else {
		[self showSignInFailedWithMessage:status];
	}
	if ([delegate respondsToSelector:@selector(loginResult:)]) {
		[delegate loginResult:currentLoginStatus];
	} else {
		NSLog(@"User Login Delegate does not respond to loginResult");
	}
}


- (void)checkLoginThread
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSString *status = [NSString stringWithString:[self checkLogin]];

	[self performSelectorOnMainThread:@selector(reportLoginResults:) withObject:status waitUntilDone:NO];
	[aPool release];
}

- (void)reportLoginResults:(NSString *)status
{
	[self hideProcessing];
	if ([status isEqualToString:@"OK"]) {
		[self showAlertWithTitle:@"Sign In Successful!" message:@"You may now use your account"];
		[self performSelectorOnMainThread:@selector(postUpdateNotification:) withObject:@"2" waitUntilDone:NO];
	}
	else if ([status isEqualToString:@"noData"]) {
		[self showAlertWithTitle:@"No Data" message:@"No data was recieved from the server.  Please try again later."];
	}
	else {
		[self showSignInFailedWithMessage:status];
	}
	if ([delegate respondsToSelector:@selector(loginResult:)]) {
		[delegate loginResult:currentLoginStatus];
	} else {
		NSLog(@"User Login Delegate does not respond to loginResult");
	}
}


-(NSString *)checkLogin
{
	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&un=%@&pw=%@&results=json",[defaults objectForKey:@"gcUserIDKey"],[defaults objectForKey:@"gcPasswordKey"]];
	
	NSLog(@"checking login");

	NSMutableData *recievedData = [self sendRequestWithAPI:@"login" andParameters:searchString];
	[searchString release];
	
	if ([recievedData length] <10) {
		NSLog(@"No Data Recieved for login check");
		return @"noData";
	}
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	//NSLog(@"Login Results: %@", tempString);
	
	if (!tempString) {
		NSLog(@"Error for login check - no string");
		return @"noData";
	} else if ([tempString length] < 10) {
		NSLog(@"Error for login check - string length < 10");
		[tempString release];
		return @"noData";
	}
	
	NSMutableDictionary *tempDict = [tempString JSONValueWithStrings];
	[tempString release];
	//NSLog(@"Login Results: %@", tempDict);
	if (!tempDict) {
		NSLog(@"Error for login check - couldnt parse json");
		return @"noData";
	}
	currentLoginStatus = NO;
	loginChecked = YES;
	
	if ([[tempDict objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		[self performSelectorOnMainThread:@selector(setAuthToken:) withObject:[tempDict objectForKey:@"login_token"] waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(setGcLoginUsername:) withObject:[defaults stringForKey:@"gcUserIDKey"] waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(setUserProfileInformation:) withObject:tempDict waitUntilDone:YES];
		//[NSThread detachNewThreadSelector:@selector(getUserProfileImage) toTarget:self withObject:nil];

		if ([[defaults objectForKey:gcUserProfileImageDataFile] length] == 0 && [tempDict objectForKey:@"profile_image_url"]) {
			[NSThread detachNewThreadSelector:@selector(getUserProfileImage) toTarget:self withObject:nil];
		} else if ([[defaults objectForKey:gcUserProfileInformation] objectForKey:@"profile_image_url"] && [tempDict objectForKey:@"profile_image_url"]) {
			if (![[tempDict objectForKey:@"profile_image_url"] isEqualToString:[[defaults objectForKey:gcUserProfileInformation] objectForKey:@"profile_image_url"]]) {
				[NSThread detachNewThreadSelector:@selector(getUserProfileImage) toTarget:self withObject:nil];
			}
			
		}
		
		//self.authToken = [tempDict objectForKey:@"login_token"];
		//self.gcUserIDKey = [defaults stringForKey:@"gcUserIDKey"];
		[defaults setObject:[tempDict objectForKey:@"login_token"] forKey:@"authToken"];
		[defaults setObject:tempDict forKey:gcUserProfileInformation];

		currentLoginStatus = YES;
		
		return @"OK";
		
	} else {
		[defaults setObject:@"" forKey:@"authToken"];
		[defaults setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"gender", @"", @"age", @"", @"profile_image_url", @"", @"city", @"", @"state", nil] forKey:gcUserProfileInformation];
		[defaults setObject:[NSData data] forKey:gcUserProfileImageDataFile];
		[defaults synchronize];

		[self performSelectorOnMainThread:@selector(setAuthToken:) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(setGcLoginUsername:) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(setUserProfileInformation:) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(setProfileImageSaved:) withObject:nil waitUntilDone:YES];

		//self.authToken = nil;
		//self.gcUserIDKey = nil;
		NSLog(@"Login Failed");
		[self performSelectorOnMainThread:@selector(postUpdateNotification:) withObject:@"0" waitUntilDone:NO];

		return [tempDict objectForKey:@"message"];
	}
	return @"error";
}

- (BOOL)checkLoginReturningBOOLThread;
{
	if (loginChecked) {
		return currentLoginStatus;
	}
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSString *status = [NSString stringWithString:[self checkLogin]];

	
	if ([status isEqualToString:@"OK"]) {
		[aPool release];
		return YES;
	}
	
	//other option is failed with message as key
	[aPool release];
	return NO;
	
}

- (void)getUserProfileImage
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	if (userProfileInformation) {
		if ([userProfileInformation objectForKey:@"profile_image_url"]) {
			if ([[userProfileInformation objectForKey:@"profile_image_url"] length] > 0) {
				NSString *photoURL = [userProfileInformation objectForKey:@"profile_image_url"];
				if ([photoURL isEqualToString:@"http://www.gaycities.com/images/sm_profile.gif"] || 
					[photoURL isEqualToString:@"http://www.gaycities.com/images/v3/default_user.png"] || 
					[photoURL isEqualToString:@"http://gcimg.gaycities.com/v3/default_user.png"] || 
					[photoURL isEqualToString:@"http://www.gaycities.com/images/v4/default_user.png"] || 
					[photoURL isEqualToString:@"http://gcimg.gaycities.com/v4/default_user.png"] || 
					[photoURL isEqualToString:@"http://www.gaycities.com/images/xsm_profile.gif"] || 
					[photoURL isEqualToString:@"http://www.gaycities.com/images/mini_profile.gif"] || 
					[photoURL isEqualToString:@"http://www.gaycities.com/images/med_profile.gif"] || 
					[photoURL isEqualToString:@"http://www.gaycities.com/images/profile.gif"]) {
					self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];
					NSData *data = UIImageJPEGRepresentation(profileImageSaved, 1);
					if (data) {
						[[NSUserDefaults standardUserDefaults] setObject:data forKey:gcUserProfileImageDataFile];
						[[NSUserDefaults standardUserDefaults] synchronize];
					}
					[self performSelectorOnMainThread:@selector(postUpdateNotification:) withObject:@"0" waitUntilDone:NO];

			
				} else {
					NSURL *URL = [NSURL URLWithString:[userProfileInformation objectForKey:@"profile_image_url"]];
					NSData *data = [NSData dataWithContentsOfURL:URL];
					if (data) {
						[[NSUserDefaults standardUserDefaults] setObject:data forKey:gcUserProfileImageDataFile];
						[[NSUserDefaults standardUserDefaults] synchronize];
						if ([data length] > 0) {
							UIImage *image = [[UIImage alloc] initWithData:(NSData *)data];
							if (image) {
								self.profileImageSaved = image;
								[image release];
							}
						}
						[self performSelectorOnMainThread:@selector(postUpdateNotification:) withObject:@"0" waitUntilDone:NO];
						
					}
				}
				
			}
		}
	}
	
	
	[aPool release];
}

- (void)postUpdateNotification:(NSString *)updateType
{
  int type = [updateType intValue];
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:gcProfileDetailsUpdated object:nil];
  
  switch (type) {
    case 0:;
      break;
    case 1:;  //new account
      GCFindPeopleViewController *fpvc = [[GCFindPeopleViewController alloc] initAfterSignIn];
      UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:fpvc];
      [[GayCitiesAppDelegate sharedAppDelegate].navigationController presentModalViewController:controller animated:YES];
      [fpvc release];
      [controller release];
      break;
    case 2:;  // returning login
      GCFindPeopleViewController *fpvc2 = [[GCFindPeopleViewController alloc] init];
      UINavigationController *controller2 = [[UINavigationController alloc] initWithRootViewController:fpvc2];
      [[GayCitiesAppDelegate sharedAppDelegate].navigationController presentModalViewController:controller2 animated:YES];
      [fpvc2 release];
      [controller2 release];
      break;

  }
	

}

-(NSDictionary *)checkListingStatus:(NSString *)listingID type:(NSString *)type
{
	
	if (!authToken) {
		return nil;
	}
	
	if (!currentLoginStatus) {
		[self checkLogin];
	}

	if (currentLoginStatus) {
		

		NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&un=%@&at=%@&listing_id=%@&type=%@&results=json",gcLoginUsername,authToken, listingID, type];
		
		NSMutableData *recievedData = [self sendRequestWithAPI:@"userlisting" andParameters:searchString];
		[searchString release];

		if ([recievedData length] <10) {
			NSLog(@"No Data Recieved for listing check");
			return nil;
		}
		
		NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
		//NSLog(@"Login Results: %@", tempString);
		
		if ([tempString length] <10) {
			NSLog(@"Error for userlisting check");
			[tempString release];
			return nil;
		}
		
		NSMutableDictionary *tempDict = [tempString JSONValueWithStrings];
		[tempString release];
//		NSLog(@"userlisting Results: %@", tempDict);
		
		return tempDict;
	}
	
	return nil;
	
}

#pragma mark Fan

- (void)checkLoginForMakeFan:(NSDictionary *)dict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	
	if (currentLoginStatus) {
		[self makeFanThread:dict];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self hideProcessing];
		[self performSelectorOnMainThread:@selector(sendMakeFanResult:) withObject:@"0" waitUntilDone:YES];
		[self showNoDataAlert];			
	}
	else {
		[self hideProcessing];
		[self performSelectorOnMainThread:@selector(sendMakeFanResult:) withObject:@"0" waitUntilDone:YES];
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}

-(void)makeFan:(NSString *)listingID type:(NSString *)type status:(NSString *)status
{
	
	if (!authToken) {
		[self askLogin];

	} else if (!currentLoginStatus) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:listingID, @"listing_id", type, @"type", status, @"status", nil];
		[NSThread detachNewThreadSelector:@selector(checkLoginForMakeFan:) toTarget:self withObject:dict];
	} else {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:listingID, @"listing_id", type, @"type", status, @"status", nil];
		[NSThread detachNewThreadSelector:@selector(makeFanThread:) toTarget:self withObject:dict];
	}

}

- (void)makeFanThread:(NSDictionary *)dict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	[self showProcessing:@"Changing Status..."];

	
	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&un=%@&at=%@&listing_id=%@&type=%@&status=%@",gcLoginUsername,authToken, [dict objectForKey:@"listing_id"], [dict objectForKey:@"type"], [dict objectForKey:@"status"]];
	
	NSMutableData *recievedData = [self sendRequestWithAPI:@"makefan" andParameters:searchString];
	[searchString release];

	if ([recievedData length] <10) {
		NSLog(@"No Data Recieved for fan change");
		[self performSelectorOnMainThread:@selector(sendMakeFanResult:) withObject:@"0" waitUntilDone:YES];
		[self showAlertWithTitle:@"No Data" message:@"No data was recieved from the server.  Please try again later."];

		[aPool release];
		return;
	}
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
	NSLog(@"Make Fan: %@", tempString);
	
	NSDictionary *results = [tempString JSONValueWithStrings];
	[tempString release];

	[self hideProcessing];

	if (!results) {
		[self performSelectorOnMainThread:@selector(sendMakeFanResult:) withObject:@"0" waitUntilDone:YES];
		[self showAlertWithTitle:@"Error" message:@"There was an error processing your status.  Please try again later."];
		
			
	} else if ([[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		[self performSelectorOnMainThread:@selector(sendMakeFanResult:) withObject:@"1" waitUntilDone:YES];
		[self showAlertWithTitle:@"Fan Status Changed" message:[results objectForKey:@"message"]];
		
	} else if ([[results objectForKey:@"api_status"] isEqualToString:@"AUTHENTICATION FAILED"]) {
		[self performSelectorOnMainThread:@selector(sendMakeFanResult:) withObject:@"0" waitUntilDone:YES];
		currentLoginStatus = NO;

		[self showSignInFailedWithMessage:[results objectForKey:@"message"]];
	}
	else {
		[self performSelectorOnMainThread:@selector(sendMakeFanResult:) withObject:@"0" waitUntilDone:YES];
		[self showAlertWithTitle:@"Error" message:[results objectForKey:@"message"]];
	}
	
	
	[aPool release];
	
}

- (void)sendMakeFanResult:(NSString *)result
{
	
	if ([delegate respondsToSelector:@selector(makeFanResult:)]) {
		[delegate makeFanResult:result];
	} else {
		NSLog(@"ul makeFanResult does not respond to makeFanResult");
	}
	
}

#pragma mark AB Methods

- (void)checkLoginForFindFriendsFromAB
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	[self hideProcessing];
	
	if (currentLoginStatus) {
		[self performSelectorOnMainThread:@selector(findFriendsAfterAccountVerified) withObject:nil waitUntilDone:NO];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self showNoDataAlert];
		
	}
	else {
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}

- (void)findAllFriendsFromLocalAB
{
	if (![self internetAccess]) {
		return;
	}

	if (!authToken) {
		[self askLogin];
		
	}else if (!currentLoginStatus) {
		[NSThread detachNewThreadSelector:@selector(checkLoginForFindFriendsFromAB) toTarget:self withObject:nil];
	} else  {

		[self findFriendsAfterAccountVerified];
		
	}
	
	
}


- (void)checkLoginForFindFriendsFromFacebook
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	[self hideProcessing];
	
	if (currentLoginStatus) {
		[self performSelectorOnMainThread:@selector(findAllFriendsFromFacebook) withObject:nil waitUntilDone:NO];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self showNoDataAlert];
		
	}
	else {
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}

- (void)findAllFriendsFromFacebook
{
	if (![self internetAccess]) {
		return;
	}
	
	if (!authToken) {
		[self askLogin];
		
	}else if (!currentLoginStatus) {
		[NSThread detachNewThreadSelector:@selector(checkLoginForFindFriendsFromFacebook) toTarget:self withObject:nil];
	} else  {
		
		[self findSocialFriendsAfterAccountVerified:@"facebook"];
		
	}
	
	
}

- (void)checkLoginForFindFriendsFromTwitter
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	[self hideProcessing];
	
	if (currentLoginStatus) {
		[self performSelectorOnMainThread:@selector(findAllFriendsFromTwitter) withObject:nil waitUntilDone:NO];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self showNoDataAlert];
		
	}
	else {
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}


- (void)findAllFriendsFromTwitter
{
	if (![self internetAccess]) {
		return;
	}
	
	if (!authToken) {
		[self askLogin];
		
	}else if (!currentLoginStatus) {
		[NSThread detachNewThreadSelector:@selector(checkLoginForFindFriendsFromTwitter) toTarget:self withObject:nil];
	} else  {
		
		[self findSocialFriendsAfterAccountVerified:@"twitter"];
		
	}
	
	
}

- (void)findFriendsAfterAccountVerified
{
	[self showProcessing:@"Searching Database..."];
	NSMutableArray *allEmails = [[NSMutableArray alloc] init];
	ABAddressBookRef aBook = ABAddressBookCreate();
	
	NSArray *allContacts = (NSArray *)ABAddressBookCopyArrayOfAllPeople(aBook);
	
	for (int x = 0; x < [allContacts count]; x++) {
		ABRecordRef person = [allContacts objectAtIndex:x];
		ABMutableMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
		CFIndex count = ABMultiValueGetCount(multi);
		
		for (CFIndex i = 0; i < count; i++) {
			CFStringRef value = ABMultiValueCopyValueAtIndex(multi, i);
			NSString *firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);  // new version from here ...
			NSString *lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
			NSMutableDictionary *personDict = [[NSMutableDictionary alloc] init];
			if (value) {
				[personDict setObject:(NSString *)value forKey:@"email"];
			} else {
				[personDict setObject:@"" forKey:@"email"];
			}
			
			
			if (firstName && lastName) {
				[personDict setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"full_name"];

			} else if (lastName) {
				[personDict setObject:[NSString stringWithFormat:@"%@", lastName] forKey:@"full_name"];
				
			} else if (value) {
				[personDict setObject:(NSString *)value forKey:@"full_name"];

			} else {
				[personDict setObject:@"NO NAME" forKey:@"full_name"];
			}
			[allEmails addObject:personDict];
			 [personDict release];
			//... to here, delete line below``
			
			//[allEmails addObject:(NSString *)value];  //old version for checking
			
			[firstName release];
      [lastName release];
			if (value) 
        CFRelease(value);
		}
		
		CFRelease(multi);
	}
	//     v3/findfriends/
	
	
	//NSLog(@"\n\n\neMails & Contacts found: \n%@\n\n\n", allEmails);
	NSString *emailsTempString = [allEmails JSONRepresentation];
	NSMutableString *formattedEmail = nil;
	if (emailsTempString) {
		formattedEmail = [NSMutableString stringWithString:emailsTempString];
	} else {
		formattedEmail = [NSMutableString string];
	}
	//NSLog(@"emails formatted: \n*****\n\n\n%@\n\n\n*****\n", formattedEmail);
	
	[allContacts release];
	CFRelease(aBook);
	[allEmails release];
	
	//NSLog(@"Query: %@", formattedEmail);
	//NSMutableString *emailString = [NSMutableString  stringWithFormat:@"%@", [formattedEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	NSMutableString *newFormattedContacts = [formattedEmail filteredStringAddingHTMLEntitiesForAPI];

	NSString *apiSearchString = [NSString stringWithFormat:@"contacts=%@",newFormattedContacts];

	//NSString *emailString = [NSString stringWithFormat:@"contacts=%@",formattedEmail];

	[NSThread detachNewThreadSelector:@selector(findFriendsWithSearchStringThread:) toTarget:self withObject:apiSearchString];

	
}

- (void)findSocialFriendsAfterAccountVerified:(NSString *)type
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	
	if ([type isEqualToString:@"facebook"]) {
		NSString *uid = [[gcad connectController] facebook_uid];
		NSString *token = [[gcad connectController] facebook_token];
		if (uid && token) {
			if ([uid length] > 0 && [token length] > 0) {
				[self showProcessing:@"Searching Facebook..."];
				NSString *searchString = [NSString stringWithFormat:@"fb_uid=%@&fb_session=%@", uid, token];
				[NSThread detachNewThreadSelector:@selector(findFriendsWithSearchStringThread:) toTarget:self withObject:searchString];
			}
		} else {
			[self showAlertWithTitle:@"Oops!" message:@"There was an issue searching with your facebook data.  Please try again later"];
		}
	} else if ([type isEqualToString:@"twitter"]){
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *twitterOAuth = [defaults objectForKey:gcTwitterOAuthDataKey];
		NSString *twitterOAuthToken = nil;
		NSString *twitterOAuthSecret = nil;
		NSString *twitterID = nil;
		NSString *twitterUsername = [defaults objectForKey:gcTwitterUsernameKey];
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
			[self showProcessing:@"Searching Twitter..."];
			NSString *requestString = [NSString stringWithFormat:@"tw_u=%@&tw_token=%@&tw_id=%@&tw_token_secret=%@", [twitterUsername filteredStringAddingHTMLEntitiesForAPI], twitterOAuthToken, twitterID, twitterOAuthSecret];
			[NSThread detachNewThreadSelector:@selector(findFriendsWithSearchStringThread:) toTarget:self withObject:requestString];
		} else {
			[self showAlertWithTitle:@"Oops!" message:@"There was an issue searching with your twitter data.  Please try again later"];
		}
	}
	
	
}

- (void)findFriendsWithSearchData:(NSString *)searchString andParameter:(NSString *)queryString
{
	if (![self internetAccess]) {
		[[GCCommunicator sharedCommunicator] showNoInternetAlertGeneric];
		
	}else if (!authToken) {
		[self askLogin];
		
	} else {
		[self showProcessing:@"Searching Database..."];

		if ([searchString length] > 0 && [queryString length] > 0) {
			NSString *requestString = [NSString stringWithFormat:@"%@=\"%@\"", queryString, searchString];
			
			NSLog(@"Query: %@", requestString);
			
			//NSMutableString *emailString = [NSMutableString  stringWithFormat:@"%@", [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			
			//NSMutableString *newFormattedContacts = [requestString filteredStringAddingHTMLEntitiesForAPI];
			
			//NSString *apiSearchString = [NSString stringWithFormat:@"contacts=%@",newFormattedContacts];
			
			//[NSThread detachNewThreadSelector:@selector(findFriendsWithSearchStringThread:) toTarget:self withObject:newFormattedContacts];
			[NSThread detachNewThreadSelector:@selector(findFriendsWithSearchStringThread:) toTarget:self withObject:requestString];

		} else {
			[NSThread detachNewThreadSelector:@selector(findFriendsWithSearchStringThread:) toTarget:self withObject:@"email=\"\""];
		}
		
	}
}

- (void)findFriendsWithSearchStringThread:(NSString *)dataString
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	
	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&un=%@&at=%@&%@",gcLoginUsername,authToken, dataString];
	
	NSMutableData *recievedData = [self sendRequestWithAPI:@"findfriends" andParameters:searchString];
	[searchString release];
	
	
	if ([recievedData length] <10) {
		NSLog(@"No Data Recieved for findfriends");
		[self hideProcessing];
		[self showNoDataAlert];
		[aPool release];
		return;
	}
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
	
	NSLog(@"findfriends Result: %@", tempString);
	
	NSDictionary *results = [tempString JSONValueWithStrings];
	//NSLog(@"findfriends Result: %@", results);
	[tempString release];
	
	
	if ([[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		// Show Friend Results

		[self performSelectorOnMainThread:@selector(processFriendSearchResultsData:) withObject:results waitUntilDone:YES];
		[self hideProcessing];

		
	} else if ([[results objectForKey:@"api_status"] isEqualToString:@"AUTHENTICATION FAILED"]) {
		[self hideProcessing];

		[self logoutOfAccount];
		[self showSignInFailedAlert];
		
	} else {
		[self hideProcessing];

		[self showAlertWithTitle:@"Oops!" message:[results objectForKey:@"message"]];

	}
	[aPool release];
}


- (void)processFriendSearchResultsData:(NSDictionary *)returnedContacts
{
	
	
	//NSLog(@"Friend Conections formatted: %@", returnedContacts);
	
	if (returnedContacts) {
		NSMutableArray *allFound = [returnedContacts objectForKey:@"foundfriends"];
		NSMutableArray *allFriends = [[NSMutableArray alloc] init];
		NSMutableArray *nonFriends = [[NSMutableArray alloc] init];
		NSMutableArray *notUsers = [returnedContacts objectForKey:@"inviteablefriends"];

		if (allFound && [allFound isKindOfClass:[NSArray class]]) {
			
			for (NSMutableDictionary *somePerson in allFound) {
				if ([[somePerson objectForKey:@"username"] isEqualToString:gcLoginUsername]) {
					NSLog(@"Current User: %@ returned in results, ignoring", gcLoginUsername);
				} else {
					GCFindFriendPerson *aPerson = [[GCFindFriendPerson alloc] init];
					//[aPerson setValuesForKeysWithDictionary:somePerson];
					aPerson.username = [somePerson objectForKey:@"username"];
					aPerson.email = [somePerson objectForKey:@"email"];
					aPerson.first_name = [somePerson objectForKey:@"first_name"];
					aPerson.last_name = [somePerson objectForKey:@"last_name"];
					aPerson.facebook_uid = [somePerson objectForKey:@"facebook_uid"];
					aPerson.profile_image_url = [somePerson objectForKey:@"profile_image_url"];
					aPerson.already_friend = [[somePerson objectForKey:@"already_friend"] boolValue];

					
					if (aPerson.already_friend) {
						[allFriends addObject:aPerson];
					}else {
						[nonFriends addObject:aPerson];
					}
					
					[aPerson release];
				}
				
			}
		}
		
		NSMutableDictionary *allPeopleReturned = [[NSMutableDictionary alloc] init];
		[allPeopleReturned setObject:allFriends forKey:@"allFriends"];
		[allPeopleReturned setObject:nonFriends forKey:@"nonFriends"];
		[allFriends release];
		[nonFriends release];
		
		if (notUsers && [notUsers isKindOfClass:[NSArray class]]) {
			NSMutableArray *potentialUsers = [[NSMutableArray alloc] init];
			for (NSMutableDictionary *newPerson in notUsers) {
				GCFindFriendPerson *aPerson = [[GCFindFriendPerson alloc] init];
				[aPerson setValuesForKeysWithDictionary:newPerson];
				aPerson.invite_sent = NO;
				[potentialUsers addObject:aPerson];
				[aPerson release];
			}
			
			[allPeopleReturned setObject:potentialUsers forKey:@"notUsers"];
			[potentialUsers release];

		} else {
			[allPeopleReturned setObject:[NSArray array] forKey:@"notUsers"];
		}
		
		if (delegate) {
			if ([delegate respondsToSelector:@selector(findFriendSearchResults:)]) {
				[delegate findFriendSearchResults:allPeopleReturned];

				[allPeopleReturned release];
				return;
			}
		}
				 
				 
		 
		 [allPeopleReturned release];
		
	}
	

	if (delegate) {
		if ([delegate respondsToSelector:@selector(findFriendSearchResults:)]) {
			[delegate findFriendSearchResults:nil];
		}
	}

	[self showAlertWithTitle:@"" message:@"There was a problem fetching the results.  Please try again later.  If this problem persists, please contact support@gaycities.com"];

	

	
	
	
}

#pragma mark Add/Remove Friends or Invite

- (void)submitFriendActionWithUsernameOrEmail:(NSString *)usernameOrEmail andAction:(FriendActionEnum)newAction withName:(NSString *)passedFullName
{
	if (![self internetAccess]) {
		return;
	}
	[self showProcessing:@"Updating..."];
	NSString *requestString;
	NSMutableString *filteredUsernameOrEmail = [usernameOrEmail filteredStringAddingHTMLEntitiesForAPI];

	if (newAction == friendInviteNewAction) {
		if (passedFullName) {
			requestString = [NSString stringWithFormat:@"email=%@&full_name=%@&action=invite", filteredUsernameOrEmail, [passedFullName filteredStringAddingHTMLEntitiesForAPI]];
		} else {
			requestString = [NSString stringWithFormat:@"email=%@&full_name=%@&action=invite", filteredUsernameOrEmail, filteredUsernameOrEmail];
		}
	} else if (newAction == friendAddAction) {
		requestString = [NSString stringWithFormat:@"username=%@&action=add_fave", filteredUsernameOrEmail];

	} else {
		requestString	= [NSString stringWithFormat:@"username=%@&action=del_fave", filteredUsernameOrEmail];

	}
	[NSThread detachNewThreadSelector:@selector(submitFriendActionThread:) toTarget:self withObject:requestString];
	
}

- (void)submitFriendActionThread:(NSString *)requestString
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&un=%@&at=%@&%@",gcLoginUsername,authToken, requestString];
	
	NSMutableData *recievedData = [self sendRequestWithAPI:@"friendsaction" andParameters:searchString];
	[searchString release];
	
	
	if ([recievedData length] <10) {
		NSLog(@"No Data Recieved for findfriends");
		[self hideProcessing];
		[self showNoDataAlert];
		[aPool release];
		return;
	}
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
	
//	NSLog(@"friendsaction Result: %@", tempString);
	
	NSMutableDictionary *results = [tempString JSONValueWithStrings];
	NSLog(@"friendsaction Result: %@", results);
	[tempString release];
	
	[self hideProcessing];
	
	
	
	if ([[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		NSString *aMessage = [results objectForKey:@"message"];
		if ([aMessage length] > 0) {
			[self showAlertWithTitle:@"" message:aMessage];
		}
		[self performSelectorOnMainThread:@selector(processFriendActionResult:) withObject:results waitUntilDone:YES];
		
	}
	else {
		NSString *aMessage = [results objectForKey:@"message"];
		if ([aMessage length] > 0) {
			[self showAlertWithTitle:@"" message:aMessage];
		} else {
			[self showAlertWithTitle:@"" message:@"We encountered a problem processing your request\nPlease try again later"];
		}
		[self performSelectorOnMainThread:@selector(processFriendActionResult:) withObject:nil waitUntilDone:YES];

	}
	
	
	[aPool release];
}

- (void)processFriendActionResult:(NSMutableDictionary *)results
{
	
	if (delegate) {
		if ([delegate respondsToSelector:@selector(friendActionResult:)]) {
			if (results && [[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
				[delegate friendActionResult:YES];
			} else {
				[delegate friendActionResult:NO];
			}
			return;
		}
	}
	
	NSLog(@"No Delegate for Friend Action Results");
}

#pragma mark -
#pragma mark Foursquare

- (void)checkFoursquareLoginWithStatus:(BOOL)flag
{
	if (![self isSignedIn]) {
		return;
	}
	
	if (flag) {
		[self showProcessing:@"Checking Foursquare Login..."];
	}
	[NSThread detachNewThreadSelector:@selector(checkFoursquareLoginThread) toTarget:self withObject:nil];
}

- (void)checkFoursquareLoginThread
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSString *searchString = [NSString stringWithFormat:@"&results=json&un=%@&at=%@&get=1&foursquare=1", gcLoginUsername, authToken];
	NSData *data = [self sendRequestWithAPI:@"socialaccounts" andParameters:searchString];
	
	if ([data length] <10) {
		NSLog(@"No Data Recieved for foursquare check");
		[self hideProcessing];
		[aPool release];
		return;
	}
	
	NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	//NSLog(@"Login Results: %@", tempString);
	
	if (!tempString) {
		NSLog(@"Error for foursquare check - no string");
		[self hideProcessing];
		[aPool release];
		return;
	}
	
	NSMutableDictionary *tempDict = [tempString JSONValueWithStrings];
	
	[self performSelectorOnMainThread:@selector(reportFoursquareResults:) withObject:tempDict waitUntilDone:YES];
	
	[aPool release];
}

- (void)reportFoursquareResults:(NSDictionary *)results
{
	NSLog(@"Foursquare Token Results: %@", results);
	[self hideProcessing];
	
	NSString *token = [results objectForKey:@"foursquare_token"];
	if (![token isKindOfClass:[NSString class]]) {
		token = @"";
	}
	
	if ([self.delegate respondsToSelector:@selector(foursquareTokenResult:)]) {
		[self.delegate foursquareTokenResult:token];
	} else {
		NSLog(@"UL Delegate doesnt respond to Foursquare token result");
	}
}

#pragma mark Social Send Twitter or FB data to server

- (void)submitTwitterInfoWithUsername:(NSString *)twitterUsername oAuth:(NSString *)twitterOAuth andID:(NSString *)twitterID andSecret:(NSString *)secret
{
	if (![self internetAccess]) {
		return;
	}
	
	if (twitterUsername && twitterOAuth && twitterID) {
		NSString *requestString = [NSString stringWithFormat:@"tw_u=%@&tw_token=%@&tw_id=%@&tw_token_secret=%@", [twitterUsername filteredStringAddingHTMLEntitiesForAPI], twitterOAuth, twitterID, secret];

		
		NSDictionary *socialReqDict = [NSDictionary dictionaryWithObjectsAndKeys:requestString, @"searchString", @"2", @"requestSite", nil];
		[NSThread detachNewThreadSelector:@selector(submitSocialInfoThread:) toTarget:self withObject:socialReqDict];
	}
	
}



- (void)submitFacebookInfoWithSession:(NSString *)fbSession andfbUID:(NSString *)fbID
{
	
	if (![self internetAccess]) {
		return;
	}
	
	if (fbID && fbSession) {
		NSString *requestString = [NSString stringWithFormat:@"fb_uid=%@&fb_session=%@", [fbID filteredStringAddingHTMLEntitiesForAPI], [fbSession filteredStringAddingHTMLEntitiesForAPI]];
		NSDictionary *socialReqDict = [NSDictionary dictionaryWithObjectsAndKeys:requestString, @"searchString", @"1", @"requestSite", nil];
		[NSThread detachNewThreadSelector:@selector(submitSocialInfoThread:) toTarget:self withObject:socialReqDict];
	}
	
}


- (void)submitSocialInfoThread:(NSDictionary *)socialReqDict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&un=%@&at=%@&%@",gcLoginUsername,authToken, [socialReqDict objectForKey:@"searchString"]];
	int requestSite = [[socialReqDict objectForKey:@"requestSite"] intValue];
	
	NSMutableData *recievedData = [self sendRequestWithAPI:@"socialaccounts" andParameters:searchString];
	[searchString release];
	
	
	if ([recievedData length] <10) {
		NSLog(@"No Data Recieved for socialaccounts");
		[aPool release];
		return;
	}
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
	
	NSLog(@"socialaccounts Result: %@", tempString);
	
	NSMutableDictionary *results = [tempString JSONValueWithStrings];
	NSLog(@"socialaccounts Result: %@", results);
	[tempString release];
	
	if ([[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		
		if (requestSite == 1) {
			[self performSelectorOnMainThread:@selector(processSocialInfoResult:) withObject:@"1" waitUntilDone:YES];
		} else if (requestSite == 2) {
			[self performSelectorOnMainThread:@selector(processSocialInfoResult:) withObject:@"2" waitUntilDone:YES];
		} else {
			[self performSelectorOnMainThread:@selector(processSocialInfoResult:) withObject:@"0" waitUntilDone:YES];
		}
		
	}
	else {
		
		[self performSelectorOnMainThread:@selector(processSocialInfoResult:) withObject:@"0" waitUntilDone:YES];
		
	}
	
	
	[aPool release];
}

- (void)processSocialInfoResult:(NSString *)result
{
	int requestSite = [result intValue];
	
	if (requestSite == 1) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:gcFacebookCredentialsSentKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[[GayCitiesAppDelegate sharedAppDelegate] connectController].fbCredentialsUploaded = YES;
		NSLog(@"!! FB Credentials Uploaded");
	} else if (requestSite == 2) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:gcTwitterCredentialsSentKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[[GayCitiesAppDelegate sharedAppDelegate] connectController].twitterCredentialsUploaded = YES;
		NSLog(@"!! TWITTER Credentials Uploaded");

	} else {
		NSLog(@"!! NOTHING !! Credentials Uploaded: %i", requestSite);

	}
}


#pragma mark Review/Rate

- (void)checkLoginForReview:(NSDictionary *)dict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	[self hideProcessing];
	
	if (currentLoginStatus) {
		[self performSelectorOnMainThread:@selector(submitReviewAfterLoginCheck:) withObject:dict waitUntilDone:NO];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self showNoDataAlert];		
	}
	else {
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}

- (void)submitReviewAfterLoginCheck:(NSDictionary *)dict
{
	
	[self submitReview:[dict objectForKey:@"listing_id"] type:[dict objectForKey:@"type"] update:[dict objectForKey:@"update"] previousReview:[dict objectForKey:@"previousReview"]];
}



-(void)submitReview:(NSString *)listingID type:(NSString *)type update:(NSString *)update previousReview:(NSDictionary *)review
{
	if (!authToken) {
		[self askLogin];

	}else if (!currentLoginStatus) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:listingID, @"listing_id", type, @"type",update, @"update", review, @"previousReview", nil];
		[NSThread detachNewThreadSelector:@selector(checkLoginForReview:) toTarget:self withObject:dict];
	} else  {
		
		self.reviewListingID = listingID;
		self.reviewType = type;
		reviewUpdate = [update boolValue];
		
		GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
		gcad.mainTabBar.hidden = YES;
		gcad.adBackgroundView.hidden = YES;
		gcad.shouldShowAdView = NO;
		
		GCReviewVC *rvc = [[GCReviewVC alloc] initWithReview:review];
		rvc.reviewDelegate = self;
		
		UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:rvc];
		[[GayCitiesAppDelegate sharedAppDelegate].navigationController presentModalViewController:nc animated:YES];
		[rvc release];
		[nc release];
		
	 

	}
	
}



-(void)submitReviewFinalThread:(NSString *)searchString
{
	
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];

	NSMutableData *recievedData = [self sendRequestWithAPI:@"rate" andParameters:searchString];

	
	if ([recievedData length] <10) {
		NSLog(@"No Data Recieved review submition");
		[self hideProcessing];
		[self showNoDataAlert];
		[aPool release];
		return;
	}
	
	
	
	NSString *resultsString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
//	NSLog(@"reviewString: %@", resultsString);
	NSMutableDictionary *results = [resultsString JSONValueWithStrings];
//	NSLog(@"SUBMIT REVIEW results: %@", results);
	[resultsString release];

	[self hideProcessing];

	
	if ([[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		[self showAlertWithTitle:@"Review Submitted" message:[results objectForKey:@"message"]];
	}
	else {
		[self showAlertWithTitle:@"Review Submission Failed" message:[results objectForKey:@"message"]];
		currentLoginStatus = NO;
	}
	
	[aPool release];
}

#pragma mark Profile Photo

- (void)checkLoginForProfilePhoto
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	[self hideProcessing];
	
	if (currentLoginStatus) {
		[self performSelectorOnMainThread:@selector(submitProfilePhotoAfterLoginCheck) withObject:nil waitUntilDone:NO];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self showNoDataAlert];
	}
	else {
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}

- (void)submitProfilePhotoAfterLoginCheck
{
	[self submitProfilePhoto];
}

-(void)submitProfilePhoto
{
	if (!authToken) {
		[self askLogin];
		
	} else if (!currentLoginStatus) {
		[NSThread detachNewThreadSelector:@selector(checkLoginForProfilePhoto) toTarget:self withObject:nil];
	} else  {
		currentPhotoType = photoSubmitTypeProfile;
		[self showImagePickerController];
		
	}
}


- (void)showImagePickerController
{
	
	if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"What picture would you like to submit?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use Photo Library",@"Use Camera", nil];			
		
		sheet.tag = 50;
		[sheet showInView:[[UIApplication sharedApplication] keyWindow]];
		[sheet release];
	} else {
		[[[GayCitiesAppDelegate sharedAppDelegate] mainTabBar] setHidden:YES];
		[[[GayCitiesAppDelegate sharedAppDelegate] adBackgroundView] setHidden:YES];
		[GayCitiesAppDelegate sharedAppDelegate].shouldShowAdView = NO;
		
		UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
		ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		ipc.delegate = self;
		[[[GayCitiesAppDelegate sharedAppDelegate] navigationController] presentModalViewController:ipc animated:YES];
		[ipc release];
	}
}

#pragma mark Listing Photo

- (void)checkLoginForPhoto:(NSDictionary *)dict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	[self hideProcessing];
	
	if (currentLoginStatus) {
		[self performSelectorOnMainThread:@selector(submitPhotoAfterLoginCheck:) withObject:dict waitUntilDone:NO];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self showNoDataAlert];
	}
	else {
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}

- (void)submitPhotoAfterLoginCheck:(NSDictionary *)dict
{
	[self uploadPhoto:[dict objectForKey:@"listing_id"] type:[dict objectForKey:@"type"]];
}

-(void)uploadPhoto:(NSString *)listingID type:(NSString *)type
{
	if (!authToken) {
		[self askLogin];
		
	} else if (!currentLoginStatus) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:listingID, @"listing_id", type, @"type", nil];
		[NSThread detachNewThreadSelector:@selector(checkLoginForPhoto:) toTarget:self withObject:dict];
	} else  {
		self.photoType = type;
		self.photoListingID = listingID;
		currentPhotoType = photoSubmitTypeListing;
		
		[self showImagePickerController];
	}
}

#pragma mark both Photo Uploads

-(void)sendPhoto
{
	[self showProcessing:@"Uploading Photo..."];
	if (currentPhotoType == photoSubmitTypeListing) {
		[NSThread detachNewThreadSelector:@selector(sendPhotoThread) toTarget:self withObject:photoCaption];
		
	} else if (currentPhotoType == photoSubmitTypeProfile) {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"USER_ACTION-Profile photo upload" withParameters:nil];
		[NSThread detachNewThreadSelector:@selector(sendPhotoThread) toTarget:self withObject:@""];
	}
	

}

- (void)sendPhotoThread
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSString *urlString = nil;
/*	if (currentPhotoType == photoSubmitTypeListing) {
		urlString = [NSString stringWithString:@"http://api.gaycities.com/v3/addlistingphoto"]; 
	} else if (currentPhotoType == photoSubmitTypeProfile) {
		urlString = [NSString stringWithString:@"http://api.gaycities.com/v3/addprofilephoto"]; 
	}
 */
	
	if (currentPhotoType == photoSubmitTypeListing) {
		urlString = [NSString stringWithString:@"http://api.gaycities.com/v4/addlistingphoto"]; 
	} else if (currentPhotoType == photoSubmitTypeProfile) {
		urlString = [NSString stringWithString:@"http://api.gaycities.com/v4/addprofilephoto"]; 
	}
	
	NSURL *url = [NSURL URLWithString:urlString];
	
		//NSLog(@"image data %@", imageData);
	
	//NSMutableString *searchString = [[NSMutableString alloc] initWithString:[self getSearchString]];
	
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:120];
	[req setHTTPMethod:@"POST"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

	NSString *boundary = @"----14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[req setValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSData *imageData = UIImageJPEGRepresentation(photo, .1);

	
	NSMutableData *postData = [[NSMutableData alloc] init];
	
	srandom(time(NULL));
	int r = (random() % 1000000)+1;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddHH"];
	NSString *c = [NSString stringWithFormat:@"gciphonesecret%@%@%i",[dateFormatter stringFromDate:[[NSDate date] addTimeInterval:-([[NSTimeZone systemTimeZone] secondsFromGMT])]],[[UIDevice currentDevice] uniqueIdentifier],r];
	[dateFormatter release];
	
		
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: form-data; name=\"r\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"%i",r] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] uniqueIdentifier]] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: form-data; name=\"c\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"%@",[[self md5Digest:c] substringWithRange:NSMakeRange(0, 7)]] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: form-data; name=\"un\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"%@",gcLoginUsername] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: form-data; name=\"at\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"%@",authToken] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: form-data; name=\"results\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"json" dataUsingEncoding:NSUTF8StringEncoding]];
	
	if (currentPhotoType == photoSubmitTypeListing) {
		[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[@"Content-Disposition: form-data; name=\"listing_id\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"%@",photoListingID] dataUsingEncoding:NSUTF8StringEncoding]];
		
		[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[@"Content-Disposition: form-data; name=\"type\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"%@",photoType] dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([photoCaption length] > 0) {
			[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[@"Content-Disposition: form-data; name=\"caption\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[[NSString stringWithFormat:@"%@",photoCaption] dataUsingEncoding:NSUTF8StringEncoding]];
			
		}
		self.photoListingID = @"";
		self.photoType = @"";

	} else if (currentPhotoType == photoSubmitTypeProfile) {
		[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[@"Content-Disposition: form-data; name=\"un\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"%@",gcLoginUsername] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	

	

	
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: form-data; name=\"upload\"; filename=\"ipodfile.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Type: image/jpg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[NSData dataWithData:imageData]];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	self.photoCaption = @"";
	
	[req setHTTPBody:postData];
	
	NSMutableData *recievedData = [[NSMutableData alloc] init];
	
//	NSLog(@"submitting photo");
	[recievedData appendData:[NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil]];
	self.photo = nil;
	[postData release];
	
	if ([recievedData length] <10) {
		currentPhotoType = 0;

		NSLog(@"No Data Recieved photo submition");
		[self hideProcessing];
		[recievedData release];
		[self showNoDataAlert];
		[aPool release];
		return;
	}
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
	[recievedData release];
	
//	NSLog(@"photo: %@", tempString);
	
	NSMutableDictionary *results = [tempString JSONValueWithStrings];
	[tempString release];
//	NSLog(@"photo: %@", results);

	
	 [self hideProcessing];
	 if ([[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		 [self showAlertWithTitle:@"Photo Uploaded" message:[results objectForKey:@"message"]];
		if (currentPhotoType == photoSubmitTypeProfile) {  
			 [self checkLogin];
		}
		 

	 }
	 else {
		 [self showAlertWithTitle:@"Photo Upload Failed" message:[results objectForKey:@"message"]];
		 currentLoginStatus = NO;
	 }
	
	[aPool release];
	
}

#pragma mark Data Report

- (void)checkLoginForDataReport:(NSDictionary *)dict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	[self hideProcessing];
	
	if (currentLoginStatus) {
		[self performSelectorOnMainThread:@selector(submitReportAfterLoginCheck:) withObject:dict waitUntilDone:NO];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self showNoDataAlert];
		
	}
	else {
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}

- (void)submitReportAfterLoginCheck:(NSDictionary *)dict
{
	[self submitDataReport:[dict objectForKey:@"listing_id"] type:[dict objectForKey:@"type"]];
}

-(void)submitDataReport:(NSString *)listingID type:(NSString *)type
{
	
	if (!authToken) {
		[self askLogin];

	}else if (!currentLoginStatus) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:listingID, @"listing_id", type, @"type", nil];
		[NSThread detachNewThreadSelector:@selector(checkLoginForDataReport:) toTarget:self withObject:dict];
	} else  {
		self.reviewListingID = listingID;
		self.reviewType = type;
		GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
		gcad.mainTabBar.hidden = YES;
		gcad.adBackgroundView.hidden = YES;
		gcad.shouldShowAdView = NO;
		
		GCDataReportVC *drvc = [[GCDataReportVC alloc] initWithDelegate:self];
		UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:drvc];
		[[GayCitiesAppDelegate sharedAppDelegate].navigationController presentModalViewController:nc animated:YES];
		[drvc release];
		[nc release];
	}
}

-(void)sendReport
{
	
	[self showProcessing:@"Sending Report..."];

	NSString *report = [[NSString alloc] initWithFormat:@"listing_id=%@&type=%@&comment=%@&visited_year=%@&visited_month=%@", reviewListingID, reviewType, dataComment, reviewYear, reviewMonth];

	[NSThread detachNewThreadSelector:@selector(sendReportThreadWithReport:) toTarget:self withObject:report];
	[report release];
	
	self.reviewListingID = @"";
	self.reviewType = @"";
	self.reviewYear = @"";
	self.reviewMonth = @"";
}

- (void)sendReportThreadWithReport:(NSString *)report
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	

	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&un=%@&at=%@&%@",gcLoginUsername,authToken, report];
	
	NSMutableData *recievedData = [self sendRequestWithAPI:@"datareport" andParameters:searchString];
	[searchString release];

	
	if ([recievedData length] <10) {
		NSLog(@"No Data Recieved for datareport");
		[self hideProcessing];
		[self showNoDataAlert];
		[aPool release];
		return;
	}
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
	
	//NSLog(@"Data Report Result: %@", tempString);
	
	NSDictionary *results = [tempString JSONValueWithStrings];
	//NSLog(@"Data Report Result: %@", results);
	[tempString release];
	
	[self hideProcessing];
	
	if ([[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		[self showAlertWithTitle:@"Report Submitted" message:[results objectForKey:@"message"]];
		
	}
	else {
		[self showAlertWithTitle:@"Report Submission Failed" message:[results objectForKey:@"message"]];
		currentLoginStatus = NO;
	}
	[aPool release];
}


#pragma mark Event Attend

- (void)checkLoginForAttendEvent:(NSDictionary *)dict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	
	if (currentLoginStatus) {
		[self attendEventThread:dict];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self hideProcessing];
		[self showNoDataAlert];			
	}
	else {
		[self hideProcessing];
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}

-(void)attendEvent:(NSString *)eventID status:(NSString *)eventStatus shout:(NSString *)shout
{
	
	if (!authToken) {
		[self askLogin];
		
	} else if (!currentLoginStatus) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:eventID, @"event_id", eventStatus, @"status",shout ? shout : @"", @"shout", nil];
		[NSThread detachNewThreadSelector:@selector(checkLoginForAttendEvent:) toTarget:self withObject:dict];
	} else {
		if (eventID && eventStatus) {
			[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"EVENT-USER_ACTION-Attend Event" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:eventID, @"event_id", eventStatus, @"event_status",gcLoginUsername, @"GC_USER_NAME", nil]];
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:eventID, @"event_id", eventStatus, @"status",shout ? shout : @"", @"shout", nil];
			[NSThread detachNewThreadSelector:@selector(attendEventThread:) toTarget:self withObject:dict];
		}
		
	}
	
}

- (void)attendEventThread:(NSDictionary *)dict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
		
	[self showProcessing:@"Changing Event Status..."];
	

	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&un=%@&at=%@&event_id=%@&status=%@",gcLoginUsername,authToken, [dict objectForKey:@"event_id"], [dict objectForKey:@"status"]];
	if ([[dict objectForKey:@"shout"] length] > 0) {
    [searchString appendFormat:@"&shout=%@", [dict objectForKey:@"shout"]];
  }
	NSMutableData *recievedData = [self sendRequestWithAPI:@"attendevent" andParameters:searchString];
	[searchString release];

  NSMutableDictionary *responseToSend = [[NSMutableDictionary alloc] init];

	if ([recievedData length] <10) {
		NSLog(@"No Data Recieved for event change");
		[self hideProcessing];
		[self showNoDataAlert];
    [responseToSend setObject:@"0" forKey:@"result"];
		[responseToSend setObject:[NSDictionary dictionary] forKey:@"response"];
		[self performSelectorOnMainThread:@selector(reportEventResults:) withObject:responseToSend waitUntilDone:NO];
    [responseToSend autorelease];
		[aPool release];
		return ;
	}
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
//	NSLog(@"Attend Event Result: %@", tempString);
	
	NSDictionary *results = [tempString JSONValueWithStrings];
//	NSLog(@"Attend Event Result: %@", results);
	[tempString release];	
	[self hideProcessing];
	

	if ([[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
    [responseToSend setObject:@"1" forKey:@"result"];
		[responseToSend setObject:results forKey:@"response"];
		[self showAlertWithTitle:@"Event Status Changed" message:[results objectForKey:@"message"]];
		[self performSelectorOnMainThread:@selector(reportEventResults:) withObject:responseToSend waitUntilDone:NO];
	} else {
    [responseToSend setObject:@"0" forKey:@"result"];
		[responseToSend setObject:[NSDictionary dictionary] forKey:@"response"];
		[self showAlertWithTitle:@"Event Status Update Failed" message:[results objectForKey:@"message"]];
		[self performSelectorOnMainThread:@selector(reportEventResults:) withObject:responseToSend waitUntilDone:NO];
	}
  [responseToSend autorelease];
	[aPool release];

}

- (void)reportEventResults:(NSMutableDictionary *)results
{
  if ([[results objectForKey:@"result"] boolValue]) {
    if ([delegate respondsToSelector:@selector(attendEventResult:)]) {
      [delegate attendEventResult:YES];
    } else {
      NSLog(@"delegate does not respond to attendEventResult for events");
    }
  } else {
    if ([delegate respondsToSelector:@selector(attendEventResult:)]) {
      [delegate attendEventResult:NO];
    } else {
      NSLog(@"delegate does not respond to attendEventResult for events");
    }
  }
  
	if ([checkinDelegate respondsToSelector:@selector(checkinResult:)]) {
		[checkinDelegate checkinResult:results];
	} else {
		NSLog(@"delegate does not respond to checkinResult for events");
	}
}

#pragma mark Submit business

- (void)submitNewBusiness:(NSString *)newName forMetro:(GCMetro *)metro withTypes:(NSArray *)types andHoods:(NSArray *)hoods
{
		GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
		gcad.mainTabBar.hidden = YES;
		gcad.adBackgroundView.hidden = YES;
		gcad.shouldShowAdView = NO;
		
		GCSubmitNewBusinessViewController *snbvc = [[GCSubmitNewBusinessViewController alloc] init];
		UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:snbvc];
		//lcivc.communicator = communicator;
		snbvc.gcDelegate = self;
		snbvc.neighborhoodNames = hoods;
		snbvc.listingTypes = types;
		snbvc.metro = metro;
		snbvc.businessName = newName;
		[gcad.navigationController presentModalViewController:controller animated:YES];
		[controller release];
		[snbvc release];
}

- (void)submitNewBusinessThread:(NSDictionary *)extras
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Submitting Business..."];
	
	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&metro_id=%@&type=%@&name=%@",[extras objectForKey:@"metro_id"],[extras objectForKey:@"type"], [extras objectForKey:@"name"]];
	if (currentLoginStatus) {
		[searchString appendFormat:@"&un=%@&at=%@",gcLoginUsername, authToken];
	}
	if ([extras objectForKey:@"add_street"]) {
		[searchString appendFormat:@"&add_street=%@", [extras objectForKey:@"add_street"]];
	}
	if ([extras objectForKey:@"add_city"]) {
		[searchString appendFormat:@"&add_city=%@", [extras objectForKey:@"add_city"]];
	}
	if ([extras objectForKey:@"add_state"]) {
		[searchString appendFormat:@"&add_state=%@", [extras objectForKey:@"add_state"]];
	}
	if ([extras objectForKey:@"add_zip"]) {
		[searchString appendFormat:@"&add_zip=%@", [extras objectForKey:@"add_zip"]];
	}
	if ([extras objectForKey:@"phone"]) {
		[searchString appendFormat:@"&phone=%@", [extras objectForKey:@"phone"]];
	}
	if ([extras objectForKey:@"url"]) {
		[searchString appendFormat:@"&url=%@", [extras objectForKey:@"url"]];
	}
	if ([extras objectForKey:@"neighborhood_id"]) {
		[searchString appendFormat:@"&neighborhood_id=%@", [extras objectForKey:@"neighborhood_id"]];
	}

	NSMutableData *recievedData = [self sendRequestWithAPI:@"addbiz" andParameters:searchString];
	[searchString release];
	
	if ([recievedData length] == 0) {
		NSLog(@"No Data Recieved for submit business");
		[self hideProcessing];
		[self showAlertWithTitle:@"No Data" message:@"No data was recieved from the server.  Please try again later."];			
		[aPool release];
		return;
	}
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
//	NSLog(@"Submit Business: %@", tempString);
	
	NSDictionary *result = [tempString JSONValueWithStrings];
	[tempString release];
//	NSLog(@"Submit Business: %@", result);
	
	[self hideProcessing];

	if (!result) {
		[self showAlertWithTitle:@"Error"message:@"There was an error processing your status.  Please try again later."];	
		
		
	} else if ([[result objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		[self showAlertWithTitle:@"Success" message:[result objectForKey:@"message"]];

	} else if ([[result objectForKey:@"api_status"] isEqualToString:@"AUTHENTICATION FAILED"]) {
		[self showAlertWithTitle:@"Error" message:@"Authentication Failed. Please try again later"];
		currentLoginStatus = NO;
	} else {			
		[self showAlertWithTitle:@"Error" message:@"Please try again later"];
	}

	
	[aPool release];
}



#pragma mark checkin to listings

-(BOOL)shouldCheckInToListing
{
	
	if (!authToken) {
		[self askLogin];
		return NO;
	} else if (!currentLoginStatus) {
		[NSThread detachNewThreadSelector:@selector(checkLoginForShouldCheckInListing) toTarget:self withObject:nil];
		return NO;
	}
	
	return YES;
}

- (void)checkLoginForShouldCheckInListing
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	[self hideProcessing];

	if (currentLoginStatus) {
		[self showAlertWithTitle:@"Sign In Successful" message:@"You may now use your account"];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self showNoDataAlert];			
	}
	else {
		[self showSignInFailedWithMessage:loginStatus];
	}
	
	[aPool release];
}



- (void)checkLoginForCheckInListing:(NSDictionary *)dict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[self showProcessing:@"Checking Login..."];
	NSString *loginStatus = [self checkLogin];
	
	if (currentLoginStatus) {
		[self checkinToListingThread:dict];
	}
	else if ([loginStatus isEqualToString:@"noData"]) {
		[self hideProcessing];
		[self showNoDataAlert];			
	}
	else {
		[self hideProcessing];
		[self showSignInFailedWithMessage:loginStatus];
	}
	[aPool release];
}

- (void)checkInToListing:(NSString *)listing_id name:(NSString *)listing_name type:(NSString *)type shout:(NSString *)shout private:(NSString *)private facebook:(NSString *)facebook twitter:(NSString *)twitter foursquare:(NSString *)foursquare lat:(NSString *)lat lng:(NSString *)lng foursquareResponse:(NSString *)response
{
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:listing_id, @"listing_id", type, @"type",shout, @"shout", private, @"private", facebook, @"facebook", twitter, @"twitter", foursquare, @"foursquare", lat, @"lat", lng, @"lng",listing_name ? listing_name : @"", @"listing_name", response ? response : @"", @"foursquareResponse", nil];
  if (!currentLoginStatus) {
    [NSThread detachNewThreadSelector:@selector(checkLoginForCheckInListing:) toTarget:self withObject:dict];
  } else {
    [NSThread detachNewThreadSelector:@selector(checkinToListingThread:) toTarget:self withObject:dict];
  }

}

- (void)checkinToListingThread:(NSDictionary *)listing
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	[self showProcessing:@"Checking In..."];
	
	NSMutableString *searchString = [[NSMutableString alloc] init];
  [searchString appendFormat:@"&results=json&un=%@&at=%@&listing_id=%@&type=%@&private=%@&twitter=%@&facebook=%@&foursquare=%@&lat=%@&lng=%@",gcLoginUsername,
   authToken, [listing objectForKey:@"listing_id"], [listing objectForKey:@"type"],
   [listing objectForKey:@"private"], [listing objectForKey:@"twitter"], [listing objectForKey:@"facebook"], [listing objectForKey:@"foursquare"],
   [listing objectForKey:@"lat"], [listing objectForKey:@"lng"]];

  if ([[listing objectForKey:@"listing_name"] length] > 0) {
    NSString *formattedName = [[listing objectForKey:@"listing_name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [searchString appendFormat:@"&listing_name=%@", formattedName];
  }
	
	
	if ([[listing objectForKey:@"shout"] length] > 0) {
		NSString *formattedShout = [[listing objectForKey:@"shout"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[searchString appendFormat:@"&shout=%@", formattedShout];
	}
  
  if ([[listing objectForKey:@"foursquareResponse"] length] > 0) {
    NSString *formattedFSResponse = [listing objectForKey:@"foursquareResponse"];
    [searchString appendFormat:@"&foursquare_checkin_in=%@", formattedFSResponse];
  }

	NSMutableData *recievedData = [self sendRequestWithAPI:@"checkin" andParameters:searchString];
	[searchString release];
	NSMutableDictionary *responseToSend = [[NSMutableDictionary alloc] init];

	if ([recievedData length] == 0) {
		[self hideProcessing];
		NSLog(@"No Data Recieved for checkin");
		[responseToSend setObject:@"0" forKey:@"result"];
		[responseToSend setObject:[NSDictionary dictionary] forKey:@"response"];
		[self sendCheckInResult:responseToSend];
		[responseToSend release];
		[self showAlertWithTitle:@"No Data" message:@"No data was recieved from the server.  Please try again later."];			
		[aPool release];
		return;
	}
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
	//NSLog(@"Checkin: %@", tempString);
	
	NSDictionary *result = [tempString JSONValueWithStrings];
	[tempString release];
	NSLog(@"Checkin: %@", result);

	
	if (!result) {
		[responseToSend setObject:@"0" forKey:@"result"];
		[responseToSend setObject:[NSDictionary dictionary] forKey:@"response"];
		[self hideProcessing];
		[self showAlertWithTitle:@"Error"message:@"There was an error processing your status.  Please try again later."];	
		[self sendCheckInResult:responseToSend];
		
		
	} else if ([[result objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		[responseToSend setObject:@"1" forKey:@"result"];
		[responseToSend setObject:result forKey:@"response"];
		[self hideProcessing];
		[self showAlertWithTitle:@"Checkin Status"message:[result objectForKey:@"message"]];
		[self sendCheckInResult:responseToSend];
	} else if ([[result objectForKey:@"api_status"] isEqualToString:@"AUTHENTICATION FAILED"]) {
		[responseToSend setObject:@"0" forKey:@"result"];
		[responseToSend setObject:[NSDictionary dictionary] forKey:@"response"];
		[self hideProcessing];
		[self showSignInFailedWithMessage:[result objectForKey:@"message"]];
		[self sendCheckInResult:responseToSend];

		currentLoginStatus = NO;
	}
	else {			
		[responseToSend setObject:@"0" forKey:@"result"];
		[responseToSend setObject:[NSDictionary dictionary] forKey:@"response"];
		[self hideProcessing];
		[self showAlertWithTitle:@"Error"message:[result objectForKey:@"message"]];
		[self sendCheckInResult:responseToSend];
	}
	[responseToSend release];
	
	[aPool release];
	
}

- (void)sendCheckInResult:(NSMutableDictionary *)result
{
	
	if ([checkinDelegate respondsToSelector:@selector(checkinResult:)]) {
		[checkinDelegate performSelectorOnMainThread:@selector(checkinResult:) withObject:result  waitUntilDone:YES];
	} else {
		NSLog(@"ul checkinDelegate does not respond to checkinResult");
	}
/*	if ([[result objectForKey:@"result"] boolValue]) {
		if ([checkinDelegate conformsToProtocol:@protocol(UIAlertViewDelegate)]) {
			[self performSelectorOnMainThread:@selector(showAlertForCheckinResult:) withObject:result waitUntilDone:YES];
		} else {
			[self showAlertWithTitle:@"Checkin Status"message:[[result objectForKey:@"response"] objectForKey:@"message"]];
		}
	}*/
	
	/*if ([[result objectForKey:@"result"] boolValue]) {
		[self showAlertWithTitle:@"Checkin Status"message:[[result objectForKey:@"response"] objectForKey:@"message"]];
	}*/
}

#pragma mark New account and Login

-(void)askLogin
{
	if ([[GCCommunicator sharedCommunicator] isThereNoInternet]) {
		UIAlertView *login = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"There appears to be no internet connection.  Please try again when connected to a WiFi or celualar data network." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		 [login show];
		 [login release];
		return;
	}
		/*UIAlertView *login = [[UIAlertView alloc] initWithTitle:@"Please Sign In" message:@"You need to be signed into GayCities to proceed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign In to Existing Account", @"Sign Up for GayCities", nil];
		login.tag = 10;
		[login show];
		[login release];*/
	
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = YES;
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	
	GCAskLoginCreateViewController *alcvc = [[GCAskLoginCreateViewController alloc] initWithGreeting:@"Sign in to share your take,\nsee what your friends are up to,\nand meet new people"];
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:alcvc];
	alcvc.gcDelegate = self;
	[gcad.navigationController presentModalViewController:controller animated:YES];
	[controller release];
	[alcvc release];
}

-(void)askLoginFriendUpdates
{
	if ([[GCCommunicator sharedCommunicator] isThereNoInternet]) {
		UIAlertView *login = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"There appears to be no internet connection.  Please try again when connected to a WiFi or celualar data network." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[login show];
		[login release];
		return;
	}
	
	/*UIAlertView *login = [[UIAlertView alloc] initWithTitle:@"Please Sign In" message:@"You need to be signed into GayCities for Friend Updates" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign In to Existing Account", @"Sign Up for GayCities", nil];
	login.tag = 10;
	[login show];
	[login release];*/
	
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = YES;
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	
	GCAskLoginCreateViewController *alcvc = [[GCAskLoginCreateViewController alloc] initWithGreeting:@"You must be a member to proceed"];
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:alcvc];
	alcvc.gcDelegate = self;
	[gcad.navigationController presentModalViewController:controller animated:YES];
	[controller release];
	[alcvc release];
}

-(void)askLoginFirstLaunch
{
	if ([[GCCommunicator sharedCommunicator] isThereNoInternet]) {
		
		return;
	}
	/*UIAlertView *login = [[UIAlertView alloc] initWithTitle:@"Sign In to GayCities" message:@"Signing in allows you to mark your favorite spots, share photos and write reviews" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Sign In to Existing Account", @"Sign Up for GayCities", nil];
	login.tag = 10;
	[login show];
	[login release];*/
	
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = YES;
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	
	GCAskLoginCreateViewController *alcvc = [[GCAskLoginCreateViewController alloc] initWithGreetingInitialLaunch:@"Sign in to share your take,\nsee what your friends are up to,\nand meet new people"];
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:alcvc];
	alcvc.gcDelegate = self;
	[gcad.navigationController presentModalViewController:controller animated:NO];
	[controller release];
	[alcvc release];
}
/*

-(void)createAccount
{
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"USER_ACTION-GC_Account_Being_Created" withParameters:nil];

	[self showProcessing:@"Creating Account..."];

	NSCalendar *gregorian = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:birthdayPicker.date];
	
	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&un=%@&pw=%@&email=%@&birth_month=%i&birth_day=%i&birth_year=%i&gender=%@&ZIP=%@&allow_newsletters=%i",loginUN.text,loginPW.text,loginEmail.text, comps.month, comps.day, comps.year, [genderControl titleForSegmentAtIndex:genderControl.selectedSegmentIndex], loginZip.text, newsletterControl.selectedSegmentIndex];
	[NSThread detachNewThreadSelector:@selector(createAccountThread:) toTarget:self withObject:searchString];
	[searchString release];
}

 */

-(void)createAccountThread:(NSString *)searchString
{

	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSMutableData *recievedData = [self sendRequestWithAPI:@"signup" andParameters:searchString];
	
	if ([recievedData length] <10) {
		NSLog(@"No Data Recieved for create account");
		[self hideProcessing];
		loginChecked = NO;
		currentLoginStatus = NO;
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"gcUserIDKey"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"gcPasswordKey"];
		//self.authToken = nil;
		//self.gcUserIDKey = nil;
		[self performSelectorOnMainThread:@selector(setAuthToken:) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(setGcLoginUsername:) withObject:nil waitUntilDone:YES];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self showNoDataAlert];
		[aPool release];
		return;
	}
	loginChecked = YES;

	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
//	NSLog(@"Create Account: %@", tempString);
	NSMutableDictionary *results = [tempString JSONValueWithStrings];
	[tempString release];
	//NSLog(@"Create Account: %@", results);

	[self hideProcessing];
	
	if (!results) {
		NSLog(@"No Data Recieved for create account");
		[self hideProcessing];
		loginChecked = NO;
		currentLoginStatus = NO;
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"gcUserIDKey"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"gcPasswordKey"];
		//self.authToken = nil;
		//self.gcUserIDKey = nil;
		[self performSelectorOnMainThread:@selector(setAuthToken:) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(setGcLoginUsername:) withObject:nil waitUntilDone:YES];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self showNoDataAlert];
		[self performSelectorOnMainThread:@selector(reportCreateAccountResults:) withObject:nil waitUntilDone:YES];

		[aPool release];
		return;
	}
	
	if ([[results objectForKey:@"api_status"] isEqualToString:@"OK"]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		//self.authToken = [results objectForKey:@"login_token"];
		[self performSelectorOnMainThread:@selector(setAuthToken:) withObject:[results objectForKey:@"login_token"] waitUntilDone:YES];
		[defaults setObject:[results objectForKey:@"login_token"] forKey:@"authToken"];
		[defaults synchronize];
		currentLoginStatus = YES;
		[self showAlertWithTitle:@"Account Created!" message:@"You may now use your account"];
		[self performSelectorOnMainThread:@selector(postUpdateNotification:) withObject:@"1" waitUntilDone:NO];
	}
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[self performSelectorOnMainThread:@selector(setAuthToken:) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(setGcLoginUsername:) withObject:nil waitUntilDone:YES];
		[defaults setObject:@"" forKey:@"authToken"];
		[defaults setObject:@"" forKey:@"gcUserIDKey"];
		[defaults setObject:@"" forKey:@"gcPasswordKey"];
		[defaults synchronize];
		currentLoginStatus = NO;
		
		
	}
	
	[self performSelectorOnMainThread:@selector(reportCreateAccountResults:) withObject:[results objectForKey:@"message"] waitUntilDone:YES];
	
	[aPool release];

}

- (void)reportCreateAccountResults:(NSString *)message
{
	if (!message) {
		//close create account view controller...
	}
	if (!currentLoginStatus && loginChecked) {
		UIAlertView *login = [[UIAlertView alloc] initWithTitle:@"Signup" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
		login.tag = 40;
		[login show];
		[login release];
	}
	
	if ([delegate respondsToSelector:@selector(loginResult:)]) {
		[delegate loginResult:currentLoginStatus];
	} else {
		NSLog(@"User Login Delegate does not respond to loginResult");
	}
}

-(void)createAccountShowView:(BOOL)animated {
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = YES;
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	
	GCCreateAccountViewController *cavc = [[GCCreateAccountViewController alloc] init];
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:cavc];
	//lcivc.communicator = communicator;
	cavc.gcDelegate = self;
	[gcad.navigationController presentModalViewController:controller animated:animated];
	[controller release];
	[cavc release];
}



-(void)createLoginAlert:(BOOL)animated {
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = YES;
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	
	GCLoginViewConroller *lvc = [[GCLoginViewConroller alloc] init];
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:lvc];
	//lcivc.communicator = communicator;
	lvc.gcDelegate = self;
	[gcad.navigationController presentModalViewController:controller animated:animated];
	[controller release];
	[lvc release];
}


- (void)logoutOfAccount {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	self.authToken = nil;
	[defaults setObject:@"" forKey:@"authToken"];
	[defaults setObject:@"" forKey:@"gcUserIDKey"];
	[defaults setObject:@"" forKey:@"gcPasswordKey"];

	self.gcLoginUsername = nil;
	
	
	loginChecked = NO;
	currentLoginStatus = NO;
	
	[defaults setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"gender", @"", @"age", @"", @"profile_image_url", @"", @"city", @"", @"state", nil] forKey:gcUserProfileInformation];
	
	self.userProfileInformation = nil;
	self.profileImageSaved = [UIImage imageNamed:@"add-profile-photo.png"];

	[defaults setObject:[NSData data] forKey:gcUserProfileImageDataFile];

	[defaults synchronize];
  
	[self postUpdateNotification:@"0"];
}




#pragma mark alert and sheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (actionSheet.tag == 10 && buttonIndex == 0) {  //create account 1 (bday)

		//[self createAccountAlert2:@"Create GayCities Account\n\nPlease fill in all fields and click submit\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];
	}
	else if (actionSheet.tag == 20 && buttonIndex == 0) {  //create account 2 (info)
														   //NSLog(@"??? %i %i", buttonIndex, genderControl.selectedSegmentIndex);
		/*if ([loginUN.text length] == 0 || [loginPW.text length] == 0 || [loginEmail.text length] == 0 || genderControl.selectedSegmentIndex == -1  || [loginZip.text length] == 0) {
			[self createAccountAlert2:@"Create GayCities Account\n\nAll fields are required\nPlease try again\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];

		}
		else {
			NSString *username = [loginUN.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			self.gcUserIDKey = username;
			[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"gcUserIDKey"];
			[[NSUserDefaults standardUserDefaults] setObject:loginPW.text forKey:@"gcPasswordKey"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[self createAccount];
			
		}*/
		
	}
	else if (actionSheet.tag == 50 && (buttonIndex == 0 || buttonIndex == 1)) {  //Submit picture sheet
		[[[GayCitiesAppDelegate sharedAppDelegate] mainTabBar] setHidden:YES];
		[[[GayCitiesAppDelegate sharedAppDelegate] adBackgroundView] setHidden:YES];
		[GayCitiesAppDelegate sharedAppDelegate].shouldShowAdView = NO;
		
		if (buttonIndex == 0) {
			
			UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
			ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			ipc.delegate = self;
			[[[GayCitiesAppDelegate sharedAppDelegate] navigationController] presentModalViewController:ipc animated:YES];
			[ipc release];
		} else if (buttonIndex == 1) {
			UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
			ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
			ipc.delegate = self;
			[[[GayCitiesAppDelegate sharedAppDelegate] navigationController] presentModalViewController:ipc animated:YES];
			[ipc release];
			
			
		}


	}
	
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		return;
	}
	
	if (alertView.tag == 10) {
		switch (buttonIndex) {
			case 0://cancel
				break;
			case 1://login
				[self createLoginAlert:YES]; //:@"Please Sign In"]; old
				break;
			case 2://create
				//[self createAccountAlert1:@"\nCreate GayCities Account\n\nPlease enter your bithday and click next\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];
				[self createAccountShowView:YES];
				break;
			
		}
	}
	else if (alertView.tag == 30) {
		switch (buttonIndex) {
			case 0://cancel
				break;
			case 1://login
				[self createLoginAlert:YES];  //:@"Please Sign In"]; old
				break;
		}
	}
	else if (alertView.tag == 40) {
		switch (buttonIndex) {
			case 0://cancel
				break;
			case 1://login
				//[self createAccountAlert1:@"\nCreate GayCities Account\n\nPlease enter your bithday and click next\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];
				[self createAccountShowView:YES];
				break;
		}
	}
}

#pragma mark General methods

- (BOOL)internetAccess
{
	BOOL noInternet = [[GCCommunicator sharedCommunicator] isThereNoInternet];
	
	if (noInternet) {
		[self showAlertWithTitle:@"There appears to be no internet" message:@"Please try again when you are connected to a WiFi or cellular data network"];
		return NO;
	}
		
	return YES;


}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
	[self performSelectorOnMainThread:@selector(showAlertWithTitleAndMessageMain:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", message, @"message", nil] waitUntilDone:NO];
}

- (void)showAlertWithTitleAndMessageMain:(NSDictionary *)strings
{
	[strings retain];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[strings objectForKey:@"title"] message:[strings objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[strings release];
}

- (void)showSignInFailedWithMessage:(NSString *)message
{
	[self performSelectorOnMainThread:@selector(showSignInFailedWithMessageMain:) withObject:message waitUntilDone:NO];
}

- (void)showSignInFailedAlert
{
	[self performSelectorOnMainThread:@selector(showSignInFailedWithMessageMain:) withObject:@"" waitUntilDone:NO];
}

- (void)showSignInFailedWithMessageMain:(NSString *)message
{
	[message retain];
	UIAlertView *failedLogin = [[UIAlertView alloc] initWithTitle:@"Sign In Failed" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign In",nil];
	failedLogin.tag = 30;
	[failedLogin show];
	[failedLogin release];
	[message release];
}

- (void)showNoDataAlert
{
	[self performSelectorOnMainThread:@selector(showNoDataAlertMain) withObject:nil waitUntilDone:NO];
}

- (void)showNoDataAlertMain
{
	UIAlertView *failedLogin = [[UIAlertView alloc] initWithTitle:@"No Data" message:@"No data was recieved from the server.  Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[failedLogin show];
	[failedLogin release];
}

- (void)hideProcessing
{
	[self performSelectorOnMainThread:@selector(hideProcessingMain) withObject:nil waitUntilDone:NO];
}

- (void)hideProcessingMain
{
	[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
}

- (void)showProcessing:(NSString *)text
{
	[self performSelectorOnMainThread:@selector(showProcessingMain:) withObject:text waitUntilDone:YES];
}
- (void)showProcessingMain:(NSString *)text
{
	[[GayCitiesAppDelegate sharedAppDelegate] showProcessing:text];
}

- (NSMutableData *)sendRequestWithAPI:(NSString *)api andParameters:(NSString *)parameters
{
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.gaycities.com/v5/%@", api];
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSMutableString *searchString = [[NSMutableString alloc] initWithString:[self getSearchString]];
		
	[searchString appendString:parameters];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
	[req setHTTPMethod:@"POST"];
//	if (![api isEqualToString:@"findfriends"]) {
		NSLog(@"Search String: %@\nURL:%@", searchString, urlString);
//	}
	[urlString release];

	NSData *sendData = [searchString dataUsingEncoding:NSUTF8StringEncoding];
	[req setHTTPBody:sendData];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[req setValue:[NSString stringWithFormat:@"%llu", [sendData length]] forHTTPHeaderField:@"Content-Length"];
	//NSLog(@"length: %llu", [sendData length]);
	[searchString release];
	
	NSMutableData *recievedData = [[[NSMutableData alloc] init] autorelease];
	
	[recievedData appendData:[NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil]];
	
	return recievedData;
}




-(NSString *)getSearchString
{
	
	srandom(time(NULL));
	int r = (random() % 1000000)+1;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddHH"];
	NSString *c = [NSString stringWithFormat:@"gciphonesecret%@%@%i",[dateFormatter stringFromDate:[[NSDate date] addTimeInterval:-([[NSTimeZone systemTimeZone] secondsFromGMT])]],[[UIDevice currentDevice] uniqueIdentifier],r];
	[dateFormatter release];
	
	
	return [NSString stringWithFormat:@"r=%i&uid=%@&c=%@",r,[[UIDevice currentDevice] uniqueIdentifier], [[self md5Digest:c] substringWithRange:NSMakeRange(0, 7)]];
	
}


- (NSString*) md5Digest:(NSString*)str {
	
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],result[2], result[3],
			result[4], result[5],result[6], result[7],
			result[8], result[9],result[10], result[11],
			result[12], result[13],result[14], result[15]];
}


#pragma mark image pickerView

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];

	self.photo = [info objectForKey:UIImagePickerControllerOriginalImage];
	if (photo) {
		[gcad.navigationController dismissModalViewControllerAnimated:NO];
		if (currentPhotoType == photoSubmitTypeListing) {
			GCSubmitPhotoViewController *gcspvc = [[GCSubmitPhotoViewController alloc] initWithImage:photo showingCaption:YES withDelegate:self];
			UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gcspvc];
			[gcad.navigationController presentModalViewController:nav animated:YES];
			[gcspvc release];
			[nav release];
			
		} else if (currentPhotoType == photoSubmitTypeProfile) {
			GCSubmitPhotoViewController *gcspvc = [[GCSubmitPhotoViewController alloc] initWithImage:photo showingCaption:NO withDelegate:self];
			UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gcspvc];
			[gcad.navigationController presentModalViewController:nav animated:YES];
			[gcspvc release];
			[nav release];
			
		}
		
	} else {
		[gcad.navigationController  dismissModalViewControllerAnimated:YES];
		gcad.mainTabBar.hidden = NO;
		gcad.adBackgroundView.hidden = NO;
		gcad.shouldShowAdView = YES;
		NSLog(@"No Photo Data from image picker");
	}
	

}

/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	NSLog(@"Image Picker Dep Method");
}
 */




- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	currentPhotoType = 0;
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];

	[gcad.navigationController  dismissModalViewControllerAnimated:YES];
	
	[[gcad mainTabBar] setHidden:NO];
	[[gcad adBackgroundView] setHidden:NO];
	gcad.shouldShowAdView = YES;

}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1]];
}

- (void)willCloseSubmitPhotoViewController:(GCSubmitPhotoViewController *)submitPhotoViewController
{
	if ([submitPhotoViewController.captionLabel.text length] > 0) {
		self.photoCaption = submitPhotoViewController.captionLabel.text;
	} else {
		self.photoCaption = @"";
	}
	[self sendPhoto];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];

	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;

}

- (void)willCancelSubmitPhotoViewController:(GCSubmitPhotoViewController *)submitPhotoViewController
{
	currentPhotoType = 0;
	self.photo = nil;
	self.photoCaption = @"";
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];

	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;

}




#pragma mark LoginViewController Delegates

- (void)willCloseLoginViewController:(GCLoginViewConroller *)loginViewController
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [loginViewController.usernameText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	self.gcLoginUsername = username;
	[defaults setObject:username forKey:@"gcUserIDKey"];
	[defaults setObject:loginViewController.passwordText forKey:@"gcPasswordKey"];
	[defaults synchronize];
	[self processNewLogin];
	
}

- (void)willCancelLoginViewController:(GCLoginViewConroller *)loginViewController
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
  currentLoginStatus = NO;
  if ([delegate respondsToSelector:@selector(loginResult:)]) {
		[delegate loginResult:currentLoginStatus];
	}
}

#pragma mark SubmitNewBusiness Delegates


- (void)willCloseSumbitNewBusinessViewController:(GCSubmitNewBusinessViewController *)viewController
{
	[viewController retain];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	//listingType, businessName, add_street, add_city, add_state, add_zip, phone, url, neighborhood_id;  metro 
	// stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *newName = [viewController.businessName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *newType = [viewController.listingType stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableDictionary *extras = [[NSMutableDictionary alloc] initWithObjectsAndKeys:newName, @"name", newType, @"type", viewController.metro.metro_id, @"metro_id", nil];
	if ([viewController.add_street length] > 0) {
		[extras setObject:[viewController.add_street stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"add_street"];
	}
	if ([viewController.add_city length] > 0) {
		[extras setObject:[viewController.add_city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"add_city"];
	}
	if ([viewController.add_state length] > 0) {
		[extras setObject:[viewController.add_state stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"add_state"];
	}
	if ([viewController.add_zip length] > 0) {
		[extras setObject:[viewController.add_zip stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"add_zip"];
	}
	if ([viewController.phone length] > 0) {
		[extras setObject:[viewController.phone stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"phone"];
	}
	if ([viewController.url length] > 0) {
		[extras setObject:[viewController.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"url"];
	}
	if ([viewController.neighborhood_id length] > 0) {
		[extras setObject:[viewController.neighborhood_id stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"neighborhood_id"];
	}
	
	[NSThread detachNewThreadSelector:@selector(submitNewBusinessThread:) toTarget:self withObject:extras];
	[extras release];
	 
	[viewController release];
}

- (void)willCancelSumbitNewBusinessViewController:(GCSubmitNewBusinessViewController *)viewController
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
}

# pragma mark create accoutbn delegate

- (void)willCloseCompletedCreateAccountViewController:(GCCreateAccountViewController *)createAccountViewController
{
	NSString *username = [createAccountViewController.createUsername stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	self.gcLoginUsername = username;
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"gcUserIDKey"];
	[[NSUserDefaults standardUserDefaults] setObject:createAccountViewController.createPassword forKey:@"gcPasswordKey"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	[gcad logEventForFlurry:@"USER_ACTION-GC_Account_Being_Created" withParameters:nil];
  
  NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:createAccountViewController.birthDate];
  age = age / (60 * 60 * 24 * 7 * 52);
  NSLog(@"Age: %f", age);
	[Flurry setAge:floor(age)];
  
	[self showProcessing:@"Creating Account..."];
	
  
	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&un=%@&pw=%@&email=%@&birth_month=%i&birth_day=%i&birth_year=%i&gender=%@&ZIP=%@&allow_newsletters=%i",username,[createAccountViewController.createPassword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[createAccountViewController.createEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [createAccountViewController.createBirthMonth intValue], [createAccountViewController.createBirthDay intValue], [createAccountViewController.createBirthYear intValue], createAccountViewController.createGender, [createAccountViewController.createZip stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [createAccountViewController.createNewsletterOption intValue]];
//	NSLog(@"CreateAccount String: %@", searchString);
	[NSThread detachNewThreadSelector:@selector(createAccountThread:) toTarget:self withObject:searchString];
	[searchString release];
}

- (void)willCancelCreateAccountViewController:(GCCreateAccountViewController *)createAccountViewController
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
}

#pragma mark AskOrLoginVCDelegate

- (void)willCloseAskLoginCreateViewControllerToCreate:(GCAskLoginCreateViewController *)askLoginCreateViewController
{

	[self createAccountShowView:NO];
	
}

- (void)willCloseAskLoginCreateViewControllerToLogin:(GCAskLoginCreateViewController *)askLoginCreateViewController withUsername:(NSString *)loginName andPassword:(NSString *)loginPassword;
{

	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.gcLoginUsername = loginName;
	[defaults setObject:loginName forKey:@"gcUserIDKey"];
	[defaults setObject:loginPassword forKey:@"gcPasswordKey"];
	[defaults synchronize];
	[self processNewLogin];
}


- (void)willCancelAskLoginCreateViewController:(GCAskLoginCreateViewController *)askLoginCreateViewController
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
}



#pragma mark Data Report Delegates

- (void)willCloseDataReportViewController:(GCDataReportVC *)dataReportViewController
{
	self.reviewYear = [NSString stringWithFormat:@"%i", dataReportViewController.year];
	self.reviewMonth = [OCConstants monthForNumber:dataReportViewController.month];
  NSString *reportText = dataReportViewController.reportTextView.text;
	dataComment = [reportText length] > 0 ? [reportText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"";
	[self sendReport];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
}


- (void)willCancelDataReportViewController:(GCDataReportVC *)dataReportViewController
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
}


#pragma mark Review Delegates

- (void)willCloseReviewViewController:(GCReviewVC *)reviewViewController
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	
	[self showProcessing:@"Submitting Review..."];
	NSMutableString *searchString = [[NSMutableString alloc] initWithString:@"&results=json"];
	
	
	if (reviewUpdate) {
		[searchString appendFormat:@"&un=%@&at=%@&listing_id=%@&type=%@&rating=%1.0f&visited_year=%i&visited_month=%i&update=%@",gcLoginUsername,
		 authToken, reviewListingID, reviewType, [reviewViewController.reviewRating value], reviewViewController.year, reviewViewController.month, @"1"];
	}
	else {
		[searchString appendFormat:@"&un=%@&at=%@&listing_id=%@&type=%@&rating=%1.0f&visited_year=%i&visited_month=%i&update=%@",gcLoginUsername,
		 authToken, reviewListingID, reviewType, [reviewViewController.reviewRating value], reviewViewController.year, reviewViewController.month, @"0"];
	}
	self.reviewListingID = @"";
	self.reviewType = @"";
	reviewUpdate = NO;
	
	if ([reviewViewController.reviewTitle.text length] > 0) {
		[searchString appendFormat:@"&review_title=%@", reviewViewController.reviewTitle.text];
	}
	
	if ([reviewViewController.reviewText.text length] > 0) {
		[searchString appendFormat:@"&review_text=%@", reviewViewController.reviewText.text];
	}
	[NSThread detachNewThreadSelector:@selector(submitReviewFinalThread:) toTarget:self withObject:searchString];
	[searchString release];

}


- (void)willCancelReviewViewController:(GCReviewVC *)reviewViewController
{
	self.reviewListingID = @"";
	self.reviewType = @"";
	reviewUpdate = NO;
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.mainTabBar.hidden = NO;
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	
	
	
}




@end
