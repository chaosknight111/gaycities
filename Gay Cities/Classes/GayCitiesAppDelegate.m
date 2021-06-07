//
//  Gay_CitiesAppDelegate.m
//  Gay Cities
//
//  Created by Brian Harmann on 11/21/08.
//  Copyright Obsessive Code 2008. All rights reserved.
//

#import "GayCitiesAppDelegate.h"
#import "RootViewController.h"
#import "OCFMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "OCConstants.h"
#import "OCWebViewController.h"
#import "MPInterstitialAdController.h"
#import "ASIHTTPRequest.h"
#import "UncaughtExceptionHandler.h"
#import "HockeySDK.h"

#define kMPAdUnitKey @"agltb3B1Yi1pbmNyDQsSBFNpdGUY9ZLrBAw"
#define kMPAdUnitInterstitialKey @"agltb3B1Yi1pbmNyDQsSBFNpdGUYzdqaBQw"
#define kHockeyAppTestID @"9ca591c58290937caba314e617a82077"
#define kHockeyAppLiveID @"9ca591c58290937caba314e617a82077"

@interface GayCitiesAppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>

@end

@implementation GayCitiesAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize mainTabBar;
@synthesize processingView, processingActivity, processingLabel, adBackgroundView;
@synthesize viewHeight;
@synthesize shouldShowAdView, showingModalAd;
@synthesize connectController;
@synthesize adViewController;
@synthesize nearbyItem, browseItem, myListItem, peopleItem, checkinItem, eventItem;
@synthesize interstitialAdController=_interstitialAdController;

+ (void)initialize
{
	NSDictionary *appDefaults =  [[NSDictionary alloc] initWithObjectsAndKeys:
						@"", @"gcUserIDKey",
						@"", @"gcPasswordKey",
						@"0", @"gcStartupKey", 
            @"0", firstLaunch, 
            @"20", @"selectedTab", 
            @"", @"authToken",
						@"0", gc25FirstLaunch,  
            @"0", gc25DetailIndexCreated, 
            @"0", gc25ReviewIndexCreated, 
            @"0", fbConnectExtendedPermissionGranted, 
            @"", fbConnectUserIDKey, 
            @"", fbConnectUsernameKey,
						@"", gcTwitterUsernameKey, 
            [NSDictionary dictionary], gcTwitterUserDictionaryKey, 
            @"-1", gcSavedHomeMetro, 
            @"0", gcSavedLatitude, 
            @"0", gcSavedLongitude , 
            @"-2", gcSavedPreviousMetro,
            [NSArray array], gcShownServerMessages, 
            [NSArray array], gcPendingServerMessages, 
            @"1", gcStartupTabSelected,
            [NSDictionary dictionaryWithObjectsAndKeys:@"", @"gender", @"", @"age", @"", @"profile_image_url", @"", @"city", @"", @"state", nil], gcUserProfileInformation, 
            [NSData data], gcUserProfileImageDataFile, 
            @"0", gcTwitterCredentialsSentKey, 
            @"0", gcFacebookCredentialsSentKey, 
            @"", gcTwitterOAuthDataKey, 
            [NSArray array], gcRecentMetrosKey, 
            @"", gcFoursquareTokenKey, nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[appDefaults release];
	

}

+ (GayCitiesAppDelegate *)sharedAppDelegate
{
    return (GayCitiesAppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - BITUpdateManagerDelegate

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}

#pragma mark -

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  if (!connectController) {
    connectController = [[GCConnectController alloc] init];
  }
  return [connectController.facebook handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (![connectController communicator]) return;
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger startupLocation = [defaults integerForKey:@"gcStartupKey"];
  if (startupLocation == gcStartupKeyCurrentLocation) [[connectController communicator] findMe:GCLocationSearchGlobal];
  else [[connectController communicator] findMe:GCLocationSearchCheckins];
  
  [window performSelectorOnMainThread:@selector(sendSubviewToBack:) withObject:self.adViewController.view waitUntilDone:NO];
  
  if ([defaults integerForKey:firstLaunch] == 1) {
    [self showAdsAndTabbarAgain];
    
    self.interstitialAdController = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMPAdUnitInterstitialKey];
    self.interstitialAdController.parent = self.adViewController;
    [self.interstitialAdController loadAd];
    
	  interstitialShownThisSession = NO;
	  _interstitialTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(interstitialTimerFired:) userInfo:nil repeats:NO];
  }
}

