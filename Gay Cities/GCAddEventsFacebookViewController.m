//
//  GCAddEventsFacebookViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/22/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "GCAddEventsFacebookViewController.h"
#import "GayCitiesAppDelegate.h"
#import "OCConstants.h"

@implementation GCAddEventsFacebookViewController

@synthesize topLabel, bottomLabel;
@synthesize fbConnectButton;
@synthesize gcad;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  self.gcad = [GayCitiesAppDelegate sharedAppDelegate];
  self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
  UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(facebookSigninSuccess:) name:gcFacebookLoginStatusSuccess object:nil];
	[nc addObserver:self selector:@selector(facebookSigninNone:) name:gcFacebookLoginStatusNone object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [gcad.mainTabBar setHidden:YES];
  [gcad.adBackgroundView setHidden:YES];
  gcad.shouldShowAdView = NO;
  

  
  UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeMe)];
  self.navigationItem.leftBarButtonItem = closeButton;
  [closeButton release];
  
  if (gcad.connectController.hasSavedFacebook) {
    topLabel.text = @"You have already signed in with your Facebook account.";
    bottomLabel.text = @"Only your public events will ever make it in our\ncalendar and we'll always respect your privacy.\n\nIf you would like to logout or change your current Facebook account, select the 'People' tab below and tap 'Options' in the top right.\n\n\n";
    fbConnectButton.enabled = NO;
    
  } else {
    topLabel.text = @"Connect with Facebook and help us\nbuild our events calendar in your area.";
    bottomLabel.text = @"Only your public events will ever make it in our\ncalendar and we'll always respect your privacy.\n\n\n\n\n\n";
    fbConnectButton.enabled = YES;
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (gcad.connectController.hasSavedFacebook && !gcad.connectController.fbExtendedPermission) {
    NSLog(@"Add events check fb permissions?");
//    fbConnectButton.enabled = NO;
//    [gcad.connectController checkExtendedPermissions:NO];
    //show extended auth agreement...
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [gcad.mainTabBar setHidden:NO];
  [gcad.adBackgroundView setHidden:NO];
  gcad.shouldShowAdView = YES;
  [[NSNotificationCenter defaultCenter] removeObserver:self];  
}

- (IBAction)connectWithFacebook:(id)sender
{
  [gcad.connectController signInOrLogoutFacebook];
}

- (void)facebookSigninSuccess:(NSNotification *)note {
  [self closeMe];
}

- (void)facebookSigninNone:(NSNotification *)note {
  [self closeMe];
}

- (void)closeMe {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
  [super viewDidUnload];
}


- (void)dealloc {
  self.topLabel = nil;
  self.bottomLabel = nil;
  self.fbConnectButton = nil;
  [super dealloc];
}


@end
