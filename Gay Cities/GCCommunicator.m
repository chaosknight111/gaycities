//
//  GCCommunicator.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/30/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCCommunicator.h"
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
#import "GCEvent.h"
#import "DDXML.h"
#import "GayCitiesAppDelegate.h"
#import "GCListingReview.h"
#import "OCConstants.h"
#import "GCPerson.h"
#import "GCEventSummary.h"
#import "GCEvent.h"
#import "GCEventsController.h"

#define URL_REQUEST_TIMEOUT     25.0


static NSString *gcBaseURL = @"http://api.gaycities.com/v5/";

static GCCommunicator *_sharedCommunicator;

@implementation GCCommunicator

@synthesize metros, listings;
@synthesize savedLocationCoordinate;
@synthesize currentLocation, updatedLocation, previousLocation;
@synthesize locationMgr;
@synthesize timer;
@synthesize noInternet, isUpdatingLocation, messagesRecieved, metrosDownloaded;
@synthesize delegate, listingDelegate, eventDelegate, peopleDelegate, checkinAndPopularDelegate;
@synthesize currentMetroID, myNearbyMetroID, year, today;
@synthesize ul;
@synthesize nearbyUpdates, friendUpdates;
@synthesize connections, peopleImages, listingConnections, otherConnections, peopleUpdateConnections, checkinConnections;
@synthesize downloadQueue;
//@synthesize geoComm;
@synthesize lastLocationUpdateTime;
@synthesize currentlyUpdatingListings;
@synthesize foursquareController;
@synthesize foursquareListings;
@synthesize currentLocationSearch;


- (id)init {
	self = [super init];
  currentLocationSearch = GCLocationSearchNone;
	currentlyUpdatingListings = NO;
	metros = [[GCMetrosController alloc]init];
  foursquareController = [[GCFoursquareController alloc] init];
  foursquareController.delegate = self;
  self.foursquareListings = [NSArray array];
	metrosDownloaded = NO;
	messagesRecieved = NO;
	connections = [[NSMutableDictionary alloc] init];
	listingConnections = [[NSMutableDictionary alloc] init];
	otherConnections = [[NSMutableDictionary alloc] init];
  checkinConnections = [[NSMutableDictionary alloc] init];
  
	UIImage *image = [UIImage imageNamed:@"defaultProfile.png"];
	if (image) {
		peopleImages = [[NSMutableDictionary alloc] initWithObjectsAndKeys:image,@"http://www.gaycities.com/images/sm_profile.gif",
						image,@"http://www.gaycities.com/images/xsm_profile.gif",
						image,@"http://www.gaycities.com/images/mini_profile.gif",
						image,@"http://www.gaycities.com/images/med_profile.gif",
						image,@"http://www.gaycities.com/images/profile.gif",nil];
	} else {
		peopleImages = [[NSMutableDictionary alloc] init];
	}
	
	peopleUpdateConnections = [[NSMutableDictionary alloc] init];
	isUpdatingLocation = NO;
	locationMgr = [[CLLocationManager alloc] init];  //Initialize location manager
	locationMgr.distanceFilter = kCLDistanceFilterNone;
	locationMgr.delegate = self;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	myNearbyMetroID = [[defaults valueForKey:gcSavedHomeMetro] intValue];
	previousLocation = nil;
	

	if (self.currentMetroID != myNearbyMetroID && myNearbyMetroID != -1) {
		if ([[defaults stringForKey:@"gcStartupKey"] intValue] == gcStartupKeyCurrentLocation) {
			self.currentMetroID = myNearbyMetroID;
		}
		savedLocationCoordinate.latitude = [[metros.currentMetro metro_lat] doubleValue];
		savedLocationCoordinate.longitude = [[metros.currentMetro metro_lng] doubleValue];
		listings = [[GCListingsController alloc] initWithMetroID:myNearbyMetroID lat:0 lng:0];

	} else if (self.currentMetroID == myNearbyMetroID && myNearbyMetroID != -1){
		savedLocationCoordinate.latitude = [[defaults valueForKey:gcSavedLatitude] doubleValue];
		savedLocationCoordinate.longitude = [[defaults valueForKey:gcSavedLongitude] doubleValue];
		listings = [[GCListingsController alloc] initWithMetroID:myNearbyMetroID lat:savedLocationCoordinate.latitude lng:savedLocationCoordinate.longitude];
	} else {
		savedLocationCoordinate.latitude = [[defaults valueForKey:gcSavedLatitude] doubleValue];
		savedLocationCoordinate.longitude = [[defaults valueForKey:gcSavedLongitude] doubleValue];
		listings = [[GCListingsController alloc] initWithMetroID:self.currentMetroID lat:0 lng:0];
	}

	
	
	
	[self isThereNoInternet];
	ul = [[GCUserLogin alloc] init];
	ul.delegate = self;
	nearbyUpdates = [[NSMutableArray alloc] init];
	friendUpdates = [[NSMutableArray alloc] init];
	findBetterLocation = NO;
	findBetterLocation2 = NO;
	downloadQueue = [[NSOperationQueue alloc] init];
	
	//NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	//[nc addObserver:self selector:@selector(updateGeoApiListings) name:gcCheckinListingsLoadedNotification object:nil];
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  unsigned unitFlags = NSYearCalendarUnit | NSWeekdayCalendarUnit;
  NSDateComponents *comps = [calendar components:unitFlags fromDate: [NSDate date]];
  year = [comps year];
  today = [comps weekday];
  
	return self;
}


- (void)dealloc
{
	[_sharedCommunicator release];
  [foursquareController release];
  [foursquareListings release];
	delegate = nil;
	listingDelegate = nil;
	eventDelegate = nil;
	peopleDelegate = nil;
	self.connections = nil;
	self.peopleImages = nil;
	self.listingConnections = nil;
	self.otherConnections = nil;
	self.peopleUpdateConnections = nil;
	self.metros = nil;
	self.listings = nil;
	self.currentLocation = nil;
	self.updatedLocation = nil;
	self.previousLocation = nil;
	self.locationMgr = nil;
	self.ul = nil;
	self.nearbyUpdates = nil;
	self.friendUpdates = nil;
	self.downloadQueue = nil;
  [checkinConnections release];
	[super dealloc];
}

+ (GCCommunicator *)sharedCommunicator
{
	if (!_sharedCommunicator) {
		_sharedCommunicator = [[GCCommunicator alloc] init];
	}
	return _sharedCommunicator;
}

- (void)setCurrentMetroID:(int)aMetroId {
  self.metros.currentMetroID = aMetroId;
}

- (int)currentMetroID {
  return self.metros.currentMetroID;
}

#pragma mark Misc


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

-(NSString *)getSearchString
{
	
	srandom(time(NULL));
	int r = (random() % 1000000)+1;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddHH"];
	NSString *c = [NSString stringWithFormat:@"gciphonesecret%@%@%i",[dateFormatter stringFromDate:[[NSDate date] addTimeInterval:-([[NSTimeZone systemTimeZone] secondsFromGMT])]],[[UIDevice currentDevice] uniqueIdentifier],r];
	[dateFormatter release];
	
	
	return [NSString stringWithFormat:@"&r=%i&uid=%@&c=%@",r,[[UIDevice currentDevice] uniqueIdentifier], [[self md5Digest:c] substringWithRange:NSMakeRange(0, 7)]];
	
}

- (BOOL)isThereNoInternet {
	if ([[Reachability reachabilityWithHostName:@"www.gaycities.com"] currentReachabilityStatus] == NotReachable) {
		NSLog(@"No Internet");
		noInternet = YES;
		metrosDownloaded = YES;
	} else {
		noInternet = NO;
	}
	return noInternet;
}

- (float)distanceFromLocation:(double)lat lng:(double)lng
{	
	if (!currentLocation) {
		return 100;
	}
	if (lat == 0 && lng == 0) {
		return 0;
	}
	CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
	float distance;
	if ([location respondsToSelector:@selector(distanceFromLocation:)]) {
		distance = [location distanceFromLocation:currentLocation];
	} else {
		distance = [location distanceFromLocation:currentLocation];
	}
	distance = distance/1000;
	distance = distance * .6214;
	[location release];
//	NSLog(@"Distance From: %f", distance);
	return distance;
	
}

- (BOOL)distanceFromLocationMetroCenter
{	
	if (!currentLocation || !metros.currentMetro) {
		return NO;
	}
	
	CLLocation *location = [[CLLocation alloc] initWithLatitude:[metros.currentMetro.metro_lat floatValue] longitude:[metros.currentMetro.metro_lng floatValue]];
	float distance;
	if ([location respondsToSelector:@selector(distanceFromLocation:)]) {
		distance = [location distanceFromLocation:currentLocation];
	} else {
		distance = [location distanceFromLocation:currentLocation];
	}
	distance = distance/1000;
	distance = distance * .6214;
	[location release];
//	NSLog(@"Distance From Metro: %f", distance);
	if (distance > 10) {
		return YES;
	}
	return NO;
	
}

- (NSMutableData *)sendRequestWithAPI:(NSString *)api andParameters:(NSString *)parameters
{
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@",gcBaseURL, api];
	NSURL *url = [NSURL URLWithString:urlString];

	NSMutableString *searchString = [[NSMutableString alloc] initWithString:[self getSearchString]];
	
	[searchString appendString:parameters];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:URL_REQUEST_TIMEOUT];
	[req setHTTPMethod:@"POST"];
	
	NSLog(@"API:%@", api);
	[urlString release];
	
	[req setHTTPBody:[searchString dataUsingEncoding:NSUTF8StringEncoding]];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	[searchString release];
	
	NSMutableData *recievedData = [[[NSMutableData alloc] init] autorelease];
	
	NSLog(@"submitting synchronous request");
	[recievedData appendData:[NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil]];
	
	return recievedData;
}

- (void)sendAsyncRequestWithAPI:(NSString *)api parameters:(NSString *)parameters type:(GCRequestType)type
{
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@", gcBaseURL, api];
	NSURL *URL = [NSURL URLWithString:urlString];
	NSLog(@"Async Request: %@ - %@", urlString, parameters);
	[urlString release];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL 
														   cachePolicy:NSURLRequestReloadIgnoringCacheData 
													   timeoutInterval:20];
	NSMutableString *searchString = [[NSMutableString alloc] initWithString:[self getSearchString]];
	[searchString appendString:parameters];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[searchString dataUsingEncoding:NSUTF8StringEncoding]];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

	[searchString release];
	GCURLConnection *connection = [[GCURLConnection alloc] initWithRequest:request delegate:self requestType:type];
	if (!connection) {
		return;
	}
	//NSLog(@"Connection Identifier: %@", connection.identifier);
	if (type == GCRequestTypeMetros) {
		[connections setObject:connection forKey:connection.identifier];
	} else if (type == GCRequestTypeListingsAndEvents) {
		[listingConnections setObject:connection forKey:connection.identifier];
	} else if (type == GCRequestTypeCheckinListings) {
		[checkinConnections setObject:connection forKey:connection.identifier];
	} else if (type == GCRequestTypePeopleUpdates ) {
		[peopleUpdateConnections setObject:connection forKey:connection.identifier];
	} else {
		[otherConnections setObject:connection forKey:connection.identifier];
	}
	[connection release];
}

