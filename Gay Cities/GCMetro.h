//
//  GCMetro.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/3/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GCMetro : NSObject {
	NSString *metro_country, *metro_id, *metro_lat, *metro_lng, *metro_name, *metro_state;
	CLLocationCoordinate2D metroLocation;
}

@property (nonatomic, retain) NSString *metro_country, *metro_id, *metro_lat, *metro_lng, *metro_name, *metro_state;
@property (readwrite) CLLocationCoordinate2D metroLocation;


- (id)initWithCountry:(NSString *)new_metro_country ID:(NSString *)new_metro_id lat:(NSString *)new_metro_lat lng:(NSString *)new_metro_lng name:(NSString *)new_metro_name state:(NSString *)new_metro_state;
   
@end
