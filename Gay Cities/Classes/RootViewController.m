//
//  RootViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 11/21/08.
//  Copyright Obsessive Code 2008. All rights reserved.
//

#import "RootViewController.h"
#import "GayCitiesAppDelegate.h"
#import "GCMetrosController.h"
#import "GCDetailViewController.h"
#import "OCDetailView.h"
#import "GCBrowseViewController.h"
#import "OCConstants.h"
#import "GCListing.h"
#import "GCMyListViewController.h"
#import "GCBrowseViewCell.h"
#import "GCPeopleViewController.h"
#import "GCMainCheckinViewController.h"
#import "GCGeneralTextCell.h"
#import "GCUILabelExtras.h"
#import "GCEventsViewController.h"
#import "RMProjection.h"

@implementation RootViewController 

@synthesize previousMarker;
@synthesize mapView;
@synthesize myMarker;
@synthesize listingTypeTable;
@synthesize communicator;
@synthesize mapFilterLabel;
//@synthesize checkinNowButton;

#pragma mark View Methods and Loading

- (void)updateNearbyButtonWithAnimation:(BOOL)flag {
  if (flag) {
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activity.frame = CGRectMake(12, 5, 20, 20);
		activity.userInteractionEnabled = NO;
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0, 0, 44, 30);
		[button setImage:[UIImage imageNamed:@"nearbyTargetUpdateBG.png"] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(findMe) forControlEvents:UIControlEventTouchUpInside];
		button.showsTouchWhenHighlighted = YES;
		[button addSubview:activity];
		UIBarButtonItem *locateButton = [[UIBarButtonItem alloc] initWithCustomView:button];
		self.navigationItem.leftBarButtonItem = locateButton;
		[activity startAnimating];
		[activity release];
		[locateButton release];
  } else {
    UIBarButtonItem *locateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"tab_icon_target_White.png"]]
                                                                     style:UIBarButtonItemStylePlain 
                                                                    target:self 
                                                                    action:@selector(findMe)];
		
		self.navigationItem.leftBarButtonItem = locateButton;
		[locateButton release];
  }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	filterDisplayed = NO;
	stillStarting = YES;
	zoomDone = NO;
	bundlePath = [[NSString alloc] initWithString:[[NSBundle mainBundle] bundlePath]];	

	self.communicator = [GCCommunicator sharedCommunicator];
	communicator.delegate = self;
	//communicator.listingDelegate = self;
	currentMetroID = communicator.currentMetroID;
	[NSThread detachNewThreadSelector:@selector(loadCheckinListingsFromDatabaseKnowingCurrentMetroID:) toTarget:communicator.listings withObject:[NSString stringWithFormat:@"%i",currentMetroID]];

	
	tabBarSelected = [[[GayCitiesAppDelegate sharedAppDelegate] mainTabBar] selectedItem].tag;  //Which tab bar item was selected
	myMarker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-me.png"] anchorPoint:CGPointMake(0.5,0.5)];
	[myMarker setListingID:-1];
	
	[self setTitle:@"Nearby"];
	mcivc = [[GCMainCheckinViewController alloc] init];
	//checkinNowButton.hidden = YES;
	
	
}


 - (void)viewWillAppear:(BOOL)animated {
	 [super viewWillAppear:animated];
	 

	 if (tabBarSelected == 10 && !mapView) {
		 currentMetroID = communicator.currentMetroID;
		 
		 [self createMapView];
		 
	 } else if (tabBarSelected == 10 && !stillStarting) {
		 communicator.delegate = self;
		 //communicator.listingDelegate = self;
		 if (communicator.isUpdatingLocation) {
			 
		 }
		 if (currentMetroID != communicator.currentMetroID) {
			 [mapFilterLabel removeFromSuperview];
			 currentMetroID = communicator.currentMetroID;
			 if ([communicator distanceFromLocationMetroCenter]) {
				 mapView.contents.zoom = 11;
			 } else {
				 mapView.contents.zoom = 13;
			 }
			 

			 [self dropPins];

			 if (communicator.currentLocation) {
				 [self centerMap:communicator.currentLocation.coordinate];
			 } else {
				 [self centerMapWithoutPoint:communicator.savedLocationCoordinate];
			 }
			 [self zoomMap];
		 } else {
			 if (previousMarker) {
				 if ([mapView.markerManager managingMarker:previousMarker]) {
					 [previousMarker showLabel];
				 } else {
					 [previousMarker hideLabel];
					 self.previousMarker = nil;
				 }
				 
			 }
		 }
	 }
	
	 
	 
 }



- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];	
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];


	if (stillStarting) {
		[self startupRoutine];
		stillStarting = NO;
		[gcad startAds];
	} else if (!zoomDone && mapView) {
		[self zoomMap];
	}
	if (self.view.frame.size.height != gcad.viewHeight) {
		self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	}

}



