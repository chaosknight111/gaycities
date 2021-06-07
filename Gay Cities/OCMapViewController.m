//
//  OCMapViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/4/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "OCMapViewController.h"
#import "RMMapView.h"
#import "RMMarkerManager.h"
#import "RMMarker.h"
#import "GayCitiesAppDelegate.h"
#import "OCConstants.h"

@implementation OCMapViewController

@synthesize mv, listing;
@synthesize lat, lng, titleString, locationString;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
-(id)init
{
	if (self = [super init]) {
		[self initWithNibName:@"OCMapViewController" bundle:nil];
		lat = -1;
		lng = -1;
		titleString = nil;
		locationString = nil;
		listing = nil;
		
	}
	return self;
}

- (id)initWithLatitude:(double)aLat andLong:(double)aLng andName:(NSString *)aTitle andLocationName:(NSString *)aLocString
{
	if (self = [super init]) {
		[self initWithNibName:@"OCMapViewController" bundle:nil];
		lat = aLat;
		lng = aLng;
		
		if (aTitle && [aTitle length] > 0) {
			self.titleString = aTitle;
		} else {
			titleString = nil;	
		}
		
		if (aLocString && [aLocString length] > 0) {
			self.locationString = aLocString;
		} else {
			locationString = nil;	
		}
	}
	return self;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];	
	if (titleString && [titleString length] > 0) {
		[self setTitle:titleString];
	} else if (listing) {
		[self setTitle:listing.name];
	} else {
		[self setTitle:@"Map"];
	}
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[RMMapView class];
	CLLocation *aLocation = nil;
	RMMarker *currentPlace = nil;
	
	if (listing) {
		aLocation = [[CLLocation alloc] initWithLatitude:[listing.lat floatValue] longitude:[listing.lng floatValue]];
		currentPlace = [[RMMarker alloc] initWithUIImage:[OCConstants imageForType:listing.type]];

	} else if (lat != -1.0 && lng != -1.0) {
		aLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];  
		currentPlace = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"events-marker.png"]];
		
	} else {
		aLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
		currentPlace = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-grey.png"]]; 

	}
	
	[mv moveToLatLong:aLocation.coordinate];
	[[mv markerManager] addMarker:currentPlace AtLatLong:aLocation.coordinate];
	[[mv contents] setZoom:16];
	[aLocation release];
	[currentPlace release];
}



-(IBAction)mapGoogle:(id)sender
{
	if (listing) {
		NSString *temp = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@,%@",listing.street,listing.city, listing.state];
		NSString *temp2 = [NSString stringWithString:[temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:temp2]];
	} else if (locationString) {
		NSString *temp = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",locationString];
		NSString *temp2 = [NSString stringWithString:[temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:temp2]];
		
	} else if (lat != -1.0 && lng != -1.0) {
		NSString *temp = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f",lat,lng];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:temp]];
		
	}
	

}

-(IBAction)directionsGoogle:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	double startLat = [defaults doubleForKey:gcSavedLatitude];
	double startLng = [defaults doubleForKey:gcSavedLongitude];


	NSString *destination = nil;
	if (listing) {
		destination = [NSString stringWithFormat:@"%@,%@,%@",listing.street,listing.city, listing.state];
		
	} else if (locationString) {
		destination = [NSString stringWithFormat:@"%@",locationString];
		
	} else if (lat != -1.0 && lng != -1.0) {
		destination = [NSString stringWithFormat:@"%f,%f",lat,lng];
		
	}
	
	NSString *temp = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",startLat, startLng, destination];
	NSString *temp2 = [NSString stringWithString:[temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:temp2]];

}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	self.mv = nil;
	if (titleString) {
		self.titleString = nil;
	}
	if (locationString) {
		self.locationString = nil;
	}
    [super dealloc];
}


@end