- (void)cancelAllPendingRequests
{
	NSLog(@"Cancelling all requests");
	[self cancelOtherRequests];
	[self cancelListingRequests];

}

- (void)cancelListingRequests
{
	NSLog(@"Cancelling listings requests");
  
	[[listingConnections allValues] makeObjectsPerformSelector:@selector(cancel)];
	[listingConnections removeAllObjects];
  currentlyUpdatingListings = NO;
	[self cancelPeopleUpdateRequests];
}

- (void)cancelCheckinListingRequests {
  NSLog(@"Cancelling checkin listings requests");
	[[checkinConnections allValues] makeObjectsPerformSelector:@selector(cancel)];
	[checkinConnections removeAllObjects];
}

- (void)cancelPeopleUpdateRequests
{
	NSLog(@"Cancelling people requests");
	[[peopleUpdateConnections allValues] makeObjectsPerformSelector:@selector(cancel)];
	[peopleUpdateConnections removeAllObjects];
	//[nearbyUpdates removeAllObjects];
}

- (void)cancelOtherRequests
{
	NSLog(@"Cancelling other requests");
	[[otherConnections allValues] makeObjectsPerformSelector:@selector(cancel)];
	[otherConnections removeAllObjects];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
	[self performSelectorOnMainThread:@selector(showAlertWithTitleAndMessageMain:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", message, @"message", nil] waitUntilDone:YES];
}

- (void)showAlertWithTitleAndMessageMain:(NSDictionary *)strings
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[strings objectForKey:@"title"] message:[strings objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
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

- (void)showNoInternetAlertGeneric
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"There appears to be no internet connection.  Please try again when connected to a WiFi or celualar data network." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

#pragma mark Location Methods

- (void)findMe:(GCLocationSearchType)searchType {
  currentLocationSearch = searchType;
	if (timer && [timer isValid]) [timer invalidate];
  timer = nil;
  
	if (currentLocationSearch == GCLocationSearchNone || isUpdatingLocation) {  //if asked to find location while finding, it means cancel
		[self hideProcessing];
		findBetterLocation = NO;
		findBetterLocation2 = NO;
		isUpdatingLocation = NO;
		//[locationMgr stopUpdatingLocation];  //new
    return;
	}
  
  if ([self isThereNoInternet]) {
    UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Find Location" message:@"Your current location could not be obtained because it appears you have no internet connection.  \nYour last known location will be used instead." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [noInternetAlert show];
    [noInternetAlert release];
    
    if ([delegate respondsToSelector:@selector(noInternetErrorLocation)]) {
      [delegate noInternetErrorLocation];
    } else {
      NSLog(@"Delegate does not respond to noInternetErrorLocation");
    }
    currentlyUpdatingListings = NO;
    return;
  }
  
  isUpdatingLocation = YES;
  NSLog(@"Updating current location");
  
  findBetterLocation = YES;
  findBetterLocation2 = NO;
  
  if (!currentLocation && myNearbyMetroID == -1) {  //if myNearbyMetroId == -1, it usually means this is your first time loading the app, so we definitly need to get the current location
    [self cancelListingRequests];
    [self showProcessing:@"Finding Your Location..."];
    currentlyUpdatingListings = YES;

  } else if (self.currentLocationSearch == GCLocationSearchGlobal) {
    BOOL savedDataExists = [listings loadNewMetroID:myNearbyMetroID];
    if (savedDataExists && myNearbyMetroID != -1) {
      self.currentMetroID = myNearbyMetroID;
      currentlyUpdatingListings = NO;
      [self updateListingsForCurrentMetro];
      NSLog(@"Find Me: global: Using saved home Metro ID");
      
      if (previousLocation) {  // the previous location is always set along with the current location, but the current location can be nilled out at times to force a location search, so we use the previous location here.
        savedLocationCoordinate.latitude = previousLocation.coordinate.latitude;
        savedLocationCoordinate.longitude = previousLocation.coordinate.longitude;
      } else {
        savedLocationCoordinate.latitude = [[metros.currentMetro metro_lat] doubleValue];
        savedLocationCoordinate.longitude = [[metros.currentMetro metro_lng] doubleValue];
      }
      
      double lat = savedLocationCoordinate.latitude;
      double lng = savedLocationCoordinate.longitude;
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      [defaults setValue:[NSNumber numberWithFloat: lat] forKey:gcSavedLatitude];
      [defaults setValue:[NSNumber numberWithFloat: lng] forKey:gcSavedLongitude];
      
      
      if ([delegate respondsToSelector:@selector(didUpdateListings)]) {
        [delegate performSelectorOnMainThread:@selector(didUpdateListings) withObject:nil waitUntilDone:YES];
      } else {
        NSLog(@"Delegate does not respond to didUpdateListings");
      }
    } else {
      [self cancelListingRequests];
      [self showProcessing:@"Finding Your Location..."];
      currentlyUpdatingListings = YES;
    }
  } else if (self.currentLocationSearch == GCLocationSearchCheckins) {
    NSLog(@"Find Me: checkins only");
  }
    
  [locationMgr startUpdatingLocation];		
}


- (void)refreshCheckinsAndLocation {
  [self updateFoursquareListings];
  if (!isUpdatingLocation) [self findMe:GCLocationSearchCheckins];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[self hideProcessing];
	NSLog(@"\nlocationError");
	[locationMgr stopUpdatingLocation];
	findBetterLocation = NO;
	findBetterLocation2 = NO;
	isUpdatingLocation = NO;
	if (currentLocation) {
		self.currentLocation = nil;
	}
  
	if (timer && [timer isValid]) [timer invalidate];
  timer = nil;
	
	if (checkinAndPopularDelegate && currentLocationSearch == GCLocationSearchCheckins) {
		if ([checkinAndPopularDelegate respondsToSelector:@selector(errorRecievingCheckInUpdates)]) {
			[checkinAndPopularDelegate errorRecievingCheckInUpdates];
		} else {
			NSLog(@"checkinAndPopularDelegate does not respond to didUpdateListings");
		}
		return;
	}
  
  if ([delegate respondsToSelector:@selector(locationError)]) {
    [delegate locationError];
  }
  
  BOOL reportNoListings = NO;
  if (currentLocationSearch == GCLocationSearchGlobal) {
    if (previousLocation) [self locateListingsForMetroID:0 orLocation:previousLocation.coordinate];
    else if (myNearbyMetroID != -1) [self locateListingsForMetroID:self.myNearbyMetroID orLocation:previousLocation.coordinate]; // If the metro ID is provided, the location coordinate is ignored.  Its only provided here cause the compiler complains if we pass nil..
    else if (self.currentMetroID > 0) [self locateListingsForMetroID:self.currentMetroID orLocation:previousLocation.coordinate];
    else reportNoListings = YES;

  } else if (currentLocationSearch == GCLocationSearchCheckins) {
    [self.listings updateCheckinListingsForNewLocation:previousLocation];
    return;
  }
  
  
  
  
	if ([listings numberOfListings] == 0 && reportNoListings) {
		UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Find Location" message:@"Your current location could not be obtained.  \nPlease choose a city in the following screen." delegate:delegate cancelButtonTitle:@"Quit" otherButtonTitles:@"Choose City", nil];
		noInternetAlert.tag = 10;
		[noInternetAlert show];
		[noInternetAlert release];
	} else if (reportNoListings) {  // this is legacy and we should really never get here.
		UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Find Location" message:@"Your current location could not be obtained.  \nYour last known location will be used instead." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noInternetAlert show];
		[noInternetAlert release];
    if (previousLocation) [self locateListingsForMetroID:0 orLocation:previousLocation.coordinate];
	} else {
    NSLog(@"**Location error - uncaught case**");
  }
   
}

- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation{
	//[timer invalidate];
	NSDate *newLocationeventDate = newLocation.timestamp;
	NSTimeInterval howRecentNewLocation = [newLocationeventDate timeIntervalSinceNow];

	// Needed to filter cached and too old locations
	if ((!updatedLocation || oldLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) && (howRecentNewLocation < -0.0 && howRecentNewLocation > -10.0)) {
		self.updatedLocation = newLocation;

		if (!currentLocation) {
			NSLog(@"Creating Current Location");
			//[self hideProcessing];
			
			self.currentLocation = newLocation;
			self.previousLocation = newLocation;
      [self performSelectorOnMainThread:@selector(cancelListingRequests) withObject:nil waitUntilDone:YES];
			if (currentLocationSearch == GCLocationSearchGlobal) [self locateListingsForMetroID:0 orLocation:newLocation.coordinate];
      else if (currentLocationSearch == GCLocationSearchCheckins) {
        NSLog(@"No previous location, update checkins with new data now and set a new nearbyMetroId");
        [self locateCheckinListingsForLocation:self.currentLocation.coordinate];
        [self updateFoursquareListings];
      }
			[listings updateCheckinListingsForNewLocation:newLocation];
			self.savedLocationCoordinate = currentLocation.coordinate;
			float lat = savedLocationCoordinate.latitude, lng = savedLocationCoordinate.longitude;
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			
			[defaults setValue:[NSNumber numberWithFloat: lat] forKey:gcSavedLatitude];
			[defaults setValue:[NSNumber numberWithFloat: lng] forKey:gcSavedLongitude];
			
			
			if ([delegate respondsToSelector:@selector(didUpdateLocation)]) {
        NSLog(@"Communicator Location Updated - Reporting to %@", [delegate class]);
				[delegate didUpdateLocation];
			} else {
				NSLog(@"Delegate does not respond to didUpdateLocation");
			}
			if (timer) {
				if ([timer isValid]) {
					[timer invalidate];
				}
				timer = nil;
			}
			timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopLocationUpdates:) userInfo:nil repeats:NO];
		} else if ([self distanceFromLocation:updatedLocation.coordinate.latitude lng:updatedLocation.coordinate.longitude] > 15) {
			NSLog(@"Checking if this location is a new metro cause its more than 15 miles from our last location");
			self.currentLocation = newLocation;
			self.previousLocation = newLocation;
			self.savedLocationCoordinate = currentLocation.coordinate;
			float lat = savedLocationCoordinate.latitude, lng = savedLocationCoordinate.longitude;
			
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			
			[defaults setValue:[NSNumber numberWithFloat: lat] forKey:gcSavedLatitude];
			[defaults setValue:[NSNumber numberWithFloat: lng] forKey:gcSavedLongitude];
			
			if ([delegate respondsToSelector:@selector(didUpdateLocation)]) {
        NSLog(@"Communicator Location Updated, past 15 miles - Reporting to %@", [delegate class]);
				[delegate didUpdateLocation];
			} else {
				NSLog(@"Delegate does not respond to didUpdateLocation");
			}
			[self performSelectorOnMainThread:@selector(cancelListingRequests) withObject:nil waitUntilDone:YES];
			if (currentLocationSearch == GCLocationSearchGlobal) [self locateListingsForMetroID:0 orLocation:updatedLocation.coordinate];
      else if (currentLocationSearch == GCLocationSearchCheckins) {
        NSLog(@"No previous location, update checkins with new data now and set a new nearbyMetroId");
        [self locateCheckinListingsForLocation:self.currentLocation.coordinate];
        [self updateFoursquareListings];
      }
			[listings updateCheckinListingsForNewLocation:currentLocation];
      isUpdatingLocation = NO;
		} else if (findBetterLocation) {
//			NSLog(@"Find better location 1");
			if (timer) {
				if ([timer isValid]) {
					[timer invalidate];
				}
				timer = nil;
			}
			timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopLocationUpdates:) userInfo:nil repeats:NO];
			findBetterLocation = NO;
			findBetterLocation2 = YES;
			isUpdatingLocation = YES;
			self.currentLocation = newLocation;
			self.previousLocation = newLocation;
			self.savedLocationCoordinate = currentLocation.coordinate;
			float lat = savedLocationCoordinate.latitude, lng = savedLocationCoordinate.longitude;
			
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			
			[defaults setValue:[NSNumber numberWithFloat: lat] forKey:gcSavedLatitude];
			[defaults setValue:[NSNumber numberWithFloat: lng] forKey:gcSavedLongitude];
			[listings updateCheckinListingsForNewLocation:currentLocation];
      [self updateFoursquareListings];
			[[GayCitiesAppDelegate sharedAppDelegate] setNewLocationForFlurry:newLocation];
			if ([delegate respondsToSelector:@selector(didUpdateLocation)]) {
        NSLog(@"Communicator Location Updated findBetterLocation1 - Reporting to %@", [delegate class]);
				[delegate didUpdateLocation];
			} else {
				NSLog(@"Delegate does not respond to didUpdateLocation");
			}
		} else if (findBetterLocation2) {
//			NSLog(@"Find better location 2");
			[locationMgr stopUpdatingLocation];
			if (timer) {
				if ([timer isValid]) {
					[timer invalidate];
				}
				timer = nil;
			}
      findBetterLocation = NO;
			findBetterLocation2 = NO;
			isUpdatingLocation = NO;
			self.currentLocation = newLocation;
			self.previousLocation = newLocation;
			self.savedLocationCoordinate = currentLocation.coordinate;
			[[GayCitiesAppDelegate sharedAppDelegate] setNewLocationForFlurry:newLocation];
			float lat = savedLocationCoordinate.latitude, lng = savedLocationCoordinate.longitude;
			
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			
			[defaults setValue:[NSNumber numberWithFloat: lat] forKey:gcSavedLatitude];
			[defaults setValue:[NSNumber numberWithFloat: lng] forKey:gcSavedLongitude];
//			[listings updateCheckinListingsForNewLocation:currentLocation];
//			[self updateFoursquareListings];
      
			if ([delegate respondsToSelector:@selector(didFinishLocationUpdates)]) {
        NSLog(@"Communicator Location Update Finished - Reporting to %@", [delegate class]);
				[delegate didFinishLocationUpdates];
			} else {
				NSLog(@"Delegate does not respond to didFinishLocationUpdates");
			}
		}  else {
//			NSLog(@"Stopping Location Updates");
			[locationMgr stopUpdatingLocation];
			isUpdatingLocation = NO;
			findBetterLocation = NO;
			findBetterLocation2 = NO;
		}
	}
}