-(void)startupRoutine
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults integerForKey:firstLaunch] == 0) {
		if ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]) {
			[defaults setObject:@"1" forKey:@"gcStartupKey"];
			[defaults synchronize];
		}
	}
	
	if ([[defaults stringForKey:@"gcStartupKey"] intValue] == gcStartupKeyCurrentLocation) {
		if (communicator.noInternet) {  
			if ([communicator.listings numberOfListings] == 0) {
				UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Connect" message:@"Since there appears to be no network connection and no data has been saved to the database, the application must exit.  \nPlease try again when connected to a Wi-Fi or cellular data network." delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
				noInternetAlert.tag = 10;
				[noInternetAlert show];
				[noInternetAlert release];
				return;
			}
			else {
				UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Connect" message:@"The application is set to find your current location, but there appears to be no network connection. Your last viewed city will be used instead.\nWithout an internet connection, many of the features of GayCities will not work properly.\nConnect to a Wi-Fi or cellular data network to access the full features." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[noInternetAlert show];
				[noInternetAlert release];
			}
		}
		else {
			if ([communicator.listings numberOfListings] == 0) {
				GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
				[gcad showProcessing:@"Downloading data for new city..."];
			}
			[communicator findMe:GCLocationSearchGlobal];
			if ([defaults integerForKey:firstLaunch] == 0) {
				[communicator.ul askLoginFirstLaunch];
				[defaults setInteger:1 forKey:firstLaunch];
			}
		}
	}
	else if ([[defaults stringForKey:@"gcStartupKey"] intValue] == gcStartupKeyLastLocation) {

		if (communicator.noInternet && [communicator.listings numberOfListings] == 0) {
			UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Connect" message:@"Since there appears to be no network connection and no data has been saved to the database, the application must exit.  \nPlease try again when connected to a Wi-Fi or cellular data network." delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
			noInternetAlert.tag = 10;
			[noInternetAlert show];
			[noInternetAlert release];
			return;
		}
		else if ([communicator.listings numberOfListings] == 0) {
			
			[self changeCity: @"The application is set to load the last viewed city, but no city is saved.\nPlease choose which city to load:"];

		}
		else if (communicator.noInternet) {
			UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Connect" message:@"Without an internet connection, many of the features of GayCities will not work properly.\nConnect to a Wi-Fi or cellular data network to access the full features." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[noInternetAlert show];
			[noInternetAlert release];
			//currentLocation = [[CLLocation alloc] initWithLatitude:[[NSString stringWithContentsOfFile:latitudeSaved encoding:NSASCIIStringEncoding error:nil] doubleValue] longitude:[[NSString stringWithContentsOfFile:longitudeSaved encoding:NSASCIIStringEncoding error:nil] doubleValue]];

		}
		else {
			[communicator updateListingsForLastLocation];
			if ([defaults integerForKey:firstLaunch] == 0) {
				[communicator.ul askLoginFirstLaunch];
				[defaults setInteger:1 forKey:firstLaunch];
			}
		}	
	}
	[self selectTabBar];
	
	

}



- (void)viewWillDisappear:(BOOL)animated {
	if (mapView) {
		communicator.savedLocationCoordinate = mapView.contents.mapCenter;
	}
	if (tabBarSelected != 10) {
		if (previousMarker) {
			[previousMarker hideLabel];
			self.previousMarker = nil;
		}
	} else {
		if (previousMarker) {
			[previousMarker hideLabel];
		}
	}
	[super viewWillDisappear:animated];

	 
}

- (void)dealloc {
	//NSLog(@"Deallocing RootViewController");
	[bundlePath release];
	self.mapView = nil;
	self.myMarker = nil;
	self.listingTypeTable = nil;
	self.communicator = nil;
	self.mapFilterLabel = nil;
	//self.checkinNowButton = nil;
	[mcivc release];
	[super dealloc];
}




#pragma mark CityPicker Delegates

- (void)changeCityButtonAction
{

	[self closeMoreActions];
	[communicator.locationMgr stopUpdatingLocation];
	if (communicator.noInternet) {
		UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:@"Since there appears to be no network connection, the current city cannot be changed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noInternetAlert show];
		[noInternetAlert release];
		return;
	}
	//NSLog(@"Change City");
	GCCityChangeViewController *cvc = [[GCCityChangeViewController alloc] init];
	cvc.viewType = optionalSelectionViewType;
	cvc.instructionText = @"";
	cvc.delegate = self;
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	
	
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	gcad.mainTabBar.hidden = YES;
  
  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:cvc];
  [cvc release];
  
	[self.navigationController presentModalViewController:nc animated:YES];
	[nc release];
}