- (void)installUncaughtExceptionHandler
{
	InstallUncaughtExceptionHandler();
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:kHockeyAppTestID
                                                         liveIdentifier:kHockeyAppLiveID
                                                               delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
	// [self installUncaughtExceptionHandler];
    
    self.window.frame = [UIScreen mainScreen].bounds;

	[Flurry startSession:@"41UE6YVKMMK2MMKZ3JYJ"];  // bc - I5M25YJEWCCC4UZGVMZ6
	//[FlurryAPI startSession:@"I5M25YJEWCCC4UZGVMZ6"];  // gc - 41UE6YVKMMK2MMKZ3JYJ
	NSString *osString = [[NSString alloc] initWithFormat:@"%@-OS_VERSION", [[UIDevice currentDevice] systemVersion]];
	[Flurry logEvent:osString];
	[osString release];
	
  self.showingModalAd = NO;
	addCount = 0;
	viewHeight = CGRectGetHeight(window.bounds) - 113.f;
	// Configure and show the window
	//[window addSubview:mainView];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	processingView.hidden = YES;
	shouldShowAdView = YES;
	messageShown = NO;
	NSString *bundlePath = [[NSString alloc] initWithString:[[NSBundle mainBundle] bundlePath]];	
	nearbyItem = [[UITabBarItem alloc] initWithTitle:@"Map" image:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"globeicon2.png"]] tag:10];
	browseItem = [[UITabBarItem alloc] initWithTitle:@"Places" image:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"tab_icon_list.png"]] tag:20];
	myListItem = [[UITabBarItem alloc] initWithTitle:@"My List" image:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"tab_icon_star.png"]] tag:30];
	peopleItem = [[UITabBarItem alloc] initWithTitle:@"People" image:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"peopleTabIcon.png"]] tag:40];
	checkinItem = [[UITabBarItem alloc] initWithTitle:@"Check In" image:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"checkinTabIcon.png"]] tag:50];
	eventItem = [[UITabBarItem alloc] initWithTitle:@"Events" image:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"eventsTabIcon.png"]] tag:60];
	
	NSArray *tabItems = [[NSArray alloc] initWithObjects:checkinItem, nearbyItem, browseItem, eventItem, myListItem, peopleItem, nil];
	mainTabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(window.bounds) - 49.f, 320, 49)];
	
	[mainTabBar setDelegate:(RootViewController *)[[navigationController viewControllers] objectAtIndex:0]];
	[mainTabBar setItems:tabItems animated:NO];
	
	[tabItems release];

	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"gc.db"];
	
	
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:gc25FirstLaunch]) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

		if ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]) {
			[userDefaults setObject:@"1" forKey:@"gcStartupKey"];
			[userDefaults setObject:@"3" forKey:gcStartupTabSelected];
		}
		//[userDefaults synchronize];
		[userDefaults setBool:YES forKey:gc25FirstLaunch];
		[userDefaults synchronize];

	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL startup = [defaults boolForKey:@"gcStartupKey"];

	if (!startup) {
		int tabToSelect = [[defaults stringForKey:gcStartupTabSelected] intValue];
		if (tabToSelect == GCStartupPeople) {
			[mainTabBar setSelectedItem:peopleItem];
		} else if (tabToSelect == GCStartupCheckin) {
			[mainTabBar setSelectedItem:checkinItem];
		} else if (tabToSelect == GCStartupMap) {
			[mainTabBar setSelectedItem:nearbyItem];
		} else {
			
			int tabBarSelected = [[defaults objectForKey:@"selectedTab"]intValue];
			if (tabBarSelected==10) {
				[mainTabBar setSelectedItem:nearbyItem];
			}
			else if (tabBarSelected==20) {
				[mainTabBar setSelectedItem:browseItem];
			}
			else if (tabBarSelected==30) {
				[mainTabBar setSelectedItem:myListItem];
			}
			else if (tabBarSelected==40) {
				[mainTabBar setSelectedItem:peopleItem];
			}else if (tabBarSelected==50) {
				[mainTabBar setSelectedItem:checkinItem];
			} else {
				[mainTabBar setSelectedItem:eventItem];
			}
		}
	} else {

		
		int tabBarSelected = [[defaults objectForKey:@"selectedTab"]intValue];
		if (tabBarSelected==10) {
			[mainTabBar setSelectedItem:nearbyItem];
		}
		else if (tabBarSelected==20) {
			[mainTabBar setSelectedItem:browseItem];
		}
		else if (tabBarSelected==30) {
			[mainTabBar setSelectedItem:myListItem];
		}
		else if (tabBarSelected==40) {
			[mainTabBar setSelectedItem:peopleItem];
		}else if (tabBarSelected==50) {
			[mainTabBar setSelectedItem:checkinItem];
		} else {
			[mainTabBar setSelectedItem:eventItem];
		}
	}
	
	
	
	
	
	
	success = [fileManager fileExistsAtPath:dbPath];  //copy the database to the app for saved data
	if (success) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		BOOL detailIndexCreated = [defaults boolForKey:gc25DetailIndexCreated];
		BOOL reviewIndexCreated = [defaults boolForKey:gc25ReviewIndexCreated];
		//BOOL threeTwoDatabaseUpdated = [defaults boolForKey:gc32DatabaseUpdateComplete];
		
		if (!detailIndexCreated || !reviewIndexCreated) {
			[self showProcessing:@"Upgrading database to new version..."];
			[NSThread detachNewThreadSelector:@selector(upgradeDatabaseFor25) toTarget:self withObject:nil];

		}
	}
	else {
		success = [fileManager copyItemAtPath:[bundlePath stringByAppendingPathComponent:@"gc.db"] toPath: dbPath error:&error];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:YES forKey:gc25DetailIndexCreated];
		[defaults setBool:YES forKey:gc25ReviewIndexCreated];
		//[defaults setBool:YES forKey:gc32DatabaseUpdateComplete];

		[defaults synchronize];
	}
	if (!success) {
		NSAssert1(0, @"Failed to copy database: %@", [error localizedDescription]);
	}
	
	NSString *metroPath = [documentsDirectory stringByAppendingPathComponent:@"allMetros.sqlite"];
	success = [fileManager fileExistsAtPath:metroPath];  //copy the database to the app for saved data

	if (success) {
		[NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(showServerMessage:) userInfo:nil repeats:NO];
		
	}
	else {
		success = [fileManager copyItemAtPath:[bundlePath stringByAppendingPathComponent:@"allMetros.sqlite"] toPath: metroPath error:&error];
	}
	if (!success) { 
		NSAssert1(0, @"Failed to copy metros database: %@", [error localizedDescription]);
	}
	
	[bundlePath release];

	if (!connectController) {
    connectController = [[GCConnectController alloc] init];
  }
	
	adBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(window.bounds) - 98.f, 320, 50)];
	adBackgroundView.backgroundColor = [UIColor blackColor];