- (void)stopLocationUpdates:(NSTimer *)aTimer
{
	timer = nil;
	[self hideProcessing];
	findBetterLocation = NO;
	findBetterLocation2 = NO;
	isUpdatingLocation = NO;
//	NSLog(@"cancelled location updates (timer)");
	[locationMgr stopUpdatingLocation];
	if ([delegate respondsToSelector:@selector(didCancelLocationUpdates)]) {
		[delegate didCancelLocationUpdates];
	} else {
		NSLog(@"Delegate does not respond to didCancelLocationUpdates");
	}
	if (checkinAndPopularDelegate && self.currentMetroID == myNearbyMetroID) {
		if ([checkinAndPopularDelegate respondsToSelector:@selector(errorRecievingCheckInUpdates)]) {
			[checkinAndPopularDelegate errorRecievingCheckInUpdates];
		} else {
			NSLog(@"checkinAndPopularDelegate does not respond to didUpdateListings");
		}
		return;
	}
	
}

- (void)stopLocationUpdates
{
	if (timer) {
		if ([timer isValid]) {
			[timer invalidate];
		}
		timer = nil;
	}
	[self hideProcessing];
	findBetterLocation = NO;
	findBetterLocation2 = NO;
	isUpdatingLocation = NO;
//	NSLog(@"stopped location updates (direct)");
	[locationMgr stopUpdatingLocation];
	if ([delegate respondsToSelector:@selector(didCancelLocationUpdates)]) {
		[delegate didCancelLocationUpdates];
	} else {
		NSLog(@"Delegate does not respond to didCancelLocationUpdates");
	}
}

#pragma mark GC.com methods

#pragma mark Listings


- (void)updateListingsForLastLocation
{
  currentlyUpdatingListings = YES;
	[self isThereNoInternet];
  self.currentLocationSearch = GCLocationSearchNone;
	if (noInternet) {
		UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Connect" message:@"Without an internet connection, many of the features of GayCities will not work properly.\nConnect to a Wi-Fi or cellular data network to access the full features." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noInternetAlert show];
		[noInternetAlert release];
		if ([delegate respondsToSelector:@selector(noInternetErrorListings)]) {
			[delegate noInternetErrorListings];
		} else {
			NSLog(@"Delegate does not respond to noInternetErrorLocation");
		}
    currentlyUpdatingListings = NO;
		return;
	}
	[self locateListingsForMetroID:0 orLocation:savedLocationCoordinate];
}

-(void)locateCity:(GCMetro *)newMetro
{
	[locationMgr stopUpdatingLocation];
  currentlyUpdatingListings = YES;
	findBetterLocation = NO;
	findBetterLocation2 = NO;
	isUpdatingLocation = NO;
  self.currentLocationSearch = GCLocationSearchNone;
	[self showProcessing:@"Changing City"];
	[self cancelListingRequests];
	[NSThread detachNewThreadSelector:@selector(locateCityThread:) toTarget:self withObject:newMetro];
}

-(void)locateCityThread:(GCMetro *)newMetro
{
	NSAutoreleasePool *apool=[[NSAutoreleasePool alloc] init];

  currentlyUpdatingListings = YES;

	BOOL savedDataExists = [listings loadNewMetroID:[newMetro.metro_id intValue]];
	
	
	if (noInternet && savedDataExists) {
		[self hideProcessing];
		
    self.metros.currentMetro = newMetro;
		self.savedLocationCoordinate = metros.currentMetro.metroLocation;
		self.currentLocation = nil;
		self.updatedLocation = nil;
    currentlyUpdatingListings = NO;

		[self showAlertWithTitle:@"Can't Connect" message:@"Since it appears you have no internet connection, that city cannot be updated.  Saved information will be used instead.\nConnect to a Wi-Fi or cellular data network to access the full features."];
		if ([delegate respondsToSelector:@selector(didUpdateListings)]) {
			[delegate performSelectorOnMainThread:@selector(didUpdateListings) withObject:nil waitUntilDone:NO];
		} else {
			NSLog(@"Delegate does not respond to didUpdateListings");
		}
		[apool release];
		return;
	} else if (noInternet) {
    currentlyUpdatingListings = NO;
		[self hideProcessing];
		[self showAlertWithTitle:@"Can't Connect" message:@"Your city cannot be changed since it appears you have no internet connection.\nConnect to a Wi-Fi or cellular data network to access the full features."];
		if ([delegate respondsToSelector:@selector(noInternetErrorListings)]) {
			[delegate performSelectorOnMainThread:@selector(noInternetErrorListings) withObject:nil waitUntilDone:NO];
		} else {
			NSLog(@"Delegate does not respond to noInternetErrorListings");
		}
		 [apool release];
		return;
	} else if (savedDataExists) {
		[self hideProcessing];
		self.metros.currentMetro = newMetro;

		self.savedLocationCoordinate = metros.currentMetro.metroLocation;
		self.currentLocation = nil;
		self.updatedLocation = nil;
    currentlyUpdatingListings = NO;

		if ([delegate respondsToSelector:@selector(didUpdateListings)]) {
			[delegate performSelectorOnMainThread:@selector(didUpdateListings) withObject:nil waitUntilDone:NO];
		} else {
			NSLog(@"Delegate does not respond to didUpdateListings");
		}
		/*[nearbyUpdates performSelectorOnMainThread:@selector(removeAllObjects) withObject:nil waitUntilDone:YES];
		if ([peopleDelegate respondsToSelector:@selector(didRecievePeopleUpdates)]) {
			[peopleDelegate performSelectorOnMainThread:@selector(didRecievePeopleUpdates) withObject:nil waitUntilDone:NO];
		} else {
			//NSLog(@"peopleDelegate does not respond to didRecievePeopleUpdates");
		}*/  
		
		// When the city is changed, it waitsfor new data to replace peopl,e updates - is this good??
		
		// not sure...
		
		
	} else {
		[self showProcessing:@"Downloading new city..."];
		
    self.metros.currentMetro = newMetro;
		self.savedLocationCoordinate = metros.currentMetro.metroLocation;
		self.currentLocation = nil;
		self.updatedLocation = nil;
	}
	
	float lat = savedLocationCoordinate.latitude, lng = savedLocationCoordinate.longitude;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setValue:[NSNumber numberWithFloat: lat] forKey:gcSavedLatitude];
	[defaults setValue:[NSNumber numberWithFloat: lng] forKey:gcSavedLongitude];
	
	[self performSelectorOnMainThread:@selector(updateListingsForCurrentMetro) withObject:nil waitUntilDone:NO];
	[apool release];
}

- (void)updateListingsForCurrentMetro
{

  [self locateListingsForMetroID:self.currentMetroID orLocation:metros.currentMetro.metroLocation];


}


-(void)locateListingsForMetroID:(int)metro_id orLocation:(CLLocationCoordinate2D)myLocation

{
	//[nearbyUpdates performSelectorOnMainThread:@selector(removeAllObjects) withObject:nil waitUntilDone:NO];
	NSMutableString *searchString = [[NSMutableString alloc] initWithString:@"&results=json&full=1&apis=listings|events"];
	
	if (metro_id>0){
		[searchString appendFormat:@"&metro_id=%i",metro_id];
	}
	else if (metro_id==0){
		[searchString appendFormat:@"&metro_id=0&lat=%f&lng=%f",myLocation.latitude, myLocation.longitude ];
//		NSLog(@"lat=%f , long=%f",myLocation.latitude, myLocation.longitude);
	}
	
	[self sendAsyncRequestWithAPI:@"jsonapiloader" parameters:searchString type:GCRequestTypeListingsAndEvents];
	[searchString release];
}