- (void)changeCity:(NSString *)instructionText
{
	if (communicator.noInternet) {
		UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:@"Since there appears to be no network connection, the current city cannot be changed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noInternetAlert show];
		[noInternetAlert release];
		return;
	}
	//NSLog(@"Change City");
	GCCityChangeViewController *cvc = [[GCCityChangeViewController alloc] init];
	cvc.viewType = requiredSelectionViewType;
	cvc.instructionText = instructionText;
	cvc.delegate = self;
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	
	
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	gcad.mainTabBar.hidden = YES;
  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:cvc];
  [cvc release];
  
	[self.navigationController presentModalViewController:nc animated:YES];
	[nc release];
	
}

- (void)cityViewDidSelectMetro:(GCMetro *)newMetro;
{
	if (previousMarker) {
		[previousMarker hideLabel];
		self.previousMarker = nil;
	}
	[communicator locateCity:newMetro];
	NSLog(@"ROOTVIEW - CITYPICKER - metro ID: %i", newMetro.metro_id);
	
	[self dismissModalViewControllerAnimated:YES];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	gcad.mainTabBar.hidden = NO;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults integerForKey:firstLaunch] == 0) {
		[communicator.ul askLoginFirstLaunch];
		[defaults setInteger:1 forKey:firstLaunch];
	}
	
	
}

- (void)cityViewDidCancel
{
	[self dismissModalViewControllerAnimated:YES];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.adBackgroundView.hidden = NO;
	gcad.mainTabBar.hidden = NO;
	gcad.shouldShowAdView = YES;

	
	//NSLog(@"cancel");
}

- (void)cityViewDidSelectNearby
{
	if (previousMarker) {
		[previousMarker hideLabel];
		self.previousMarker = nil;
	}
	[communicator findMe:GCLocationSearchGlobal];
	[self dismissModalViewControllerAnimated:YES];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.adBackgroundView.hidden = NO;
	gcad.mainTabBar.hidden = NO;
	gcad.shouldShowAdView = YES;

	
	//NSLog(@"nearby");
	
}


#pragma mark Communicator Delegates

- (void)didUpdateListings
{
	//NSLog(@"listings updates from communicator");
	if ([[self.navigationController topViewController] isKindOfClass:[RootViewController class]] && tabBarSelected == 10) {

		
		[self dropPins];
		if (currentMetroID != communicator.currentMetroID) {
			if ([communicator distanceFromLocationMetroCenter]) {
				mapView.contents.zoom = 11;
			} else {
				mapView.contents.zoom = 13;
			}

			currentMetroID = communicator.currentMetroID;
			if (communicator.currentLocation) {
				[self centerMap:communicator.currentLocation.coordinate];				
			} else {
				[self centerMapWithoutPoint:communicator.savedLocationCoordinate];
			}
			[self zoomMap];
		} else {
			if (communicator.currentLocation) {
				[self centerMap:communicator.currentLocation.coordinate];				
			}
		}
		
		
	}
	[mapFilterLabel removeFromSuperview];

	[listingTypeTable reloadData];
}

- (void)didUpdateMetros
{
	
}

- (void)didUpdateEvents
{
	
}

- (void)didUpdateLocation
{
	
	if ([[self.navigationController topViewController] isKindOfClass:[RootViewController class]] && tabBarSelected == 10) {
		[self centerMap:communicator.currentLocation.coordinate];

		//currentMetroID = communicator.currentMetroID;

	}
}

- (void)didFinishLocationUpdates
{
	if ([[self.navigationController topViewController] isKindOfClass:[RootViewController class]] && tabBarSelected == 10) {
		
		[self centerMap:communicator.currentLocation.coordinate];	
		[self updateNearbyButtonWithAnimation:NO];
		
			
	}
		
	
}

- (void)didCancelLocationUpdates
{
	if ([[self.navigationController topViewController] isKindOfClass:[RootViewController class]] && tabBarSelected == 10) {
		
		//[self centerMap:communicator.currentLocation.coordinate];
		[self updateNearbyButtonWithAnimation:NO];
	}
}

- (void)didChangeCurrentMetro
{
	
	[mapFilterLabel removeFromSuperview];
	zoomDone = NO;
	if ([[self.navigationController topViewController] isKindOfClass:[RootViewController class]] && tabBarSelected == 10) {
		NSLog(@"ROOTVIEW - centering map, metro changed");

		[self centerMapWithoutPoint:communicator.savedLocationCoordinate];
		//currentMetroID = communicator.currentMetroID;

	}
}

- (void)noInternetErrorLocation
{
	
}

- (void)noInternetErrorListings
{
	
}

- (void)didFailLoadListings
{
	
}

- (void)locationError
{
	
}

- (void)noInternetErrorListing
{
	
}