//  adBackgroundView.layer.borderWidth = 1.0;
//  adBackgroundView.layer.borderColor = [[UIColor blackColor] CGColor];
  
	[window addSubview:adBackgroundView];
	[window addSubview:[self.adViewController view]];
	[window addSubview:[navigationController view]];
	[window addSubview:mainTabBar];
  
	[window makeKeyAndVisible];

	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	navigationController.navigationBar.topItem.titleView = titleView;
	[titleView release];
	[navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1]];
	
	[mainTabBar release];
}


- (void)showServerMessage:(NSTimer *)timer
{
	if (!shouldShowAdView) {
		[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(showServerMessage:) userInfo:nil repeats:NO];
		return;
	}
	
	if (![[GCCommunicator sharedCommunicator] messagesRecieved]) {
		[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(showServerMessage:) userInfo:nil repeats:NO];
		return;
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSMutableArray *pendingMessages = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:gcPendingServerMessages]];
	NSMutableArray *sentMessages = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:gcShownServerMessages]];
	NSMutableArray *messagesToRemove = [[NSMutableArray alloc] init];
	for (NSDictionary *newMessage in pendingMessages) {
		if ([[newMessage objectForKey:@"expires"] doubleValue] < [[NSDate date] timeIntervalSince1970]) {
			[messagesToRemove addObject:newMessage];
		}
	}
	
	if ([messagesToRemove count] > 0) {
		for (NSDictionary *aMessage in messagesToRemove) {
			[sentMessages addObject:aMessage];
			[pendingMessages removeObject:aMessage];
		}
		[defaults setObject:pendingMessages forKey:gcPendingServerMessages];
		[defaults setObject:sentMessages forKey:gcShownServerMessages];
		[defaults synchronize];
	}
	
	
	[pendingMessages release];
	[sentMessages release];
	[messagesToRemove release];
	
	
	[NSThread detachNewThreadSelector:@selector(showServerMessageThread) toTarget:self withObject:nil]; 
	
	
}

- (void)showServerMessageThread
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *pendingMessages = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:gcPendingServerMessages]];
	
	if ([pendingMessages count] == 0) {
		[pendingMessages release];
		[aPool release];
		return;
	}
	NSLog(@"Pending Messages: %@", pendingMessages);
	
	NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
	
	for (NSDictionary *newMessage in pendingMessages) {
		if ([newMessage objectForKey:@"expires"]) {
			if ([[newMessage objectForKey:@"expires"] doubleValue] > [[NSDate date] timeIntervalSince1970] || [[newMessage objectForKey:@"expires"] doubleValue] == 0) {
				if ([message count] == 0) {
					[message setDictionary:newMessage];
				} else if ([[message objectForKey:@"priority"] intValue] > [[newMessage objectForKey:@"priority"] intValue]) {
					[message setDictionary:newMessage];
				} else if ([[message objectForKey:@"id"] intValue] > [[newMessage objectForKey:@"id"] intValue]) {
					[message setDictionary:newMessage];
				}
			}
		}else if ([message count] == 0) {
			[message setDictionary:newMessage];
		} else if ([[message objectForKey:@"priority"] intValue] > [[newMessage objectForKey:@"priority"] intValue]) {
			[message setDictionary:newMessage];
		} else if ([[message objectForKey:@"id"] intValue] > [[newMessage objectForKey:@"id"] intValue]) {
			[message setDictionary:newMessage];
		}
	}	
	
	if ([message objectForKey:@"expires"]) {
		if ([[message objectForKey:@"expires"] doubleValue] < [[NSDate date] timeIntervalSince1970] && [[message objectForKey:@"expires"] doubleValue] > 0) {
			[message release];
			[pendingMessages release];
			[aPool release];
			return;
		}
	}
	
	[self performSelectorOnMainThread:@selector(showMessageNow:) withObject:message waitUntilDone:YES];
	[message release];
	[pendingMessages release];
	
	
	[aPool release];
}