- (void)processListingData:(NSData *)recievedData
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	if ([recievedData length] < 10) {
    currentlyUpdatingListings = NO;
		NSLog(@"processListingData - No Data from server");
		//show some alert
		[locationMgr stopUpdatingLocation];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				
		savedLocationCoordinate.latitude = [[defaults valueForKey:gcSavedLatitude] doubleValue];
		savedLocationCoordinate.longitude = [[defaults valueForKey:gcSavedLongitude] doubleValue];
		[self hideProcessing];

		if ([delegate respondsToSelector:@selector(didFailLoadListings)]) {
			[delegate performSelectorOnMainThread:@selector(didFailLoadListings) withObject:nil waitUntilDone:NO];
		} else {
			NSLog(@"Delegate does not respond to didFailLoadListings");
		}
		if (currentLocation && self.currentMetroID == myNearbyMetroID) {
			if (checkinAndPopularDelegate) {
				if ([checkinAndPopularDelegate respondsToSelector:@selector(errorRecievingCheckInUpdates)]) {
					[checkinAndPopularDelegate performSelectorOnMainThread:@selector(errorRecievingCheckInUpdates) withObject:nil waitUntilDone:NO];
				} else {
					NSLog(@"checkinAndPopularDelegate does not respond to didUpdateListings");
				}
			}
		}
		[aPool release];
		return;
		
	}
	
	NSMutableString *tempString = [[NSMutableString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	//NSLog(@"before listings: %@",tempString);

	NSMutableDictionary *dict = [tempString JSONValueWithStrings];
//	NSLog(@"Listings and Events: %@",dict);
	
	
	if (dict) {
		NSMutableDictionary *tempEvents = [dict objectForKey:@"events_response"];
		NSMutableDictionary *tempListings = [dict objectForKey:@"listings_response"];
		if (tempListings) {
			if ([[tempListings objectForKey:@"metro_id"]intValue] != self.currentMetroID) {
				//[nearbyUpdates performSelectorOnMainThread:@selector(removeAllObjects) withObject:nil waitUntilDone:NO];
        self.metros.currentMetroID = [[tempListings objectForKey:@"metro_id"] intValue];
				if (currentLocation) {
					myNearbyMetroID = self.currentMetroID;
					[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:myNearbyMetroID] forKey:gcSavedHomeMetro];
					//show message if different my location
					[self performSelectorOnMainThread:@selector(calculateMetroDistance) withObject:nil waitUntilDone:YES];

				} else {
					if ([delegate respondsToSelector:@selector(didChangeCurrentMetro)]) {
						[delegate performSelectorOnMainThread:@selector(didChangeCurrentMetro) withObject:nil waitUntilDone:YES];
					} else {
						//NSLog(@"Delegate does not respond to didChangeCurrentMetro");
					}
				}
			} else if (currentLocation) {
				myNearbyMetroID = self.currentMetroID;
				[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:myNearbyMetroID] forKey:gcSavedHomeMetro];
				//show message if different my location
			}
		}
		
		if (tempEvents) {
			NSMutableArray *newEvents = [tempEvents objectForKey:@"events"];
      //NSLog(@"New Events: %@", newEvents);
			NSMutableArray *formattedEvents = [[NSMutableArray alloc] init];
      GCEventsController *eventsController = [[GCEventsController alloc] init];
      
      
			if (newEvents && [newEvents isKindOfClass:[NSMutableArray class]]) {
				for (NSMutableDictionary *event in newEvents) {
					GCEventSummary *eventSummary = [[GCEventSummary alloc] init];
					
					int time = [[event objectForKey:@"start"] intValue];
					eventSummary.startTimeInterval = time;
					[event setObject:eventSummary.startDate forKey:@"start"];
					time = [[event objectForKey:@"end"] intValue];
					eventSummary.endTimeInterval = time;
					[event setObject:eventSummary.endDate forKey:@"end"];
					eventSummary.event = event;
					eventSummary.event_id = [event objectForKey:@"event_id"];
					eventSummary.eventHours = [event objectForKey:@"hours"];
					eventSummary.eventName = [event objectForKey:@"name"];
					eventSummary.numAttending = [event objectForKey:@"num_attending"];
					eventSummary.photo_url = [event objectForKey:@"photo_url"];
					eventSummary.metro_id = [event objectForKey:@"metro_id"];
          eventSummary.group = [event objectForKey:@"group"];
          eventSummary.popularType = [event objectForKey:@"popular_label"];
          eventSummary.isPopular = [[event objectForKey:@"popular"] boolValue];
          
					[formattedEvents addObject:eventSummary];
          [eventsController addNewEvent:eventSummary];
          [eventSummary release];
					
				}
				
				if ([formattedEvents count] == [newEvents count]) {
					[tempEvents setObject:formattedEvents forKey:@"events"];
				} else {
					[tempEvents setObject:[NSMutableArray array] forKey:@"events"];
				}
				
				
			}
			//NSLog(@"New Events Post: %@", newEvents);
			[dict setObject:eventsController forKey:@"organized_events"];
			[eventsController release];
			[formattedEvents release];

		}
		//NSLog(@"listings: %@",dict);
		[self performSelectorOnMainThread:@selector(processListingsAndEvents:) withObject:dict waitUntilDone:NO];
	} else {
		[self performSelectorOnMainThread:@selector(processListingsAndEvents:) withObject:nil waitUntilDone:NO];
	}
	
	[self hideProcessing];

	[tempString release];
	[aPool release];

}

-(void)processListingsAndEvents:(NSMutableDictionary *)newListingsAndEvents
{
  currentlyUpdatingListings = NO;
	if (!newListingsAndEvents) {
		[listings setNewListings:nil forMetroID:self.currentMetroID lat:0 lng:0 addPopular:NO];
		if (previousLocation && self.currentMetroID == myNearbyMetroID) {
			if (listings.cachedCheckinListingsLoaded) {
				listings.closeByCheckinListingsLoaded = YES;
			}
			
			if (checkinAndPopularDelegate) {
				if ([checkinAndPopularDelegate respondsToSelector:@selector(errorRecievingCheckInUpdates)]) {
					[checkinAndPopularDelegate errorRecievingCheckInUpdates];
				} else {
					NSLog(@"checkinAndPopularDelegate does not respond to errorRecievingCheckInUpdates");
				}
			}
		}
	}else {
		if (previousLocation && self.currentMetroID == myNearbyMetroID) {
			[listings setNewListings:newListingsAndEvents forMetroID:self.currentMetroID lat:previousLocation.coordinate.latitude lng:previousLocation.coordinate.longitude addPopular:YES];
			if (checkinAndPopularDelegate) {
				if ([checkinAndPopularDelegate respondsToSelector:@selector(didRecieveCheckInUpdates)]) {
					[checkinAndPopularDelegate didRecieveCheckInUpdates];
				} else {
					NSLog(@"checkinAndPopularDelegate does not respond to didRecieveCheckInUpdates");
				}
			}
		} else {
			[listings setNewListings:newListingsAndEvents forMetroID:self.currentMetroID lat:0 lng:0 addPopular:NO];
			
			if (!previousLocation && myNearbyMetroID != -1 && listings.closeByCheckinListingsLoaded) {
				if (checkinAndPopularDelegate) {
					if ([checkinAndPopularDelegate respondsToSelector:@selector(errorRecievingCheckInUpdates)]) {
						[checkinAndPopularDelegate errorRecievingCheckInUpdates];
					} else {
						NSLog(@"checkinAndPopularDelegate does not respond to errorRecievingCheckInUpdates");
					}
				}
			}
			
		}
	} 

	if ([delegate respondsToSelector:@selector(didUpdateListings)]) {
		[delegate didUpdateListings];
	} else {
		NSLog(@"Delegate does not respond to didUpdateListings");
	}
	
	[self getPeopleUpdates];
	
	if (self.previousLocation || self.currentLocation) [self updateFoursquareListings];
}



-(void)calculateMetroDistance
{	
	if (!previousLocation || (previousLocation.coordinate.latitude == 0 && previousLocation.coordinate.longitude == 0)) {
//		NSLog(@"No Previous Location - Not displaying metro distance message");
		return;
	}
	
	float distance;
	CLLocation *location = [[CLLocation alloc] initWithLatitude:metros.currentMetro.metroLocation.latitude longitude:metros.currentMetro.metroLocation.longitude];
	if ([location respondsToSelector:@selector(distanceFromLocation:)]) {
		distance = [location distanceFromLocation:previousLocation];
	} else {
		distance = [location distanceFromLocation:previousLocation];
	}
	distance = distance/1000;
	distance = distance * .6214;
	[location release];
	NSLog(@"calculateMetroDistance - Distance:%1.1f", distance);
	if (distance > 75) {
		UIAlertView *metroDistanceError = [[UIAlertView alloc] initWithTitle:@"No Cities Nearby" 
																	 message:[NSString stringWithFormat:@"The closest city to your current location is %@, which is %1.1f miles away.",metros.currentMetro.metro_name,distance ] 
																	delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[metroDistanceError show];
		[metroDistanceError release];
	}
	
}

#pragma mark Checkin LIstings Only

-(void)locateCheckinListingsForLocation:(CLLocationCoordinate2D)myLocation {
	//[nearbyUpdates performSelectorOnMainThread:@selector(removeAllObjects) withObject:nil waitUntilDone:NO];
	NSMutableString *searchString = [[NSMutableString alloc] initWithString:@"&results=json&full=1"];
	
  [searchString appendFormat:@"&metro_id=0&lat=%f&lng=%f",myLocation.latitude, myLocation.longitude ];
  NSLog(@"locateCheckinListingsForLocation - lat=%f , long=%f",myLocation.latitude, myLocation.longitude);
	
	[self sendAsyncRequestWithAPI:@"listings" parameters:searchString type:GCRequestTypeCheckinListings];
	[searchString release];
}

- (void)processCheckinData:(NSData *)receivedData {
  NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	if ([receivedData length] < 10) {
		NSLog(@"locateCheckinListingsForLocation - No Data from server");
		//show some alert
		[self hideProcessing];

    if (checkinAndPopularDelegate) {
      if ([checkinAndPopularDelegate respondsToSelector:@selector(errorRecievingCheckInUpdates)]) {
        [checkinAndPopularDelegate performSelectorOnMainThread:@selector(errorRecievingCheckInUpdates) withObject:nil waitUntilDone:NO];
      } else {
        NSLog(@"checkinAndPopularDelegate does not respond to didUpdateListings");
      }
    }
		[aPool release];
		return;
	}
	
	//NSLog(@"Recieved Data from Server");
	
	
	NSMutableString *tempString = [[NSMutableString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	//NSLog(@"before listings: %@",tempString);
  
	NSMutableDictionary *dict = [tempString JSONValueWithStrings];
  //	NSLog(@"Listings and Events: %@",dict);
  [tempString release];
//	NSLog(@"locateCheckinListingsForLocation - checkin Listings: %@", dict);
  return;
  
	if (dict) {
		NSMutableDictionary *tempListings = [dict objectForKey:@"listings_response"];
		if (tempListings) {
			if (currentLocation) {
        myNearbyMetroID = [[tempListings objectForKey:@"metro_id"] intValue];
			}
		}
		//NSLog(@"listings: %@",dict);
		[self performSelectorOnMainThread:@selector(processCheckinListings:) withObject:dict waitUntilDone:NO];
	} else {
		[self performSelectorOnMainThread:@selector(processCheckinListings:) withObject:nil waitUntilDone:NO];
	}
	
	[self hideProcessing];
  
	[aPool release];
}

- (void)processCheckinListings:(NSArray *)listings {
  
}


#pragma mark Metros

- (void)locateMetros 
{
	//[self sendAsyncRequestWithAPI:@"metros" andParameters:@"&results=json"];
	//[self sendAsyncRequestWithAPI:@"metros" parameters:@"&results=json" type:GCRequestTypeMetros];

	
	NSMutableString *searchString = [[NSMutableString alloc] initWithString:@"&results=json&apis=metros|broadcast"];
	
	if (previousLocation) {
		[searchString appendFormat:@"&lat=%f&lng=%f", previousLocation.coordinate.latitude, previousLocation.coordinate.longitude];
	} else {
    [searchString appendFormat:@"&lat=%f&lng=%f", savedLocationCoordinate.latitude, savedLocationCoordinate.longitude];
	} 
//	NSLog(@"Broadcast Search String:%@", searchString);
	[NSThread detachNewThreadSelector:@selector(locateMetrosThread:) toTarget:self withObject:searchString];
	[searchString release];

}

- (void)locateMetrosThread:(NSMutableString *)searchString
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];

	
	
	if (ul.authToken && ul.gcLoginUsername) {
		if (ul.loginChecked && ul.currentLoginStatus) {
			[searchString appendFormat:@"&un=%@&at=%@",ul.gcLoginUsername,ul.authToken];
		}
		else if ([ul checkLoginReturningBOOLThread]) {
			[searchString appendFormat:@"&un=%@&at=%@",ul.gcLoginUsername,ul.authToken];			
		}
	} 
	
	[self performSelectorOnMainThread:@selector(sendLocateMetrosRequest:) withObject:searchString waitUntilDone:YES];
	
	[aPool release];
}

- (void)sendLocateMetrosRequest:(NSMutableString *)searchString
{
	
	[self sendAsyncRequestWithAPI:@"jsonapiloader" parameters:searchString type:GCRequestTypeMetros];
	
}

- (void)processMetroData:(NSData *)recievedMetroData
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	if ([recievedMetroData length] < 10) {
		[self performSelectorOnMainThread:@selector(processMetros:) withObject:nil waitUntilDone:YES];
		[aPool release];
		NSLog(@"No Data For Metros");
		return;
	}
	NSString *metroString = [[NSString alloc] initWithData:recievedMetroData encoding:NSUTF8StringEncoding];
	
	//NSLog(@"metros: %@", metroString);
	
	if ([metroString length] < 10) {
		NSLog(@"No String For Metros");
		[self performSelectorOnMainThread:@selector(processMetros:) withObject:nil waitUntilDone:YES];
		[metroString release];
		[aPool release];
		return;
	}
	
	NSDictionary *metroDict = [metroString JSONValueWithStrings];
	//NSLog(@"metros: %@", metroDict);
	[metroString release];
	
	if (!metroDict) {
		NSLog(@"No JSON For Metros");
		[self performSelectorOnMainThread:@selector(processMetros:) withObject:nil waitUntilDone:YES];
		[aPool release];
		return;
	}
	
	[self performSelectorOnMainThread:@selector(processMetros:) withObject:metroDict waitUntilDone:YES];
	
	
	
	
	[aPool release];
}

