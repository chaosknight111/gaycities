//
//  GCMoPubContainerViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/21/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "GCMoPubContainerViewController.h"
#import "GayCitiesAppDelegate.h"

@implementation GCMoPubContainerViewController

- (UIViewController *)viewControllerForPresentingModalView {
  return self;
}

- (void)willPresentModalViewForAd:(MPAdView *)view {
  [[GayCitiesAppDelegate sharedAppDelegate] willPresentModalViewForAd:view];
}

- (void)didDismissModalViewForAd:(MPAdView *)view {
  [[GayCitiesAppDelegate sharedAppDelegate] didDismissModalViewForAd:view];
}

//- (void)adViewDidFailToLoadAd:(MPAdView *)view {
//
//}
//
//- (void)adViewDidLoadAd:(MPAdView *)view {
//
//}

// Dismiss the interstitial.
- (void)dismissInterstitial:(MPInterstitialAdController *)interstitial
{
  [self dismissModalViewControllerAnimated:YES];
}

// Present the ad only after it is ready.
//- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
//{
//  [interstitial show];
//}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
  [[GayCitiesAppDelegate sharedAppDelegate] setShowingModalAd:YES];
  [[[GayCitiesAppDelegate sharedAppDelegate] window] bringSubviewToFront:self.view];
}

//- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
//  
//}
//
//- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
//  
//}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
  [[[GayCitiesAppDelegate sharedAppDelegate] window] sendSubviewToBack:self.view];
  [[GayCitiesAppDelegate sharedAppDelegate] setShowingModalAd:NO];
}

/*
 * Interstitial ads from certain networks (e.g. iAd) may expire their content at any time, 
 * regardless of whether the content is currently on-screen. This callback notifies you when the
 * currently-loaded interstitial has expired and is no longer eligible for display. If the ad
 * was on-screen when it expired, you can expect that the ad will already have been dismissed 
 * by the time this callback was fired. Your implementation of this method does not need to include 
 * logic to dismiss an interstitial. It may include a call to -loadAd to fetch a new ad, if desired.
 */
- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
	
}


@end