/*
- (void)didUpdateListing:(GCListing *)listing
{
	GCDetailViewController *dvc = [[GCDetailViewController alloc] init];
	dvc.communicator = communicator;
	dvc.listing = listing;
	[self.navigationController pushViewController:dvc animated:YES];
	[dvc release];
	
}*/


#pragma mark Map View Delegates
- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map
{
	if (previousMarker) {
		[previousMarker setZPosition:0.1];
	}
	
	//NSLog(@"MARKER TAPPED!");
	if (marker == myMarker){
		if (previousMarker) {
			[previousMarker hideLabel];
			//checkinNowButton.hidden = YES;
			self.previousMarker = nil;
		} 
		return;
	}
	[marker setZPosition: 1.0];
	

	float x = [mapView.markerManager screenCoordinatesForMarker:marker].x;
	//NSLog(@"marker x: %f", x);
	[(OCDetailView *)marker.label setAnchorX:x];
	
	[marker toggleLabel];
	
	/*if (communicator.previousLocation && marker && (GCListing *)[marker listing] && communicator.currentMetroID == communicator.myNearbyMetroID && communicator.myNearbyMetroID != -1) {
		CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[[(GCListing *)[marker listing] lat] doubleValue] longitude:[[(GCListing *)[marker listing] lng] doubleValue]];
		double dist = [communicator.previousLocation distanceFromLocation:placeLocation];
		
		if (placeLocation.coordinate.latitude == 0 && placeLocation.coordinate.longitude == 0) {
			checkinNowButton.hidden = marker.label.isHidden;
			
		} else if (dist <= kDefaultCheckinDistance) {
			checkinNowButton.hidden = marker.label.isHidden;
		} else {
			checkinNowButton.hidden = YES;
		}
		[placeLocation release];
		
	} else {
		checkinNowButton.hidden = YES;
	}
	 */
	
	if ([(OCDetailView *)marker.label isHidden]) {
		[marker setZPosition:0.1];
	}
	if (previousMarker) {
		[previousMarker hideLabel];
	}
	if (previousMarker == marker) {
		self.previousMarker = nil;
	}
	else {
		self.previousMarker = marker;
	}
	
	
}


- (void) tapOnLabelForMarker:(RMMarker*) marker onMap:(RMMapView*) map
{
	/*
	
	NSString *type = [NSString stringWithString:[communicator.listings typeForListingID:marker.listingID]];
	//NSLog(@"Rootviewcontroller listing ID for Details: %i", listingID);
	GCDetailViewController *detailViewController = [[GCDetailViewController alloc] init];
	[detailViewController setDetailsFor:marker.listingID andType:type];
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
	 */
	
	//[communicator loadDetailsForListing:(GCListing *)marker.listing];
	GCDetailViewController *dvc = [[GCDetailViewController alloc] init];
	//dvc.communicator = communicator;
	dvc.listing = (GCListing *)marker.listing;
	[self.navigationController pushViewController:dvc animated:YES];
	[dvc release];

}

- (void) singleTapOnMap: (RMMapView*) map At: (CGPoint) point
{
	//NSLog(@"map single tap");
	if (previousMarker) {
		[previousMarker hideLabel];
		//checkinNowButton.hidden = YES;
		[previousMarker setZPosition:0.1];

	}
	if (myMarker) {
		[myMarker setZPosition:.9];
	}
	self.previousMarker = nil;
}



- (IBAction)checkinPressedForlisting
{
//	if (previousMarker) {
//		if ([[[previousMarker listing] listing_id] length] > 0 && [[[previousMarker listing] type] length] > 0) {
//			NSLog(@"Checkin now for: %@ %@", [[previousMarker listing] listing_id], [[previousMarker listing] type]);
//			
//		}
//	}
}

/*
- (void) doubleTapOnMap: (RMMapView*) map At: (CGPoint) point;
{
	NSLog(@"Zoom In: %f", mapView.contents.zoom);
	//[mapView.contents zoomInToNextNativeZoomAt:point animated:YES];
}*/