-(void)processMetros:(NSMutableDictionary *)items
{
	if (!items) {
		messagesRecieved = YES;
		return;
	}
	//NSLog(@"Metros raw: %@", items);
	NSMutableArray *newMetros =  [[items objectForKey:@"metros_response"] objectForKey:@"metros"];
	[metros setNewMetros:newMetros];
	if ([delegate respondsToSelector:@selector(didUpdateMetros)]) {
		[delegate didUpdateMetros];
	} else {
		//NSLog(@"Delegate does not respond to didUpdateMetros");
	}
	NSMutableDictionary *messageResponse = [items objectForKey:@"broadcast_response"];
	if (!messageResponse) {
		//messagesRecieved = YES;
		return;
	}
	NSLog(@"Broadcast: %@", messageResponse);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *sentMessages = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:gcShownServerMessages]];
	/*NSMutableArray *newSentMessages = [[NSMutableArray alloc] init];
	for (NSMutableDictionary *shownMessage in sentMessages) {
		if ([shownMessage objectForKey:@"expires"]) {
			if ([[shownMessage objectForKey:@"expires"] doubleValue] > [NSDate timeIntervalSinceReferenceDate] || [[shownMessage objectForKey:@"expires"] doubleValue] == 0) {
				[newSentMessages addObject:shownMessage];
			}
		} else {
			[newSentMessages addObject:shownMessage];
		}
	}
	[sentMessages release];*/

	if ([messageResponse objectForKey:@"messages"]) {
		if ([[messageResponse objectForKey:@"messages"] isKindOfClass:[NSArray class]]) {
			
			NSMutableArray *newMessages = [[NSMutableArray alloc] initWithArray:[messageResponse objectForKey:@"messages"]];

			NSMutableArray *pendingMessages = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:gcPendingServerMessages]];
			
			
			
			for (NSMutableDictionary *message in newMessages) {
				BOOL found = NO;
				for (NSMutableDictionary *shownMessage in sentMessages) {
					if ([[shownMessage objectForKey:@"id"] isEqualToString:[message objectForKey:@"id"]]) {
						found = YES;
						break;
					}
				}
				if (!found) {
					int count = -1;
					for (NSMutableDictionary *pendingMessage in pendingMessages) {
						count ++;
						if ([[pendingMessage objectForKey:@"id"] isEqualToString:[message objectForKey:@"id"]]) {
							found = YES;
							break;
						}
					}
					if (found) {
						if ([[message objectForKey:@"priority"] isEqualToString:@"-1"]) {
							[pendingMessages removeObjectAtIndex:count];
						} else if ([message objectForKey:@"expires"]) {
							if ([[message objectForKey:@"expires"] doubleValue] < [[NSDate date] timeIntervalSince1970] && [[message objectForKey:@"expires"] doubleValue] > 0) {
								[pendingMessages removeObjectAtIndex:count];
								[sentMessages addObject:message];
							} else {
								[pendingMessages replaceObjectAtIndex:count withObject:message];
							}
						} else {
							[pendingMessages replaceObjectAtIndex:count withObject:message];
						}
					}
				}
				
				if (!found) {
					if (![[message objectForKey:@"priority"] isEqualToString:@"-1"]) {
						if ([message objectForKey:@"expires"]) {
							if ([[message objectForKey:@"expires"] doubleValue] > [[NSDate date] timeIntervalSince1970] || [[message objectForKey:@"expires"] doubleValue] == 0) {
								[pendingMessages addObject:message];
							} else {
								[sentMessages addObject:message];
							}
						} else {
							[pendingMessages addObject:message];
						}
					}
				}
			}
			
			[defaults setObject:pendingMessages forKey:gcPendingServerMessages];
			[pendingMessages release];
			[newMessages release];
		}
	}
	[defaults setObject:sentMessages forKey:gcShownServerMessages];
	[defaults synchronize];
	[sentMessages release];

	messagesRecieved = YES;


}

#pragma mark Event Details

-(void)loadEventDetails:(NSString *)event_id processing:(BOOL)showProcessing
{
	if (showProcessing) {
		[self showProcessing:@"Getting Event Details..."];
	}
	[NSThread detachNewThreadSelector:@selector(eventDetailsThread:) toTarget:self withObject:event_id];
}

-(void)eventDetailsThread:(NSString *)event_id
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];

	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&event_id=%@",event_id];
	
	if (ul.authToken && ul.gcLoginUsername) {
		if (ul.loginChecked && ul.currentLoginStatus) {
			[searchString appendFormat:@"&un=%@&at=%@",ul.gcLoginUsername,ul.authToken];
			
		}
		else if ([ul checkLoginReturningBOOLThread]) {
			[searchString appendFormat:@"&un=%@&at=%@",ul.gcLoginUsername,ul.authToken];

		}
	} 
	[self performSelectorOnMainThread:@selector(sumbitQueryForEvent:) withObject:searchString waitUntilDone:NO];
	[searchString release];
	
	[aPool release];
	
}

- (void)sumbitQueryForEvent:(NSString *)parameters
{
	[self sendAsyncRequestWithAPI:@"event" parameters:parameters type:GCRequestTypeEventDetails];
}
	
	
- (void)processEventDetailData:(NSData *)eventData
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	if (!eventData) {
		NSLog(@"No Event Received");
		[self hideProcessing];
		
		if ([eventDelegate respondsToSelector:@selector(didFailLoadEventDetails)]) {
			[eventDelegate performSelectorOnMainThread:@selector(didFailLoadEventDetails) withObject:nil waitUntilDone:YES];
			
		} else {
			NSLog(@"Delegate does not respond to didFailLoadEventDetails");
		}
		
		[self showAlertWithTitle:@"Could not load event" message:@"Please check your network connection or try again later"];
		
		[aPool release];
		return;
	}
	
	NSString *eventString = [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding];
	//NSLog(@"event results: %@", eventString);
	NSMutableDictionary *eventDict = [eventString JSONValueWithStrings];
	//NSLog(@"event string: %@", eventString);
	
	[eventString release];
	//NSLog(@"event results: %@", eventDict);
	if (!eventDict) {
		NSLog(@"No Event Received");
		[self hideProcessing];
		
		if ([eventDelegate respondsToSelector:@selector(didFailLoadEventDetails)]) {
			[eventDelegate performSelectorOnMainThread:@selector(didFailLoadEventDetails) withObject:nil waitUntilDone:YES];
			
		} else {
			NSLog(@"Delegate does not respond to didFailLoadEventDetails");
		}
		
		[self showAlertWithTitle:@"Could not load event" message:@"Please check your network connection or try again later"];
		
		[aPool release];
		return;
	}
	
	int seconds = [[NSTimeZone systemTimeZone] secondsFromGMT];
	//int seconds = 0;
	//GCEvent *event = [[GCEvent alloc] initW
	int time = [[eventDict objectForKey:@"start"] intValue];
	[eventDict setObject:[NSDate dateWithTimeIntervalSince1970:(time - seconds)] forKey:@"start"];
	time = [[eventDict objectForKey:@"end"] intValue];
	[eventDict setObject:[NSDate dateWithTimeIntervalSince1970:(time - seconds)] forKey:@"end"];
	//NSLog(@"event results: %@", event);
	NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[eventDict objectForKey:@"attendees"]];
	[[eventDict objectForKey:@"attendees"] setArray:tempArray];
	[tempArray release];
	
	//NSLog(@"event results post: %@", eventDict);

	NSMutableArray *attendees = [[NSMutableArray alloc] init];
	
	for (NSMutableDictionary *attendee in [eventDict objectForKey:@"attendees"]) {
		GCPerson *person = [[GCPerson alloc] init];
		person.user = attendee;
		person.u_photo_url = [person.user objectForKey:@"u_photo"];
		[attendees addObject:person];
		[person release];
	}
	[[eventDict objectForKey:@"attendees"] setArray:attendees];
	[attendees release];
	[self hideProcessing];

	
	if ([eventDelegate respondsToSelector:@selector(didLoadEventDetails:)]) {
		[eventDelegate performSelectorOnMainThread:@selector(didLoadEventDetails:) withObject:eventDict waitUntilDone:YES];
	} else {
		NSLog(@"Delegate does not respond to didLoadEventDetails");
	}
	
	[aPool release];
}




#pragma mark Listing People

- (void)updateListingPeople:(GCListing *)listing
{
	[self isThereNoInternet];
	
	if (noInternet) {
		if ([listingDelegate respondsToSelector:@selector(errorListingPeopleUpdate)]) {
			[listingDelegate errorListingPeopleUpdate];
		} else {
			NSLog(@"listingDelegate does not respond to noInternetErrorListing");
		}
		return;
	}
	//[NSThread detachNewThreadSelector:@selector(processListingPeopleData:) toTarget:self withObject:recievedData];
	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&listing_id=%@&type=%@&results=json",listing.listing_id, listing.type];
	
	[self sendAsyncRequestWithAPI:@"listingpeople" parameters:searchString type:GCRequestTypeListingPeople];
	[searchString release];
	
}