- (void)showMessageNow:(NSMutableDictionary *)message
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *pendingMessages = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:gcPendingServerMessages]];
	NSMutableArray *sentMessages = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:gcShownServerMessages]];
	
	NSMutableDictionary *foundMessage = nil;
	for (NSMutableDictionary *newMessage in pendingMessages) {
		if ([[message objectForKey:@"id"] intValue] == [[newMessage objectForKey:@"id"] intValue]) {
			foundMessage = newMessage;
			break;
		}
	}
	if (foundMessage) {
		[pendingMessages removeObject:foundMessage];
		[sentMessages addObject:foundMessage];
		
		[defaults setObject:pendingMessages forKey:gcPendingServerMessages];
		[defaults setObject:sentMessages forKey:gcShownServerMessages];
		[defaults synchronize];
	} else {
		NSLog(@"message not found? %@", message);
		[pendingMessages release];
		[sentMessages release];
		return;
	}
	
	[pendingMessages release];
	[sentMessages release];
	
	
	NSString *text = [message objectForKey:@"text"];
	//itunes.com
	NSDictionary *button = [message objectForKey:@"button"];
	NSString *buttonText = nil;
	if (button) {
		buttonText = [button objectForKey:@"button_text"];
		if ([button objectForKey:@"url"] && buttonText) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message From GayCities.com" message:text delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:buttonText, nil];
			alert.tag = [[message objectForKey:@"id"] intValue];
			[alert show];
			[alert release];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message From GayCities.com" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message From GayCities.com" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}

	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSMutableArray *sentMessages = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:gcShownServerMessages]];
		BOOL found = NO;
		for (NSMutableDictionary *newMessage in sentMessages) {
			if ([[newMessage objectForKey:@"id"] intValue] == alertView.tag) {
				found = YES;
				NSDictionary *button = [newMessage objectForKey:@"button"];
				if (button) {
					NSString *buttonURL = [button objectForKey:@"url"];
					if (buttonURL) {
						NSURL *URL = [NSURL URLWithString:buttonURL];
						NSLog(@"scheme: %@",[URL scheme]);
						NSLog(@"host: %@",[URL host]);
						//[[UIApplication sharedApplication] openURL: ];
						if ([[URL scheme] isEqualToString:@"mailto"]) {
							[[UIApplication sharedApplication] openURL:URL];
						} else if ([[URL scheme] isEqualToString:@"http"]) {
							if ([[URL host] isEqualToString:@"itunes.apple.com"]) {
								[[UIApplication sharedApplication] openURL:URL];
							} else if ([[URL host] isEqualToString:@"itunes.com"]) {
								[[UIApplication sharedApplication] openURL:URL];
							} else if ([[URL host] isEqualToString:@"www.itunes.com"]) {
								[[UIApplication sharedApplication] openURL:URL];
							} else if ([[URL host] isEqualToString:@"maps.google.com"]) {
								[[UIApplication sharedApplication] openURL:URL];
							} else {
								OCWebViewController	*webViewController = [[OCWebViewController alloc] init];
								[webViewController setURL:URL andName:@"Browser"];
								[navigationController pushViewController:webViewController animated:YES];
								[webViewController release];
							}
						} else {
							[[UIApplication sharedApplication] openURL:URL];
						}
					}
				}
				
				break;
			}
		}
		if (!found) {
			NSLog(@"message not found to send after alert? %i", alertView.tag);
		}
		[sentMessages release];
	}
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"**App memory warning");

}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
  
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [[connectController communicator] cancelAllPendingRequests];
  [[connectController communicator] cancelCheckinListingRequests];
  
  [[ASIHTTPRequest sharedQueue] cancelAllOperations];
  
  if (self.adViewController.modalViewController) [self.adViewController dismissModalViewControllerAnimated:NO];
  
  if (!self.connectController.findFriendsDelegate) {
    if (self.navigationController.topViewController.modalViewController) [self.navigationController.topViewController dismissModalViewControllerAnimated:NO];
    else if (self.navigationController.modalViewController) [self.navigationController dismissModalViewControllerAnimated:NO];
  }

  if ([_interstitialTimer isValid]) {
    [_interstitialTimer invalidate];
    _interstitialTimer = nil;
  }  
}