-(void)findMe { // for the map bar buton item
  [[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"MAP-Target_AND_Find_Me button tapped" withParameters:nil];
	if (communicator.isUpdatingLocation) {
    [self updateNearbyButtonWithAnimation:NO];
    if (communicator.currentLocation) [self centerMap:communicator.currentLocation.coordinate];
		[self performSelector:@selector(findMe:) withObject:[NSNumber numberWithInt:GCLocationSearchNone] afterDelay:0.5];  // this will cancel and current update in progress
  } else if (communicator.currentLocation) {
		[self centerMap:communicator.currentLocation.coordinate];
		[self performSelector:@selector(findMe:) withObject:[NSNumber numberWithInt:GCLocationSearchGlobal] afterDelay:0.5];
	} else {
    [self updateNearbyButtonWithAnimation:YES];
		[self performSelector:@selector(findMe:) withObject:[NSNumber numberWithInt:GCLocationSearchGlobal] afterDelay:0.5];
	}
}

- (void)findMe:(NSNumber *)searchTypeNumber{
  int searchType = [searchTypeNumber intValue];
	[communicator findMe:searchType];
}

-(void) centerMap:(CLLocationCoordinate2D)loc{
	RMMapContents *contents = mapView.contents;
	RMMarkerManager *manager = contents.markerManager;

	
	//lat: 40.754038
	//long: -73.997671
	if (!myMarker) {
		myMarker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-me.png"] anchorPoint:CGPointMake(0.5,0.5)];
		[myMarker setListingID:-1];
//		[manager addMarker:myMarker AtLatLong:loc];
    [manager addMarker:myMarker atProjectedPoint:[[self.mapView.contents projection] latLongToPoint:loc]];
	} else {
		if (![manager managingMarker:myMarker]) {
//			[manager addMarker:myMarker AtLatLong:loc];
      [manager addMarker:myMarker atProjectedPoint:[[self.mapView.contents projection] latLongToPoint:loc]];
		}
		else {
			[manager moveMarker:myMarker AtLatLon:loc];
		}

	}
	if (![manager isMarkerWithinScreenBounds:myMarker] || contents.zoom < 13) {
		[contents moveToLatLong:loc];
	}
	
	[myMarker setZPosition:.9];
	

	
}

-(void)dropCurrentLocationPin:(CLLocationCoordinate2D)loc
{
	RMMarkerManager *manager = mapView.markerManager;

	if (!myMarker) {
		myMarker =[[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-me.png"] anchorPoint:CGPointMake(0.5,0.5)];
		[myMarker setListingID:-1];
//		[manager addMarker:myMarker AtLatLong:loc];
    [manager addMarker:myMarker atProjectedPoint:[[self.mapView.contents projection] latLongToPoint:loc]];
	} else {
		if (![manager managingMarker:myMarker]) {
//			[manager addMarker:myMarker AtLatLong:loc];
      [manager addMarker:myMarker atProjectedPoint:[[self.mapView.contents projection] latLongToPoint:loc]];
		}
		else {
			[manager moveMarker:myMarker AtLatLon:loc];
		}
		
	}
	[myMarker setZPosition:1];
}

-(void) centerMapWithoutPoint:(CLLocationCoordinate2D)loc
{
	[mapView.contents moveToLatLong:loc];
}



-(void) dropAndZoom
{
	[self dropPins];
	[self zoomMap];
}


-(void) dropPins
{
	zoomDone = NO;
	if (!mapView || ([communicator.listings numberOfListings] == 0) ) {
		return;
	}
	//checkinNowButton.hidden = YES;
	
	RMMarkerManager *manager = mapView.markerManager;
	if (previousMarker) {
		[previousMarker hideLabel];
		self.previousMarker = nil;
	}
	

	@synchronized(self) { 
		[manager removeMarkers];
	}
	
	for (GCListing *listing in communicator.listings.listings) {
		if (listing.listingType.isEnabled) {
			RMMarker *currentPlace =[[RMMarker alloc] initWithUIImage:listing.listingType.pinImage];
			
			CGPoint position = CGPointMake([currentPlace bounds].size.width / 2, 0);
			OCDetailView *detail = [[OCDetailView alloc] initWithText:[listing.name filteredStringRemovingHTMLEntities] andAnchorPoint:position andCaption:[listing.one_liner filteredStringRemovingHTMLEntities]];
			[currentPlace setLabel:detail];
			[currentPlace hideLabel];
			//detail.listing = listing;
			[detail release];
			
			//[currentPlace setListingID:[listing.listing_id intValue]];
			currentPlace.listing = listing;
			/*if (previousMarker) {
				if (previousMarker.listing == currentPlace.listing) {
					previousMarker = currentPlace;
					[previousMarker showLabel];
				}
			}*/
			CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[listing.lat floatValue] 
																   longitude:[listing.lng floatValue]];
//			[manager addMarker:currentPlace AtLatLong:[placeLocation coordinate]];
      [manager addMarker:currentPlace atProjectedPoint:[[self.mapView.contents projection] latLongToPoint:[placeLocation coordinate]]];
			
			[placeLocation release];
			if ([listing.listingType.name isEqualToString:@"bars"]) {
				[currentPlace setZPosition:0.2];
			} else {
				[currentPlace setZPosition:0.0];
			}
			[currentPlace release];
		}
		
	}
	

}

-(void)zoomMap
{
	if (!mapView) {
		return;
	}
	if (tabBarSelected != 10) {
		NSLog(@"Map isnt shown, no zoom in");

		return;
	}
	int count = [[mapView.contents.markerManager markersWithinScreenBounds] count];
	if (count <= 15) {
		NSLog(@"Less than 15 listings, no zoom in");
		mapView.contents.zoom = 11;
		return;
	}
	
	
	[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(performZoom:) userInfo:nil repeats:NO];
	zoomDone = YES;
}


- (void)performZoom:(NSTimer *)timer
{
	RMMapContents *contents = mapView.contents;
	if (contents.zoom >= 15.3) {
		return;
	}	
	//NSLog(@"zoom min: %f, max: %f", contents.minZoom, contents.maxZoom);
	//[contents zoomByFactor:1.3 near:centerPoint animated:YES];
	int count = [[contents.markerManager markersWithinScreenBounds] count];
	if (count > 50) {
		CGPoint centerPoint = [contents latLongToPixel: contents.mapCenter];
		[contents zoomByFactor:1.75 near:centerPoint animated:YES withCallback:self];
	} else if (count > 30) {
		CGPoint centerPoint = [contents latLongToPixel: contents.mapCenter];
		[contents zoomByFactor:1.6 near:centerPoint animated:YES withCallback:self];
	} else if (count > 15) {
		CGPoint centerPoint = [contents latLongToPixel: contents.mapCenter];
		[contents zoomByFactor:1.4 near:centerPoint animated:YES withCallback:self];
	} else {
		CGPoint centerPoint = [contents latLongToPixel: contents.mapCenter];
		[contents zoomByFactor:.8 near:centerPoint animated:YES];
	}
	zoomDone = YES;
}

- (void)animationFinishedWithZoomFactor:(float)zoomFactor near:(CGPoint)p;
{
	RMMapContents *contents = mapView.contents;
	if (contents.zoom >= 15.3) {
		return;
	}
	
	//NSLog(@"zoom min: %f, max: %f", contents.minZoom, contents.maxZoom);
	//[contents zoomByFactor:1.3 near:centerPoint animated:YES];
	
	if ([[contents.markerManager markersWithinScreenBounds] count] > 15) {
		CGPoint centerPoint = [contents latLongToPixel: contents.mapCenter];
		[contents zoomByFactor:1.4 near:centerPoint animated:YES withCallback:self];
	} 

}


-(void)createMapView
{
	//NSLog(@"View will appear - allocing mapView");
	mapView = [[RMMapView alloc] initWithFrame:self.view.frame];
	mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[mapView setDelegate:self];
	self.view = mapView;
	[mapView release];

	[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(mapCreateDone:) userInfo:nil repeats:NO];
}

- (void)mapCreateDone:(NSTimer *)timer
{
	[self dropPins];

	if (communicator.currentLocation) {
		[self centerMap:communicator.currentLocation.coordinate];
	} else {
		[mapView moveToLatLong:communicator.savedLocationCoordinate];
	}
	[self zoomMap];
}




#pragma mark TabBar Delegate Methods

-(void)selectTabBar
{
	[self tabBar:nil didSelectItem:nil];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (item) {
		tabBarSelected = [item tag];
		//NSLog(@"TabBarSelected:%i", tabBarSelected);
		[defaults setObject:[[NSNumber numberWithInt: tabBarSelected] stringValue] forKey:@"selectedTab"];
	}
	
	//[self.navigationController setNavigationBarHidden:NO];


	
	if (tabBarSelected ==10)
	{
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"MAIN_TAB-MAP-Tapped" withParameters:nil];
		[self.navigationController popToRootViewControllerAnimated:NO];
		communicator.delegate = self;

		//NSLog(@"nearby");
		[self setTitle:@"Nearby"];
		if (!mapView) {
			[self createMapView];
		}
		if (!filterDisplayed) {
			UIBarButtonItem *moreActionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(showMoreActions)];
			
			self.navigationItem.rightBarButtonItem = moreActionsButton;
			[moreActionsButton release];
		} else {
			UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"  Done  " style:UIBarButtonItemStyleDone target:self action:@selector(closeMoreActions)];
			//UIBarButtonItem *changeCityButton = [[UIBarButtonItem alloc] initWithTitle:@"Pick City" style:UIBarButtonItemStylePlain target:self action:@selector(changeCityButtonAction)];
			
			self.navigationItem.rightBarButtonItem = doneButton;
			[doneButton release];
		}
		
		if (communicator.isUpdatingLocation) {
			[self updateNearbyButtonWithAnimation:YES];
		} else {
			[self updateNearbyButtonWithAnimation:NO];
		}
	}
	else if (tabBarSelected == 20)
	{
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"MAIN_TAB-BROWSE-Tapped" withParameters:nil];
		//NSLog(@"browse");
		if ([[self.navigationController topViewController] isKindOfClass:[GCBrowseViewController class]]) {
			GCBrowseViewController *bvc = (GCBrowseViewController *)[self.navigationController topViewController];
			[bvc.browseTableView reloadData];
		} else {
			[self.navigationController popToRootViewControllerAnimated:NO];
			GCBrowseViewController *bvc = [[GCBrowseViewController alloc] init];
			//bvc.communicator = communicator;
			[self.navigationController pushViewController:bvc animated:NO];

			[bvc release];

		}
		
		
		
		
	}
	else if (tabBarSelected == 30)
	{
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"MAIN_TAB-MY_LIST-Tapped" withParameters:nil];
		//NSLog(@"my list");
		[communicator.listings loadBookmarks];
		
		communicator.delegate = self;

		if ([[self.navigationController topViewController] isKindOfClass:[GCMyListViewController class]]) {
			GCMyListViewController *mlvc = (GCMyListViewController *)[self.navigationController topViewController];
			
			[mlvc.mainTableView reloadData];
			//NSLog(@"mlvc already ontop, reseting data");
		} else {
			[self.navigationController popToRootViewControllerAnimated:NO];
			
			GCMyListViewController *mlvc = [[GCMyListViewController alloc] init];
			//mlvc.communicator = communicator;
			[self.navigationController pushViewController:mlvc animated:NO];
			
			[mlvc release];
			//NSLog(@"mlvc pushed");
			
		}

	} else if (tabBarSelected == 40)
	{
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"MAIN_TAB-PEOPLE_UPDATES-Tapped" withParameters:nil];
		communicator.delegate = self;
		//NSLog(@"people");
		if ([[self.navigationController topViewController] isKindOfClass:[GCPeopleViewController class]]) {
			//GCPeopleViewController *pvc = (GCPeopleViewController *)[self.navigationController topViewController];
			
			//[pvc.mainTableView reloadData];
			//NSLog(@"mlvc already ontop, reseting data");
		} else {
			[self.navigationController popToRootViewControllerAnimated:NO];
			
			GCPeopleViewController *pvc = [[GCPeopleViewController alloc] init];
			//pvc.communicator = communicator;
			[self.navigationController pushViewController:pvc animated:NO];
			
			[pvc release];
			//NSLog(@"mlvc pushed");
			
		}

	} else if (tabBarSelected == 50) {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"MAIN_TAB-CHECKIN-Tapped" withParameters:nil];
		communicator.delegate = self;
		if ([[self.navigationController topViewController] isKindOfClass:[GCMainCheckinViewController class]]) {
			//GCMainCheckinViewController *vc = (GCMainCheckinViewController *)[self.navigationController topViewController];
			[mcivc.mainTable reloadData];
		} else {
			
			mcivc.showingProfilePage = NO;

			[self.navigationController setViewControllers:[NSArray arrayWithObjects:self, mcivc, nil]];
			//[mcivc release];
			
		}
	} else if (tabBarSelected == 60) {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"MAIN_TAB-EVENTS-Tapped" withParameters:nil];
		if (![[self.navigationController topViewController] isKindOfClass:[GCEventsViewController class]]) {
			
				[self.navigationController popToRootViewControllerAnimated:NO];

				GCEventsViewController *evc = [[GCEventsViewController alloc] init];
        communicator.delegate = evc;

				[self.navigationController pushViewController:evc animated:NO];
				[evc release];
	
		}
		
	}

	

}