- (void)processListingPeopleData:(NSData *)recievedData
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSString *tempString = [[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
	
	if ([tempString length] < 10) {
		NSLog(@"processListingPeopleData - No Data");
		[tempString release];
		if ([listingDelegate respondsToSelector:@selector(errorListingPeopleUpdate)]) {
			[listingDelegate performSelectorOnMainThread:@selector(errorListingPeopleUpdate) withObject:nil waitUntilDone:NO];
		} else {
			NSLog(@"listingDelegate does not respond to noInternetErrorListing");
		}
		[aPool release];
		return;
	}
	//NSLog(@"listing people: %@", tempString);

	NSMutableDictionary *people = [tempString JSONValueWithStrings];
//	NSLog(@"listing people: %@", tempDict);
	[tempString release];
	
	if (!people) {
		NSLog(@"processListingPeopleData - No Data");
		if ([listingDelegate respondsToSelector:@selector(errorListingPeopleUpdate)]) {
			[listingDelegate performSelectorOnMainThread:@selector(errorListingPeopleUpdate) withObject:nil waitUntilDone:NO];
		} else {
			NSLog(@"listingDelegate does not respond to noInternetErrorListing");
		}
		[aPool release];
		return;
	}
	
	NSMutableArray *checkins = [[NSMutableArray alloc] initWithArray:[people objectForKey:@"checkins"]];
	NSMutableArray *regulars = [[NSMutableArray alloc] initWithArray:[people objectForKey:@"regulars"]];
	
	[people setObject:[NSMutableArray array] forKey:@"recentCheckins"];
	[people setObject:[NSMutableArray array] forKey:@"olderCheckins"];
	[people setObject:regulars forKey:@"regulars"];
	[regulars release];
	
	
	
	if ([checkins count] > 0) {
		[[people objectForKey:@"checkins"] removeAllObjects];
		for (NSMutableDictionary *checkin in checkins) {
			[checkin setObject:[checkin objectForKey:@"id"] forKey:@"checkin_id"];
			[checkin removeObjectForKey:@"id"];
			GCPerson *person = [[GCPerson alloc] init];
			//NSLog(@"checkin: %@", checkin);
			[person setValuesForKeysWithDictionary:checkin];
			person.u_photo_url = [person.user objectForKey:@"u_photo"];
			double time = [person.created doubleValue];
			person.createdTime = [NSDate dateWithTimeIntervalSince1970:time];
			if ([person.createdTime timeIntervalSinceNow]/60 > -120) {
				[[people objectForKey:@"recentCheckins"] addObject:person];
			} else {
				[[people objectForKey:@"olderCheckins"] addObject:person];
			}
			[person release];
		}
	}
	NSMutableArray *newRegulars = [[NSMutableArray alloc] init];
	for (NSMutableDictionary *regular in [people objectForKey:@"regulars"]) {
		GCPerson *person = [[GCPerson alloc] init];
		person.user = regular;
		person.u_photo_url = [person.user objectForKey:@"u_photo"];
		[newRegulars addObject:person];
		[person release];
	}
	[[people objectForKey:@"regulars"] setArray:newRegulars];
	[newRegulars release];
	
	[checkins release];
	if ([[people objectForKey:@"mayor"] objectForKey:@"user"]) {
		if ([[[[people objectForKey:@"mayor"] objectForKey:@"user"] objectForKey:@"u_photo"] length] > 0) {
			NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[[[people objectForKey:@"mayor"] objectForKey:@"user"] objectForKey:@"u_photo"]]];
			if ([data length] > 10) {
				UIImage *image = [[UIImage alloc] initWithData:data];
				[[people objectForKey:@"mayor"] setObject:image forKey:@"profileImage"];
				[image release];
			} else {
				[[people objectForKey:@"mayor"] setObject:[UIImage imageNamed:@"default_profile40.png"] forKey:@"profileImage"];
			}
			[data release];
		} else {
			[[people objectForKey:@"mayor"] setObject:[UIImage imageNamed:@"default_profile40.png"] forKey:@"profileImage"];
		}
	}
	
	
	if ([listingDelegate respondsToSelector:@selector(listingPeopleUpdated:)]) {
		[listingDelegate performSelectorOnMainThread:@selector(listingPeopleUpdated:) withObject:people waitUntilDone:NO];
	} else {
		//NSLog(@"listingDelegate does not respond to listingPeopleUpdated");
	}
	
	
	
	
	
	[aPool release];
}

#pragma mark Listing Photos

- (void)loadListingPhotos:(GCListing *)listing
{
	NSMutableString *searchString = [[NSMutableString alloc ] initWithFormat:@"&listing_id=%@&type=%@&results=json",listing.listing_id, listing.type];
	[self sendAsyncRequestWithAPI:@"listingphotos" parameters:searchString type:GCRequestTypeListingPhotos];
	[searchString release];
	
}

- (void)processListingPhotosData:(NSData *)receivedData
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	
	NSString *tempString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	//NSLog(@"reviews & people for listing: %@", tempString);
	
	
	if ([tempString length] < 10) {
		NSLog(@"loadListingPhotos - No Data");
		[tempString release];
		if ([listingDelegate respondsToSelector:@selector(didRecieveListingPhoto:)]) {
			[listingDelegate performSelectorOnMainThread:@selector(didRecieveListingPhoto:) withObject:nil waitUntilDone:NO ];
		} else {
			NSLog(@"listingDelegate does not respond to didRecieveListingPhoto");
		}
		[aPool release];
		return;
	}
	
	NSDictionary *resultsDict = [tempString JSONValueWithStrings];
//	NSLog(@"loadListingPhotos - %@", resultsDict);
	[tempString release];
	if (!resultsDict) {
		NSLog(@"loadListingPhotos - No Data");
		if ([listingDelegate respondsToSelector:@selector(didRecieveListingPhoto:)]) {
			[listingDelegate performSelectorOnMainThread:@selector(didRecieveListingPhoto:) withObject:nil waitUntilDone:NO ];
		} else {
			NSLog(@"listingDelegate does not respond to didRecieveListingPhoto");
		}
		[aPool release];
		return;
	}
	
	
	NSMutableArray *photos = nil;
	if ([[resultsDict objectForKey:@"photos"] isKindOfClass:[NSMutableArray class]]) {
		photos = [resultsDict objectForKey:@"photos"];
	}
	if ([listingDelegate respondsToSelector:@selector(didRecieveListingPhoto:)]) {
		[listingDelegate performSelectorOnMainThread:@selector(didRecieveListingPhoto:) withObject:photos waitUntilDone:NO];
	} else {
		NSLog(@"listingDelegate does not respond to didRecieveListingPhoto");
	}
	
	[aPool release];
}

#pragma mark Listing Reviews && People Combined

- (void)loadReviewsAndPeopleForListing:(GCListing *)listing
{
	BOOL savedDataExists = [listings loadListingReviews:listing];
	
	if (savedDataExists) {
		if ([listingDelegate respondsToSelector:@selector(didUpdateReviews:)]) {
			[listingDelegate didUpdateReviews:nil];
		} else {
			//NSLog(@"listingDelegate does not respond to didUpdateReviews");
		}
		
	} else if (noInternet) {
		
		if ([listingDelegate respondsToSelector:@selector(errorListingPeopleReviewsUpdate)]) {
			[listingDelegate errorListingPeopleReviewsUpdate];
		} else {
			//NSLog(@"listingDelegate does not respond to noDataErrorReviews");
		}
		return;
	}
	[self loadListingPhotos:listing];
	
	//[NSThread detachNewThreadSelector:@selector(processReviewsAndPeopleForListingData:) toTarget:self withObject:recievedData];
	NSMutableString *searchString = [[NSMutableString alloc ] initWithFormat:@"&apis=reviews|listingpeople&listing_id=%@&type=%@&results=json",listing.listing_id, listing.type];
	//NSLog(@"reviews post: %@",searchString);
	[self sendAsyncRequestWithAPI:@"jsonapiloader" parameters:searchString type:GCRequestTypeListingPeopleAndReviews];
	[searchString release];
	
}