- (void)upgradeDatabaseFor25
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"gc.db"];
	NSString *recentPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"recents.plist"]];
	NSString *bookmarkPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"bookmarks.plist"]];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	
	
	if ([db executeUpdate:@"alter table details add column former_names text"]) {
//		NSLog(@"former_names added");
		
	} else {
//		NSLog(@"former_names Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"alter table details add column enhanced_listing text"]) {
//		NSLog(@"enhanced_listing added");
		
	} else {
//		NSLog(@"enhanced_listing Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"alter table details add column last_verified text"]) {
//		NSLog(@"last_verified added");
		
	} else {
//		NSLog(@"last_verified Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"alter table details add column desc_mgmt text"]) {
//		NSLog(@"desc_mgmt added");
		
	} else {
//		NSLog(@"desc_mgmt Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"alter table details add column username text"]) {
//		NSLog(@"username added");
		
	} else {
//		NSLog(@"username Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"CREATE INDEX IF NOT EXISTS detailIndex ON details(listing_id,type)"]) {
//		NSLog(@"detailIndex Created");
		[defaults setBool:YES forKey:gc25DetailIndexCreated];
	} else {
//		NSLog(@"detailIndex Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"CREATE INDEX IF NOT EXISTS reviewIndex ON allReviews(listing_id,type)"]) {
//		NSLog(@"reviewIndex Created");
		[defaults setBool:YES forKey:gc25ReviewIndexCreated];
		
	} else {
//		NSLog(@"reviewIndex Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"CREATE TABLE IF NOT EXISTS tblBookmarks (listing_id text,type text,isDeleted boolean NOT NULL DEFAULT false,orderNum text)"]) {
//		NSLog(@"tblBookmarks Created");
		
	} else {
//		NSLog(@"tblBookmarks Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"CREATE TABLE IF NOT EXISTS tblRecents (listing_id text,type text,isDeleted boolean NOT NULL DEFAULT false,orderNum text)"]) {
//		NSLog(@"tblRecents Created");
		
	} else {
//		NSLog(@"tblRecents Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"CREATE INDEX IF NOT EXISTS bookmarkIndex ON tblBookmarks(listing_id,type)"]) {
//		NSLog(@"bookmarkIndex Created");
	} else {
//		NSLog(@"bookmarkIndex Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"CREATE INDEX IF NOT EXISTS recentIndex ON tblRecents(listing_id,type)"]) {
//		NSLog(@"recentIndex Created");
		
	} else {
//		NSLog(@"recentIndex Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"CREATE INDEX IF NOT EXISTS bookmarkOrderIndex ON tblBookmarks(orderNum)"]) {
//		NSLog(@"bookmarkOrderIndex Created");
	} else {
//		NSLog(@"bookmarkOrderIndex Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"CREATE INDEX IF NOT EXISTS recentOrderIndex ON tblRecents(orderNum)"]) {
//		NSLog(@"recentOrderIndex Created");
		
	} else {
//		NSLog(@"recentOrderIndex Failed: %@", [db lastErrorMessage]);
	}
	
	NSArray *recents = [[NSMutableArray alloc] initWithContentsOfFile: recentPath];
	NSArray *bookmarks = [[NSMutableArray alloc] initWithContentsOfFile: bookmarkPath];
	[recentPath release];
	[bookmarkPath release];

	int count = 0;
	for (NSString *listingID in recents) {
		OCFMResultSet *rs = [db executeQuery:@"select type from details where listing_id = ?", listingID];
		[rs next];
		
		NSString *type = [rs stringForColumn:@"type"];
		
		[rs close];
		
		 if ([db executeUpdate:@"insert into tblRecents (listing_id, type, orderNum) values (?, ?, ?)", listingID, type, [NSNumber numberWithInt: count]]) {
//			 NSLog(@"tblRecents updated");
			 
		 } else {
//			 NSLog(@"tblRecents update Failed: %@", [db lastErrorMessage]);
		 }
		count ++;
	}
	
	count = 0;
	for (NSString *listingID in bookmarks) {
		OCFMResultSet *rs = [db executeQuery:@"select type from details where listing_id = ?", listingID];
		[rs next];
		
		NSString *type = [rs stringForColumn:@"type"];
		
		[rs close];
		
		if ([db executeUpdate:@"insert into tblBookmarks (listing_id, type, orderNum) values (?, ?, ?)", listingID, type, [NSNumber numberWithInt: count]]) {
//			NSLog(@"tblBookmarks updated");
			
		} else {
//			NSLog(@"tblBookmarks update Failed: %@", [db lastErrorMessage]);
		}
		count ++;
	}
	
	[db close];
	
	[self performSelectorOnMainThread:@selector(hideProcessing) withObject:nil waitUntilDone:NO];
	[recents release];
	[bookmarks release];
	[aPool release];
	

}

