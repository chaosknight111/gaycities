//
//  UserLogin.h
//  Gay Cities
//
//  Created by Brian Harmann on 6/13/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BAUIStarSlider;
#import "GCUserLoginDelegate.h"
#import "GCLoginViewConroller.h"
#import "GCSubmitNewBusinessViewController.h"
#import "GCCreateAccountViewController.h"
#import "GCAskLoginCreateViewController.h"
#import "GCSubmitPhotoViewControllerDelegate.h"
#import "GCDataReportVCDelegate.h"
#import "GCReviewVCDelegate.h"

typedef enum PhotoSubmitType {
	photoSubmitTypeListing = 1,
	photoSubmitTypeProfile = 2
} PhotoSubmitType;

typedef enum FriendActionEnum {
	friendActionNone = -1,
	friendAddAction = 0,
	friendRemoveAction = 1,
	friendInviteNewAction = 2
} FriendActionEnum;

@interface GCUserLogin : NSObject <UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GCLoginViewControllerDelegate, GCSubmitNewBusinessViewControllerDelegate, GCCreateAccountViewControllerDelegate, GCAskLoginCreateViewControllerDelegate, GCSubmitPhotoViewControllerDelegate, GCDataReportVCDelegate, GCReviewVCDelegate> {
	NSString *reviewListingID, *reviewType, *reviewYear, *reviewMonth, *authToken, *gcLoginUsername;
	bool reviewUpdate;
	bool reviewVisitedShown;
	NSString *photoListingID, *photoType;
	NSString *photoCaption, *dataComment;
	UIImage *photo, *profileImageSaved;
	BOOL loginChecked, currentLoginStatus;
	NSObject<GCUserLoginDelegate> *delegate, *checkinDelegate;
	NSMutableDictionary *userProfileInformation;
	PhotoSubmitType currentPhotoType;
}

@property (nonatomic, retain) NSString *reviewListingID, *reviewType, *reviewYear, *reviewMonth, *authToken, *gcLoginUsername;
@property (nonatomic, retain) NSString *photoListingID, *photoType;
@property (nonatomic, retain) NSString *photoCaption;
@property (nonatomic, retain) UIImage *photo, *profileImageSaved;
@property (readonly) BOOL loginChecked, currentLoginStatus;
@property (nonatomic, assign) NSObject<GCUserLoginDelegate> *delegate, *checkinDelegate;
@property (nonatomic, retain) NSMutableDictionary *userProfileInformation;

- (BOOL)isSignedIn;
- (BOOL)internetAccess;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void)showSignInFailedWithMessage:(NSString *)message;
- (void)showSignInFailedAlert;
- (void)showNoDataAlert;
- (NSMutableData *)sendRequestWithAPI:(NSString *)api andParameters:(NSString *)parameters;
-(NSString *)getSearchString;
- (void)processNewLogin;
- (void)checkChangedLogin;
-(NSString *)checkLogin;
-(NSString*) md5Digest:(NSString*)str;

-(void)attendEvent:(NSString *)eventID status:(NSString *)eventStatus shout:(NSString *)shout;
- (void)attendEventThread:(NSDictionary *)dict;

-(void)askLogin;
-(void)askLoginFriendUpdates;
-(void)askLoginFirstLaunch;
-(void)createLoginAlert:(BOOL)animated;
-(void)createAccountShowView:(BOOL)animated;
- (void)logoutOfAccount;


-(NSDictionary *)checkListingStatus:(NSString *)listingID type:(NSString *)type;
-(void)makeFan:(NSString *)listingID type:(NSString *)type status:(NSString *)status;
- (void)makeFanThread:(NSDictionary *)dict;
-(void)submitReview:(NSString *)listingID type:(NSString *)type update:(NSString *)update previousReview:(NSDictionary *)review;
-(void)submitDataReport:(NSString *)listingID type:(NSString *)type;
-(void)sendReport;
-(void)sendPhoto;
-(void)submitProfilePhoto;

-(void)uploadPhoto:(NSString *)listingID type:(NSString *)type;

-(void)hideProcessing;
-(void)showProcessing:(NSString *)text;

- (BOOL)checkLoginReturningBOOLThread;
- (BOOL)shouldCheckInToListing;
- (void)sendCheckInResult:(NSMutableDictionary *)result;
- (void)checkInToListing:(NSString *)listing_id name:(NSString *)listing_name type:(NSString *)type shout:(NSString *)shout private:(NSString *)private facebook:(NSString *)facebook twitter:(NSString *)twitter foursquare:(NSString *)foursquare lat:(NSString *)lat lng:(NSString *)lng foursquareResponse:(NSString *)response;
- (void)checkinToListingThread:(NSDictionary *)listing;

- (void)submitNewBusiness:(NSString *)newName forMetro:(GCMetro *)metro withTypes:(NSArray *)types andHoods:(NSArray *)hoods;
//-(BOOL)canSubmitBusiness;

- (void)findAllFriendsFromLocalAB;
- (void)findFriendsAfterAccountVerified;
- (void)submitFriendActionWithUsernameOrEmail:(NSString *)usernameOrEmail andAction:(FriendActionEnum)newAction withName:(NSString *)passedFullName;
- (void)findFriendsWithSearchData:(NSString *)searchString andParameter:(NSString *)queryString;

- (void)submitTwitterInfoWithUsername:(NSString *)twitterUsername oAuth:(NSString *)twitterOAuth andID:(NSString *)twitterID andSecret:(NSString *)secret;
- (void)submitFacebookInfoWithSession:(NSString *)fbSession andfbUID:(NSString *)fbID;

- (void)showImagePickerController;
- (void)findAllFriendsFromFacebook;
- (void)findSocialFriendsAfterAccountVerified:(NSString *)type;
- (void)findAllFriendsFromTwitter;

- (void)checkFoursquareLoginWithStatus:(BOOL)flag;

@end