- (void)processReviewsAndPeopleForListingData:(NSData *)receivedData
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	
	NSString *tempString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	//NSLog(@"reviews & people for listing: %@", tempString);

	
	if ([tempString length] < 10) {
		NSLog(@"processReviewsAndPeopleForListingData - No Data");
		[tempString release];
		if ([listingDelegate respondsToSelector:@selector(errorListingPeopleReviewsUpdate)]) {
			[listingDelegate performSelectorOnMainThread:@selector(errorListingPeopleReviewsUpdate) withObject:nil waitUntilDone:NO ];
		} else {
			NSLog(@"listingDelegate does not respond to errorListingPeopleReviewsUpdate");
		}
		[aPool release];
		return;
	}
	
	NSDictionary *resultsDict = [tempString JSONValueWithStrings];
	//NSLog(@"reviews & people for listing: %@", resultsDict);
	[tempString release];
	
	if (!resultsDict) {
		NSLog(@"processReviewsAndPeopleForListingData - No Data");
		if ([listingDelegate respondsToSelector:@selector(errorListingPeopleReviewsUpdate)]) {
			[listingDelegate performSelectorOnMainThread:@selector(errorListingPeopleReviewsUpdate) withObject:nil waitUntilDone:NO ];
		} else {
			NSLog(@"listingDelegate does not respond to errorListingPeopleReviewsUpdate");
		}
		[aPool release];
		return;
	}

	NSMutableDictionary *reviewsResponse = [resultsDict objectForKey:@"reviews_response"];
	if (reviewsResponse) {
		NSMutableArray *reviews = [[NSMutableArray alloc] initWithArray:[reviewsResponse objectForKey:@"reviews"]];
		NSMutableArray *newReviews = [[NSMutableArray alloc] init];
		for (NSDictionary *reviewDict in reviews) {
			GCListingReview *review = [[GCListingReview alloc] init];
			[review setValuesForKeysWithDictionary:reviewDict];
			review.r_text = [NSString filterString:review.r_text];
			review.r_title = [NSString filterString:review.r_title];
			review.stars = [OCConstants reviewStarsForRating:[review.r_rating floatValue]];
			[newReviews addObject:review];
			[review release];
		}
		[reviews setArray:newReviews];
		[newReviews release];
		if ([listingDelegate respondsToSelector:@selector(didUpdateReviews:)]) {
			
			[listingDelegate performSelectorOnMainThread:@selector(didUpdateReviews:) withObject:reviews waitUntilDone:NO];
		} else {
			NSLog(@"ListingDelegate does not respond to didUpdateReviews");
		}
		
		[reviews release];
	} else {
		if ([listingDelegate respondsToSelector:@selector(didUpdateReviews:)]) {
			
			[listingDelegate performSelectorOnMainThread:@selector(didUpdateReviews:) withObject:nil waitUntilDone:NO];
		} else {
			NSLog(@"ListingDelegate does not respond to didUpdateReviews");
		}
	}
	
	NSMutableDictionary *people = [resultsDict objectForKey:@"listingpeople_response"];
	NSMutableArray *checkins = [[NSMutableArray alloc] initWithArray:[people objectForKey:@"checkins"]];
	NSMutableArray *regulars = [[NSMutableArray alloc] initWithArray:[people objectForKey:@"regulars"]];
	
	[people setObject:[NSMutableArray array] forKey:@"recentCheckins"];
	[people setObject:[NSMutableArray array] forKey:@"olderCheckins"];
	[people setObject:regulars forKey:@"regulars"];
	[regulars release];
	
	
	
	if ([checkins count] > 0) {
		[[people objectForKey:@"checkins"] removeAllObjects];
		for (NSMutableDictionary *checkin in checkins) {
			[checkin setObject:[checkin objectForKey:@"id"] forKey:@"checkin_id"];
			[checkin removeObjectForKey:@"id"];
			GCPerson *person = [[GCPerson alloc] init];
			//NSLog(@"checkin: %@", checkin);
			[person setValuesForKeysWithDictionary:checkin];
			person.u_photo_url = [person.user objectForKey:@"u_photo"];
			double time = [person.created doubleValue];
			person.createdTime = [NSDate dateWithTimeIntervalSince1970:time];
			if ([person.createdTime timeIntervalSinceNow]/60 > -120) {
				[[people objectForKey:@"recentCheckins"] addObject:person];
			} else {
				[[people objectForKey:@"olderCheckins"] addObject:person];
			}
			[person release];
		}
	}
	NSMutableArray *newRegulars = [[NSMutableArray alloc] init];
	for (NSMutableDictionary *regular in [people objectForKey:@"regulars"]) {
		GCPerson *person = [[GCPerson alloc] init];
		person.user = regular;
		person.u_photo_url = [person.user objectForKey:@"u_photo"];
		[newRegulars addObject:person];
		[person release];
	}
	[[people objectForKey:@"regulars"] setArray:newRegulars];
	[newRegulars release];
	
	[checkins release];
	if ([[people objectForKey:@"mayor"] objectForKey:@"user"]) {
		if ([[[[people objectForKey:@"mayor"] objectForKey:@"user"] objectForKey:@"u_photo"] length] > 0) {
			NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[[[people objectForKey:@"mayor"] objectForKey:@"user"] objectForKey:@"u_photo"]]];
			if ([data length] > 10) {
				UIImage *image = [[UIImage alloc] initWithData:data];
				[[people objectForKey:@"mayor"] setObject:image forKey:@"profileImage"];
				[image release];
			} else {
				[[people objectForKey:@"mayor"] setObject:[UIImage imageNamed:@"default_profile40.png"] forKey:@"profileImage"];
			}
			[data release];
		} else {
			[[people objectForKey:@"mayor"] setObject:[UIImage imageNamed:@"default_profile40.png"] forKey:@"profileImage"];
		}
	}
	
	if ([listingDelegate respondsToSelector:@selector(listingPeopleUpdated:)]) {
		[listingDelegate performSelectorOnMainThread:@selector(listingPeopleUpdated:) withObject:people waitUntilDone:NO];
	} else {
		NSLog(@"listingDelegate does not respond to listingPeopleUpdated");
	}
	
	[aPool release];
	
}


#pragma mark Updates (Nearby)

- (void)getPeopleUpdates
{
	[self isThereNoInternet];
	
	if (noInternet) {
		if ([peopleDelegate respondsToSelector:@selector(errorRecievingPeopleUpdates)]) {
			[peopleDelegate errorRecievingPeopleUpdates];
		} else {
			NSLog(@"peopleDelegate does not respond to errorRecievingPeopleUpdates");
		}
		return;
	}
	
	if ([peopleUpdateConnections count] > 0) {
		[self cancelPeopleUpdateRequests];
	}
	if (currentLocation) {
		CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
		[NSThread detachNewThreadSelector:@selector(getPeopleUpdatesThread:) toTarget:self withObject:aLocation];
		[aLocation release];
	} else {
		CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:[metros.currentMetro.metro_lat doubleValue] longitude:[metros.currentMetro.metro_lng doubleValue]];
		[NSThread detachNewThreadSelector:@selector(getPeopleUpdatesThread:) toTarget:self withObject:aLocation];
		[aLocation release];
	}
	
}

- (void)getPeopleUpdatesThread:(CLLocation *)aLocation
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	NSMutableString *searchString = [[NSMutableString alloc] initWithFormat:@"&results=json&nearby=1&lat=%f&lng=%f", aLocation.coordinate.latitude, aLocation.coordinate.longitude];
	
	
	if (ul.authToken && ul.gcLoginUsername) {
		if (ul.loginChecked && ul.currentLoginStatus) {
			[searchString appendFormat:@"&friends=1&un=%@&at=%@", ul.gcLoginUsername, ul.authToken];
			//[searchString appendString:@"&friends=1&un=scott&at=843f8f98adaf35aadb04542fc5229034"];  //scotts for testing
		}
		else if ([ul checkLoginReturningBOOLThread]) {
			[searchString appendFormat:@"&friends=1&un=%@&at=%@", ul.gcLoginUsername, ul.authToken];
			//[searchString appendString:@"&friends=1&un=scott&at=843f8f98adaf35aadb04542fc5229034"];  //scotts for testing
		}
	}
	[self performSelectorOnMainThread:@selector(sendPeopleUpdatesRequest:) withObject:searchString waitUntilDone:YES];
	[searchString release];

	[aPool release];
}

- (void)sendPeopleUpdatesRequest:(NSString *)searchString
{
	[self sendAsyncRequestWithAPI:@"updates" parameters:searchString type:GCRequestTypePeopleUpdates];
	if (!metrosDownloaded) {
		[self locateMetros];
		metrosDownloaded = YES;
	}

}

- (void)processPeopleUpdatesData:(NSData *)receivedData
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	
	
	if ([receivedData length] < 10) {
		NSLog(@"processPeopleUpdatesData - No Data");
		if ([peopleDelegate respondsToSelector:@selector(errorRecievingPeopleUpdates)]) {
			[peopleDelegate performSelectorOnMainThread:@selector(errorRecievingPeopleUpdates) withObject:nil waitUntilDone:NO];
		} else {
			NSLog(@"peopleDelegate does not respond to errorRecievingPeopleUpdates");
		}
		[aPool release];
		return;
	}
	NSString *tempString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	//NSLog(@"updates people: %@", tempString);

	NSMutableDictionary *tempDict = [tempString JSONValueWithStrings];
	//NSLog(@"updates people: %@", tempDict);
	[tempString release];
	
	if (!tempDict) {  //add this to otehr internet methods
		NSLog(@"processPeopleUpdatesData - JSON Error");
		if ([peopleDelegate respondsToSelector:@selector(errorRecievingPeopleUpdates)]) {
			[peopleDelegate performSelectorOnMainThread:@selector(errorRecievingPeopleUpdates) withObject:nil waitUntilDone:NO];
		} else {
			NSLog(@"peopleDelegate does not respond to errorRecievingPeopleUpdates");
		}
		[aPool release];
		return;
	}


	//UIImage *profileImage = [UIImage imageNamed:@"default_profile40.png"];
	
	NSMutableArray *nearby = [[NSMutableArray alloc] initWithArray:[tempDict objectForKey:@"nearby_updates"]];
	NSMutableArray *friends = [[NSMutableArray alloc] initWithArray:[tempDict objectForKey:@"friends_updates"]];
	[[tempDict objectForKey:@"friends_updates"] removeAllObjects];
	[[tempDict objectForKey:@"nearby_updates"] removeAllObjects];
	
	for (NSMutableDictionary *dict in nearby) {
		GCPerson *person = [[GCPerson alloc] init];
		[person setValuesForKeysWithDictionary:dict];
		person.u_photo_url = [person.user objectForKey:@"u_photo"];
		double time = [person.created doubleValue];
		person.createdTime = [NSDate dateWithTimeIntervalSince1970:time];
		//NSLog(@"%@",person);
		[[tempDict objectForKey:@"nearby_updates"] addObject:person];
		[person release];
	}
	[nearby release];
	for (NSMutableDictionary *dict in friends) {
		
		GCPerson *person = [[GCPerson alloc] init];
		[person setValuesForKeysWithDictionary:dict];
		person.u_photo_url = [person.user objectForKey:@"u_photo"];
		double time = [person.created doubleValue];
		person.createdTime = [NSDate dateWithTimeIntervalSince1970:time];
		//NSLog(@"%@",person);
		[[tempDict objectForKey:@"friends_updates"] addObject:person];
		[person release];
	}
	[friends release];
	//NSLog(@"updates people: %@", tempDict);

	[self performSelectorOnMainThread:@selector(replacePeopleUpdates:) withObject:tempDict waitUntilDone:NO];

	[aPool release];
}

- (void)replacePeopleUpdates:(NSMutableDictionary *)peopleUpdates
{
	NSMutableArray *nearby = [peopleUpdates objectForKey:@"nearby_updates"];
	NSMutableArray *friends = [peopleUpdates objectForKey:@"friends_updates"];

	if (nearby) {
		[nearbyUpdates setArray:nearby];
	} else {
		[nearbyUpdates removeAllObjects];
	}
	if (friends) {
		[friendUpdates setArray:friends];

	} else {
		[friendUpdates removeAllObjects];
	}
	
	if ([peopleDelegate respondsToSelector:@selector(didRecievePeopleUpdates)]) {
		[peopleDelegate didRecievePeopleUpdates];
	} else {
		//NSLog(@"peopleDelegate does not respond to didRecievePeopleUpdates");
	}
	//NSLog(@"updates people done: %@\n\n%@", nearbyUpdates, friendUpdates);

}


#pragma mark UserLogin Delegate

- (void)loginResult:(BOOL)result
{
	
}

#pragma mark GCURLConnection Delegates


- (void)connection:(GCURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//NSLog(@"Response Recieved");

    // This method is called when the server has determined that it has enough information to create the NSURLResponse.
    // it can be called multiple times, for example in the case of a redirect, so each time we reset the data.
    [connection resetDataLength];
    
    // Get response code.
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    int statusCode = [resp statusCode];
	NSLog(@"GCURLCONNECTION-RESPONSE: %i, %@",statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);

    if (statusCode >= 400) {
        // Assume failure, and report to delegate.
        NSError *error = [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:nil];
		NSLog(@"GCURLCONNECTION-Error: %@, %d", [error localizedDescription], connection.requestType);
        
        [connection cancel];
        NSString *connectionIdentifier = [connection identifier];
        [self sendFailedRequestWithType:connection.requestType];
        if (connection.requestType == GCRequestTypeMetros) {
          [connections removeObjectForKey:connectionIdentifier];
        } else if (connection.requestType == GCRequestTypeListingsAndEvents) {
          [self hideProcessing];
          [listingConnections removeObjectForKey:connectionIdentifier];

        } else if (connection.requestType == GCRequestTypeCheckinListings) {
          [checkinConnections removeObjectForKey:connectionIdentifier];
          
        } else if (connection.requestType == GCRequestTypePeopleUpdates) {
          [peopleUpdateConnections removeObjectForKey:connectionIdentifier];
          
        } else {
          [otherConnections removeObjectForKey:connectionIdentifier];
        }
    }
}





- (void)connection:(GCURLConnection *)connection didReceiveData:(NSData *)data
{
	//NSLog(@"Data Recieved");

    // Append the new data to the receivedData.
    [connection appendData:data];
}