/*
- (void)upgradeDatabaseFor32
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"listings.sqlite"];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSLog(@"updating db for 3.2");
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	
	
	if ([db executeUpdate:@"alter table events add column hours text"]) {
		NSLog(@"events hours added");
		
	} else {
		NSLog(@"events hours Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"alter table events add column photo_url text"]) {
		NSLog(@"events photo_url added");
		
	} else {
		NSLog(@"events photo_url Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"alter table events add column num_attending text"]) {
		NSLog(@"events num_attending added");
		
	} else {
		NSLog(@"events num_attending Failed: %@", [db lastErrorMessage]);
	}
	
		
	[db close];
	
	[defaults setBool:YES forKey:gc32DatabaseUpdateComplete];
	[defaults synchronize];
	
	[self performSelectorOnMainThread:@selector(hideProcessing) withObject:nil waitUntilDone:NO];
	[aPool release];
}*/

#pragma mark - Ads General

- (void)hideAdsForNow
{
	adBackgroundView.hidden = YES;
	shouldShowAdView = NO;
}

- (void)showAdsAgain
{
	adBackgroundView.hidden = NO;
	shouldShowAdView = YES;
}
- (void)hideAdsAndTabBarForNow
{
	adBackgroundView.hidden = YES;
	shouldShowAdView = NO;
	mainTabBar.hidden = YES;
  
}

- (void)showAdsAndTabbarAgain
{
	adBackgroundView.hidden = NO;
	shouldShowAdView = YES;
	mainTabBar.hidden = NO;
  
}

- (void)startAds
{
	/*
	 rollerView = [ARRollerView requestRollerViewWithDelegate:self];
	 [rollerView retain];
	 rollerView.frame = CGRectMake(0, 0, 320, 49); // set the frame, in this case at the bottom of the screen
	 [adBackgroundView addSubview:rollerView];
	 */
	
	/*if ([adBackgroundView isHidden] == YES) {
		adBackgroundView.hidden = NO;
		if (viewHeight != 318) {
			//[window bringSubviewToFront:adBackgroundView];
			viewHeight = 318;
			navigationController.topViewController.view.frame = CGRectMake(0, 0, 320, viewHeight);
		}
	} */
  
  
//	[Mobclix start];
//	mobClixAd = [[MMABannerXLAdView alloc] init];
//	mobClixAd.frame = CGRectMake(10, 0, 300, 50);
//	mobClixAd.delegate = self;
//	mobClixAd.refreshTime = 60;
//	[adBackgroundView addSubview:mobClixAd];
//	mobClixAd.viewController = adViewController;
//	adMobAd = nil;
	if (_adView) {
		if (_adView.superview) [_adView removeFromSuperview];
		_adView.delegate = nil;
		[_adView release];
	}
  
  _adView = [[MPAdView alloc] initWithAdUnitId:kMPAdUnitKey 
                                                   size:MOPUB_BANNER_SIZE];
  _adView.delegate = self;
  
  CGRect frame = _adView.frame;
//  CGSize size = [adView adContentViewSize];
  frame.origin.y = 0;
  _adView.frame = frame;
  
  [adBackgroundView addSubview:_adView];
	
	_adView.location = [[GCCommunicator sharedCommunicator] currentLocation];
	
	[_adView loadAd];
}

#pragma mark - MoPub

- (UIViewController *)viewControllerForPresentingModalView {
	NSLog(@"Ad View Controller: %@", self.adViewController);
  return self.adViewController;
}

/*
 * These callbacks notify you regarding whether the ad view (un)successfully
 * loaded an ad.
 */
- (void)adViewDidFailToLoadAd:(MPAdView *)view {
	view.location = [[GCCommunicator sharedCommunicator] currentLocation];

  [window sendSubviewToBack:adBackgroundView];
	//
	
	viewHeight = CGRectGetHeight(window.bounds) - 113.f;
	if (navigationController.topViewController.view.frame.size.height != viewHeight) {
		navigationController.topViewController.view.frame = CGRectMake(0, 0, 320, viewHeight);
	}
}

- (void)adViewDidLoadAd:(MPAdView *)view {
	
	view.location = [[GCCommunicator sharedCommunicator] currentLocation];

    	viewHeight = CGRectGetHeight(window.bounds) - 162.f;

	if (shouldShowAdView) {
		if (navigationController.topViewController.view.frame.size.height != viewHeight) {
			navigationController.topViewController.view.frame = CGRectMake(0, 0, 320, viewHeight);
		}
	}
	
	if (![[window.subviews lastObject] isEqual:self.adViewController.view] && !self.showingModalAd) {
		[window bringSubviewToFront:self.adBackgroundView];
	}
}

/*
 * These callbacks are triggered when the ad view is about to present/dismiss a
 * modal view. If your application may be disrupted by these actions, you can
 * use these notifications to handle them (for example, a game might need to
 * pause/unpause).
 */