#pragma mark Table View Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {


	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if (section == 0) {
		return 1;
	} else if (section == 1) {
		if (communicator.listings) {
			return [communicator.listings numberOfTypes];
		}
	}
	
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = [indexPath section];
	if (section == 0) {
		return 30;
	} else if (section == 1) {
		return 44;
	}
	return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		if (communicator.listings) {
			UILabel *label = [UILabel gcLabelForTableHeaderView];
			
			label.text = @"Tap on a row to show or hide that type on the map\n\nTap the image to select only that type";
			label.font = [UIFont systemFontOfSize:13];
			return label;
			
		}
	} else if (section == 1) {
		return nil;
	}
	return nil;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return 70;
	} else if (section == 1) {
		return 10;
	}
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath section];
    if (section == 0) {
		GCGeneralTextCell *cell  = (GCGeneralTextCell *)[tableView dequeueReusableCellWithIdentifier:@"generalTextCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCGeneralTextCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
			cell.cellLabel.font = [UIFont boldSystemFontOfSize:16];
			cell.cellLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.cellLabel.text = @"Select All";
		}
		return cell;
	} else if (section == 1) {
		int row = [indexPath row];
	
		GCBrowseViewCell *cell  = (GCBrowseViewCell *)[tableView dequeueReusableCellWithIdentifier:@"browseViewCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCBrowseViewCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.frame = CGRectMake(0, 0, 44, 44);
			button.showsTouchWhenHighlighted = YES;
			button.backgroundColor = [UIColor clearColor];
			[button addTarget:self action:@selector(selectThisFilterTypeRow:) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:button];
 		}
		
		if (communicator.listings) {
			cell.typeName.text = [[[[communicator.listings listingTypes]objectAtIndex:row] name] capitalizedString];
			cell.typeImage.image = [[[communicator.listings listingTypes]objectAtIndex:row] typeImage];
			cell.someIdentifierWord = [NSString stringWithFormat:@"%i", row];
			if ([[[communicator.listings listingTypes]objectAtIndex:row] isEnabled]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			
		}	
		
		
		
		return cell;
	}
	return nil;
}

