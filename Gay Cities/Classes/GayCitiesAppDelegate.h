//
//  Gay_CitiesAppDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 11/21/08.
//  Copyright Obsessive Code 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OCFMDatabase;

#import "FBConnect.h"
#import <CoreLocation/CoreLocation.h>
#import "GCConnectController.h"
#import "Flurry.h"
#import "MPAdView.h"
#import "GCMoPubContainerViewController.h"

#ifndef __IPHONE_3_0
#define __IPHONE_3_0 30000
#endif
#ifndef __IPHONE_4_0
#define __IPHONE_4_0 40000
#endif

@class MPInterstitialAdController;

typedef enum GCStartUpTabPrefernce {
	GCStartupPeople = 1,
	GCStartupCheckin = 2,
	GCStartupMap = 3,
	GCStartupLastTab = 4
} GCStartUpTabPrefernce;

@interface GayCitiesAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate, MPAdViewDelegate> {
  UIWindow *window;
  UINavigationController *navigationController;
	UITabBar *mainTabBar;
	UIView *processingView, *adBackgroundView;
	UIActivityIndicatorView *processingActivity;
	UILabel *processingLabel;
	int addCount;
	float viewHeight;
	BOOL shouldShowAdView, messageShown, showingModalAd;
	GCConnectController *connectController;
	GCMoPubContainerViewController *adViewController;
	UITabBarItem *nearbyItem, *browseItem, *myListItem, *peopleItem, *checkinItem, *eventItem;
  MPInterstitialAdController *_interstitialAdController;
  NSTimer *_interstitialTimer;
	MPAdView *_adView;
	BOOL interstitialShownThisSession;
}

@property (nonatomic, retain) UITabBarItem *nearbyItem, *browseItem, *myListItem, *peopleItem, *checkinItem, *eventItem;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) UITabBar *mainTabBar;
@property (nonatomic, retain) IBOutlet UIView *processingView;
@property (nonatomic, retain) UIView *adBackgroundView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *processingActivity;
@property (nonatomic, retain) IBOutlet UILabel *processingLabel;
@property (readwrite) float viewHeight;
@property (readwrite) BOOL shouldShowAdView, showingModalAd;
@property (nonatomic, retain) GCConnectController *connectController;
@property (nonatomic, retain) IBOutlet GCMoPubContainerViewController *adViewController;
@property (nonatomic, retain) MPInterstitialAdController *interstitialAdController;

+ (GayCitiesAppDelegate *)sharedAppDelegate;


-(void)showProcessing:(NSString *)text;
-(void)hideProcessing;
- (void)upgradeDatabaseFor25;
- (void)startAds;
- (void)logEventForFlurry:(NSString *)event withParameters:(NSDictionary *)parameters;
- (void)setNewLocationForFlurry:(CLLocation *)newLoc;

// ads hide and show

- (void)showAdsAndTabbarAgain;
- (void)hideAdsAndTabBarForNow;
- (void)showAdsAgain;
- (void)hideAdsForNow;



@end