- (void)willPresentModalViewForAd:(MPAdView *)view {
	view.location = [[GCCommunicator sharedCommunicator] currentLocation];

  self.showingModalAd = YES;
  [window bringSubviewToFront:self.adViewController.view];
}

- (void)didDismissModalViewForAd:(MPAdView *)view {
  self.showingModalAd = NO;
  [window performSelector:@selector(sendSubviewToBack:) withObject:self.adViewController.view afterDelay:0.5];
}


/*
 
 Interstatial
 
 */



- (void)interstitialTimerFired:(NSTimer *)timer {
  if (!interstitialShownThisSession && self.interstitialAdController.ready && !self.adViewController.modalViewController && !self.navigationController.topViewController.modalViewController && !self.showingModalAd) {
	  interstitialShownThisSession = YES;
    NSLog(@"AppDelegate - Interstatcial Timer fired - displaying now");
    [_interstitialTimer invalidate];
    _interstitialTimer = nil;
    [self.interstitialAdController show];
  } else {
	  if (!interstitialShownThisSession) {
		  _interstitialTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(interstitialTimerFired:) userInfo:nil repeats:NO];
	  }
    NSLog(@"AppDelegate - Interstatcial Timer fired, but adViewController not ready to present");
  }
}

#pragma mark Mobclix

#if 0

- (void) adViewDidFinishLoad:(MobclixAdView*) adView
{
	if (adMobAd) {
		if (adMobAd.superview) {
			
			[adMobAd removeFromSuperview];
		}
	} else {
	}
    
    viewHeight = CGRectGetHeight(window.bounds) - 162.f;
	if (shouldShowAdView) {
		if (navigationController.topViewController.view.frame.size.height != viewHeight) {
			navigationController.topViewController.view.frame = CGRectMake(0, 0, 320, viewHeight);
		}
	}
	
	
	[window bringSubviewToFront:adBackgroundView];
	if (mobClixAd.hidden == YES) {
		mobClixAd.hidden = NO;
	}
}


- (void) adView: (MobclixAdView*) adView didFailLoadWithError: (NSError*) error
{
	
	//[window bringSubviewToFront:navigationController.topViewController.view];
	//[window bringSubviewToFront:mainTabBar];
	[window sendSubviewToBack:adBackgroundView];
	//
	
	viewHeight = CGRectGetHeight(window.bounds) - 113.f;
	if (navigationController.topViewController.view.frame.size.height != viewHeight) {
		navigationController.topViewController.view.frame = CGRectMake(0, 0, 320, viewHeight);
	}

	
	if (adMobAd) {
		if (adMobAd.superview) {
			[adMobAd removeFromSuperview];
		} else {
			//self.adMobAd = nil;
		}
	}
	
	adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
	[adMobAd retain];
	mobClixAd.hidden = YES;
}

- (void)adView:(MobclixAdView*)adView didTouchCustomAdWithString:(NSString*)string
{
//	NSLog(@"mobclix clicked");
}


- (void)adViewWillTouchThrough:(MobclixAdView*)adView
{
//	NSLog(@"mobclix will click");
	[window bringSubviewToFront: adViewController.view];

}

- (void)adViewDidFinishTouchThrough:(MobclixAdView*)adView
{
//	NSLog(@"mobclix finish showing ad after click");
	[window sendSubviewToBack: adViewController.view];
}

#endif



#if 0
#pragma mark -
#pragma mark AdMobDelegate methods

- (NSString *)publisherIdForAd:(AdMobView *)adView
{
	return @"a14a342296c272e"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView
{
//	NSLog(@"AdMob requesting view controller");
	return navigationController;
}

- (UIColor *)adBackgroundColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)primaryTextColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)secondaryTextColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

//Older methods, just in case....

- (UIColor *)adBackgroundColor {
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)primaryTextColor {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)secondaryTextColor {
	return [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1]; // this should be prefilled; if not, provide a UIColor
}



- (void)didReceiveAd:(AdMobView *)adView {
	//NSLog(@"AdMob: Did receive ad");
	
    viewHeight = CGRectGetHeight(window.bounds) - 162.f;
	if (shouldShowAdView) {
		if (navigationController.topViewController.view.frame.size.height != viewHeight) {
			navigationController.topViewController.view.frame = CGRectMake(0, 0, 320, viewHeight);
		}
	}
	
	[window bringSubviewToFront:adBackgroundView];
	adMobAd.frame = CGRectMake(0, 0, 320, 49);
//	NSLog(@"Admob addsubview - Recieved Ad");
	[adBackgroundView addSubview:adMobAd];

}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
	//NSLog(@"AdMob: Did fail to receive ad");
	
	//[window bringSubviewToFront:navigationController.topViewController.view];
	//[window bringSubviewToFront:mainTabBar];
	[window sendSubviewToBack:adBackgroundView];

	//
	
	viewHeight = CGRectGetHeight(window.bounds) - 113.f;
	if (navigationController.topViewController.view.frame.size.height != viewHeight) {
		navigationController.topViewController.view.frame = CGRectMake(0, 0, 320, viewHeight);
	}
	
	if (adMobAd) {
		//NSLog(@"Admob fail release");
		[adMobAd release];
		adMobAd = nil;
	} else {
		//NSLog(@"Admob fail No release");
	}
}