- (void)selectThisFilterTypeRow:(id)sender
{
	
	if (communicator.listings) {
		GCBrowseViewCell *cell = (GCBrowseViewCell *)[(UIButton *)sender superview];
		
		int row = [cell.someIdentifierWord intValue];
		int count = 0;
		for (GCListingType *type in communicator.listings.listingTypes) {
			if (count == row) {
				type.isEnabled = YES;
			} else {
				type.isEnabled = NO;
			}
			count ++;
		}
		[listingTypeTable reloadData];
	}
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = [indexPath section];
	if (section == 0) {
		for (GCListingType *type in communicator.listings.listingTypes) {
			type.isEnabled = YES;
		}
		[tableView reloadData];
	} else if (section == 1) {
		if (communicator.listings) {
			int count = 0;
			for (GCListingType *type in communicator.listings.listingTypes) {
				if (type.isEnabled) {
					count ++;
				}
			}
			if (count <= 1 && [[[communicator.listings listingTypes]objectAtIndex:[indexPath row]] isEnabled]) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"One category required" message:@"At least one category must be on.  Please select another category before turning this one off" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
				
			} else {
				[[[communicator.listings listingTypes]objectAtIndex:[indexPath row]] setIsEnabled: ![[[communicator.listings listingTypes]objectAtIndex:[indexPath row]] isEnabled]];
				[tableView reloadData];
			}
			
		}
	}
	
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{

	return NO;
}


 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

	 return NO;

 }


 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {

	 return NO;
 }



