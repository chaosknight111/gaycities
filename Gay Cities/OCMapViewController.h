//
//  OCMapViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/4/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RMMapView;
#import "GCListing.h"

@interface OCMapViewController : UIViewController {
	IBOutlet RMMapView *mv;
	GCListing *listing;
	NSString *titleString, *locationString;
	double lat, lng;
}

@property (nonatomic, retain) RMMapView *mv;
@property (nonatomic, assign) GCListing *listing;
@property (nonatomic, copy) NSString *titleString, *locationString;
@property (readwrite) double lat, lng;

-(IBAction)mapGoogle:(id)sender;
-(IBAction)directionsGoogle:(id)sender;
- (id)initWithLatitude:(double)aLat andLong:(double)aLng andName:(NSString *)aTitle andLocationName:(NSString *)aLocString;

@end