#endif


#pragma mark FlurryAPI

- (void)setNewLocationForFlurry:(CLLocation *)newLoc
{
	[self performSelectorOnMainThread:@selector(setNewLocationForFlurryMainThread:) withObject:newLoc waitUntilDone:YES];
}

- (void)setNewLocationForFlurryMainThread:(CLLocation *)newLoc
{
	[Flurry setLatitude:newLoc.coordinate.latitude longitude:newLoc.coordinate.longitude horizontalAccuracy:newLoc.horizontalAccuracy verticalAccuracy:newLoc.verticalAccuracy];
}

- (void)logEventForFlurry:(NSString *)event withParameters:(NSDictionary *)parameters
{
	if (!event) {
		NSLog(@"Flurry No Event");
		return;
	} else if ([event length] == 0) {
		NSLog(@"Flurry No Event Length");
		return;
	} else if (parameters) {
		if ([parameters count] > 0) {
			NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:event, @"event", parameters, @"parameters", nil];
			[self performSelectorOnMainThread:@selector(logEventWithParametersMainThread:) withObject:dict waitUntilDone:YES];
			[dict release];
		} else {
			NSLog(@"Flurry Parameters, but lebgth == 0");
			[self performSelectorOnMainThread:@selector(logEventMainThread:) withObject:event waitUntilDone:YES];
		}
		
	} else {
		[self performSelectorOnMainThread:@selector(logEventMainThread:) withObject:event waitUntilDone:YES];
	}
	
}

- (void)logEventMainThread:(NSString *)event
{
	[Flurry logEvent:event];
//	NSLog(@"Flurry Event: %@", event);
}

- (void)logEventWithParametersMainThread:(NSDictionary *)eventDict
{
	[Flurry logEvent:[eventDict objectForKey:@"event"] withParameters:[eventDict objectForKey:@"parameters"]];
//	NSLog(@"Flurry Event: %@\nFlurry Parameters: %@", [eventDict objectForKey:@"event"], [eventDict objectForKey:@"parameters"]);
}

#pragma mark Processing view

-(void)showProcessing:(NSString *)text
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	[window bringSubviewToFront:processingView];
	processingLabel.text = text;
	processingView.hidden = NO;
	[processingActivity startAnimating];
	[aPool release];
}


-(void)hideProcessing
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	processingLabel.text = @"";
	processingView.hidden = YES;
	[processingActivity stopAnimating];
	[aPool release];
}


- (void)dealloc {
	self.navigationController = nil;
	self.window = nil;
	self.processingView = nil;
	self.processingActivity = nil;
	self.processingLabel = nil;
	self.adBackgroundView = nil;
	//[session.delegates removeObject:self];
	//[session release];
	self.connectController = nil;
	self.adViewController = nil;
	[nearbyItem release];
	[browseItem release];
	[myListItem release];
	[peopleItem release];
	[checkinItem release];
	[eventItem release];
  [_interstitialAdController release];
	[_adView release];

	[super dealloc];
}



@end



/*db = [FMDatabase databaseWithPath:[bundlePath stringByAppendingPathComponent:@"gc.db"]];
 if (![db open]) {
 NSLog(@"Could not open db.");
 return;
 }
 [db executeUpdate:@"create table if not exists metros (metro_country text, metro_id text, metro_name text, metro_state text, metro_lat text, metro_lng text)"];
 [db executeUpdate:@"create table if not exists listings (stars blob, listing_id text, type text, name  text, rating text, one_liner text, hood text default none, street text, city text, state text, lat text, lng text, tags text)"];
 [db executeUpdate:@"create table if not exists allReviews (r_rating text, r_id integer, r_date text, r_title text, r_text text, username text, u_age text, u_gender text, u_num_reviews text, u_photo text, listing_id text, type text)"];
 [db executeUpdate:@"create table if not exists browseListings (stars blob, listing_id text, type text, name  text, rating text, one_liner text, hood text, street text, city text, state text, lat text, lng text, tags text)"];
 [db executeUpdate:@"create table if not exists details (listing_id text, type text, name  text, overall_rating text, one_liner text, num_reviews text, num_fans text, photo_url text, website text, phone text, hood text, street text, city text, state text, lat text, lng text, desc_editorial text, cross_street text, hours text, tags text)"];
 [db executeUpdate:@"create table if not exists browseListingsArchive (stars blob, listing_id text, type text, name  text, rating text, one_liner text, hood text, street text, city text, state text, lat text, lng text, tags text)"];
 
 [db close];*/