#pragma mark Misc Methods

- (void)showMoreActions
{
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"MAP-Filter button tapped" withParameters:nil];

	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	if (previousMarker) {
		[previousMarker hideLabel];
	}
	[mapFilterLabel removeFromSuperview];

	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	gcad.mainTabBar.hidden = YES;
	self.view.frame = CGRectMake(0, 0, 320, 416);
	//[UIView beginAnimations:nil context:NULL];
	//[UIView setAnimationDuration:.6];
	//[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];;
	[self.view addSubview:listingTypeTable];
	
	//[UIView commitAnimations];
	
	
	[listingTypeTable reloadData];

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"  Done  " style:UIBarButtonItemStyleDone target:self action:@selector(closeMoreActions)];
	//UIBarButtonItem *changeCityButton = [[UIBarButtonItem alloc] initWithTitle:@"Pick City" style:UIBarButtonItemStylePlain target:self action:@selector(changeCityButtonAction)];
	
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	//[changeCityButton release];
	filterDisplayed = YES;

	
}

- (void)closeMoreActions
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	

	[listingTypeTable removeFromSuperview];
	gcad.adBackgroundView.hidden = NO;
	gcad.mainTabBar.hidden = NO;
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	
	
	[gcad showProcessing:@"Updating Map..."];
	
	

	UIBarButtonItem *moreActionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(showMoreActions)];
	
	self.navigationItem.rightBarButtonItem = moreActionsButton;
	[moreActionsButton release];
	[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateMapViewForFilter:) userInfo:nil repeats:NO];
	filterDisplayed = NO;;
}

- (void)updateMapViewForFilter:(NSTimer *)timer
{
	[self dropPins];
	
	if (communicator.currentLocation) {
		[self dropCurrentLocationPin:communicator.currentLocation.coordinate];				
	}
	int count = 0;
	for (GCListingType *type in communicator.listings.listingTypes) {
		if (type.isEnabled) {
			count ++;
		}
	}
	if (count == [communicator.listings.listingTypes count]) {
		[mapFilterLabel removeFromSuperview];
	} else {
		[self.view addSubview:mapFilterLabel];
		//mapFilterLabel.hidden = NO;
		//mapFilterLabel.frame = CGRectMake(0, 100, 320, 23);
	}
	[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 10) {
		if (buttonIndex == 0) {
			exit(0);
		} 
		else if (buttonIndex == 1) {
			[self changeCity:@"Choose a city:"];
		}
	}
	
	
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    // Release anything that's not essential, such as cached data
	NSLog(@"root view memory warning");
	
	
	//[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
}











@end