- (void)connection:(GCURLConnection *)connection didFailWithError:(NSError *)error
{
    
	NSLog(@"**Connection Failed: %d",connection.requestType);
	GCRequestType aType = connection.requestType;
	[self sendFailedRequestWithType:aType];
    // Release the connection.
	NSString *connectionIdentifier = [connection identifier];
	if (aType == GCRequestTypeMetros) {
		[connections removeObjectForKey:connectionIdentifier];
	} else if (aType == GCRequestTypeListingsAndEvents) {
		[self hideProcessing];
		[listingConnections removeObjectForKey:connectionIdentifier];
			
	} else if (aType == GCRequestTypePeopleUpdates) {
		[peopleUpdateConnections removeObjectForKey:connectionIdentifier];
	} else if (aType == GCRequestTypeCheckinListings) {
		[checkinConnections removeObjectForKey:connectionIdentifier];
	} else {
		[otherConnections removeObjectForKey:connectionIdentifier];
	}
	
		
	
}


/*
 GCRequestTypeMetros = 1,
 GCRequestTypeListings,
 GCRequestTypeEvents,
 GCRequestTypeListingsAndEvents,
 GCRequestTypeEventDetails,
 GCRequestTypeListingPeople,
 GCRequestTypeListingPeopleAndReviews,
 GCRequestTypePeopleUpdates,
 GCRequestTypeListingPhotos,
 GCRequestTypeListingsCheckInAndPopular*/



- (void)connectionDidFinishLoading:(GCURLConnection *)connection
{
    NSData *receivedData = [connection data];
	GCRequestType aType = connection.requestType;
	NSString *connectionIdentifier = [connection identifier];

    if (receivedData) {
        if (aType == GCRequestTypeMetros) {
//          NSLog(@"Process Metros");
          if ([connections objectForKey:connectionIdentifier])
            [NSThread detachNewThreadSelector:@selector(processMetroData:) toTarget:self withObject:receivedData];  
        } else if (aType == GCRequestTypeListingsAndEvents) {
//          NSLog(@"Process Listings and Events");
          if ([listingConnections objectForKey:connectionIdentifier])
            [NSThread detachNewThreadSelector:@selector(processListingData:) toTarget:self withObject:receivedData];  
        } else if (aType == GCRequestTypePeopleUpdates) {
//          NSLog(@"Process People Updates");
          if ([peopleUpdateConnections objectForKey:connectionIdentifier])
            [NSThread detachNewThreadSelector:@selector(processPeopleUpdatesData:) toTarget:self withObject:receivedData]; 
        } else if (aType == GCRequestTypeListingPeopleAndReviews) {
//          NSLog(@"Process Listing People and Reviews");
          if ([otherConnections objectForKey:connectionIdentifier])
            [NSThread detachNewThreadSelector:@selector(processReviewsAndPeopleForListingData:) toTarget:self withObject:receivedData]; 
        } else if (aType == GCRequestTypeListingPeople) {
//          NSLog(@"Process Listing People");
          if ([otherConnections objectForKey:connectionIdentifier])
            [NSThread detachNewThreadSelector:@selector(processListingPeopleData:) toTarget:self withObject:receivedData]; 
        } else if (aType == GCRequestTypeListingPhotos) {
//          NSLog(@"Process Listing Photos");
          if ([otherConnections objectForKey:connectionIdentifier])
            [NSThread detachNewThreadSelector:@selector(processListingPhotosData:) toTarget:self withObject:receivedData]; 
        } else if (aType == GCRequestTypeEventDetails) {
//          NSLog(@"Process Event Details");
          if ([otherConnections objectForKey:connectionIdentifier])
            [NSThread detachNewThreadSelector:@selector(processEventDetailData:) toTarget:self withObject:receivedData];  
        } else if (aType == GCRequestTypeCheckinListings) {
//          NSLog(@"Process Checkin Listings");
          if ([checkinConnections objectForKey:connectionIdentifier])
            [NSThread detachNewThreadSelector:@selector(processCheckinData:) toTarget:self withObject:receivedData];  
        } else {
//          NSLog(@"Process Nothing?");
        }
    }
    
    // Release the connection.
	if (aType == GCRequestTypeMetros) {
		[connections removeObjectForKey:connectionIdentifier];
	} else if (aType == GCRequestTypeListingsAndEvents) {
		[listingConnections removeObjectForKey:connectionIdentifier];
	} else if (aType == GCRequestTypePeopleUpdates) {
		[peopleUpdateConnections removeObjectForKey:connectionIdentifier];
	} else if (aType == GCRequestTypeCheckinListings) {
		[checkinConnections removeObjectForKey:connectionIdentifier];
	} else {
		[otherConnections removeObjectForKey:connectionIdentifier];
	}
}

- (void)sendFailedRequestWithType:(GCRequestType)aType
{
	if (aType == GCRequestTypeMetros) {
		NSLog(@"Failed Metros");
		[NSThread detachNewThreadSelector:@selector(processMetroData:) toTarget:self withObject:[NSData data]];  // empoty data object
	} else if (aType == GCRequestTypeListingsAndEvents) {
		NSLog(@"Failed Listings and Events");
		[NSThread detachNewThreadSelector:@selector(processListingData:) toTarget:self withObject:[NSData data]];   //empty nsdata object
	} else if (aType == GCRequestTypePeopleUpdates) {
		NSLog(@"Failed People Updates");
		[NSThread detachNewThreadSelector:@selector(processPeopleUpdatesData:) toTarget:self withObject:[NSData data]]; // empoty data object
	} else if (aType == GCRequestTypeListingPeopleAndReviews) {
		NSLog(@"Failed Listing People and Reviews");
		[NSThread detachNewThreadSelector:@selector(processReviewsAndPeopleForListingData:) toTarget:self withObject:[NSData data]]; // empoty data object
	} else if (aType == GCRequestTypeListingPeople) {
		NSLog(@"Failed Listing People");
		[NSThread detachNewThreadSelector:@selector(processListingPeopleData:) toTarget:self withObject:[NSData data]]; // empoty data object
	} else if (aType == GCRequestTypeListingPhotos) {
		NSLog(@"Failed Listing Photos");
		[NSThread detachNewThreadSelector:@selector(processListingPhotosData:) toTarget:self withObject:[NSData data]]; // empoty data object
	} else if (aType == GCRequestTypeEventDetails) {
		NSLog(@"Failed Event Details");
		[NSThread detachNewThreadSelector:@selector(processEventDetailData:) toTarget:self withObject:[NSData data]];  //empty nsdata object
	} else if (aType == GCRequestTypeCheckinListings) {
		NSLog(@"Failed Checkin Listings");
		[NSThread detachNewThreadSelector:@selector(processCheckinData:) toTarget:self withObject:[NSData data]];  //empty nsdata object
	} else {
		NSLog(@"Failed - No Type?");
	}
}

#pragma mark
#pragma mark Foursquare

- (void)processFoursquareResults:(NSMutableArray *)newListings
{
//  NSLog(@"Process Foursquare results");
  if (!newListings || [newListings count] == 0) {
    self.foursquareListings = [NSArray array];
  } else {
    self.foursquareListings = [NSArray arrayWithArray:newListings];
  }
	
	if (checkinAndPopularDelegate) {
		if ([checkinAndPopularDelegate respondsToSelector:@selector(didRecieveCheckInUpdates)]) {
			[checkinAndPopularDelegate didRecieveCheckInUpdates];
		} else {
			NSLog(@"checkinAndPopularDelegate does not respond to didRecieveCheckInUpdates (FS Update)");
		}
	}
}

- (void)updateFoursquareListings {
  NSLog(@"Update FS Listings");
  NSString *lat = @"0";
  NSString *lng = @"0";
  if (self.previousLocation) {
    lat = [NSString stringWithFormat:@"%f", self.previousLocation.coordinate.latitude];
    lng = [NSString stringWithFormat:@"%f", self.previousLocation.coordinate.longitude];
  } else if (self.currentLocation) {
    lat = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.latitude];
    lng = [NSString stringWithFormat:@"%f", self.currentLocation.coordinate.longitude];
  } else if (myNearbyMetroID != -1) {
    GCMetro *myMetro = [self.metros metroForIntID:myNearbyMetroID];
    lat = [NSString stringWithFormat:@"%f", [myMetro.metro_lat doubleValue]];
    lng = [NSString stringWithFormat:@"%f", [myMetro.metro_lng doubleValue]];
  } else return;
  
  [foursquareController fetchListingsForLat:lat lng:lng];
}
   
- (void)didFetchFoursquareListings:(NSArray *)newListings {
//  NSLog(@"GCCommunicator FS Listings: %@", newListings);
  if (!newListings || [newListings count] == 0) {
    self.foursquareListings = [NSArray array];
    if (checkinAndPopularDelegate) {
      if ([checkinAndPopularDelegate respondsToSelector:@selector(didRecieveCheckInUpdates)]) {
        [checkinAndPopularDelegate didRecieveCheckInUpdates];
      } else {
        NSLog(@"checkinAndPopularDelegate does not respond to didRecieveCheckInUpdates");
      }
    }
    return;
  }
  [NSThread detachNewThreadSelector:@selector(processFoursquareResultsThread:) toTarget:self withObject:newListings];
}

- (void)processFoursquareResultsThread:(NSArray *)newListings {
  NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
  [newListings retain];
  
  NSMutableArray *tempListings = [[NSMutableArray alloc] init];
  NSSet *knownIds = [NSSet setWithSet:self.listings.foursquareIds];
  
	if ([newListings isKindOfClass:[NSArray class]]) {
		for (NSDictionary *listingFound in newListings) {
      NSString *fsId = [listingFound objectForKey:@"id"];
      if (![knownIds containsObject:fsId]) {
        GCListing *listing = [[GCListing alloc] init];
        listing.listing_id = fsId;
        listing.foursquareId = fsId;
        listing.name = [listingFound objectForKey:@"name"];
        NSDictionary *locationInfo = [listingFound objectForKey:@"location"];
        if (locationInfo) {
          listing.lat = [locationInfo objectForKey:@"lat"];
          listing.lng = [locationInfo objectForKey:@"lng"];
          if ([locationInfo objectForKey:@"address"]) listing.street = [locationInfo objectForKey:@"address"];
          else listing.street = nil;
          if ([locationInfo objectForKey:@"city"]) listing.city = [locationInfo objectForKey:@"city"];
          else listing.city = nil;
          if ([locationInfo objectForKey:@"state"]) listing.state = [locationInfo objectForKey:@"state"];
          else listing.state = nil;
          listing.distance = [locationInfo objectForKey:@"distance"];
        }
        
        NSArray *categories = [listingFound objectForKey:@"categories"];
        if (categories && [categories count] > 0) {
          NSDictionary *category = [categories objectAtIndex:0];
          if (category) {
            listing.hood = [category objectForKey:@"name"];
          }
        }
        
        listing.type = @"foursquare";
        [tempListings addObject:listing];
        [listing release];
      }
    }
  }
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
  [tempListings sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	[self performSelectorOnMainThread:@selector(processFoursquareResults:) withObject:tempListings waitUntilDone:YES];
	[tempListings release];
  [newListings release];
  [aPool release];
}



@end





