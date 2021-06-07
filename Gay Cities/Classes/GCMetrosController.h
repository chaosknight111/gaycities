//
//  OCMetros.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/9/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GCMetro.h"
#import "OCConstants.h"

@interface GCMetrosController : NSObject {
	NSMutableArray *metros, *recents;
	int currentMetroID;
	GCMetro *currentMetro;
}

@property (nonatomic, retain) NSMutableArray *metros, *recents;
@property (nonatomic) int currentMetroID;
@property (nonatomic, retain) GCMetro *currentMetro;

- (void)setCurrentMetro:(GCMetro *)newMetro;
- (void)setMetroWithStringID:(NSString *)metroID;
- (int)numberOfStates;
- (int)numberOfCitiesInState:(int)index;
- (NSMutableArray *)citiesForStateIndex:(int)index;
- (void)setNewMetros:(NSArray *)newMetros;
- (GCMetro *)metroForIntID:(int)metroID;
- (void)addRecent:(GCMetro *)metro;
- (void)deleteRecent:(GCMetro *)metro;

@end
