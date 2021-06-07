//
//  OCMetros.m
//  Gay states
//
//  Created by Brian Harmann on 12/9/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import "GCMetrosController.h"
#import "OCFMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "GCMetro.h"
#import "GayCitiesAppDelegate.h"

@implementation GCMetrosController

@synthesize metros, recents;
@synthesize currentMetroID, currentMetro;

-(id)init
{
	self = [super init];
	
	metros = [NSMutableArray new];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *savePath = [paths objectAtIndex:0];
	currentMetroID = [[[NSUserDefaults standardUserDefaults] valueForKey:gcSavedPreviousMetro] intValue];

	

	OCFMDatabase *db = [OCFMDatabase databaseWithPath:[savePath stringByAppendingPathComponent:@"allMetros.sqlite"]];
	//db = [FMDatabase databaseWithPath: [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"gc.db"]];

	if (![db open]) {
		NSLog(@"Could not open db.");
		return self;
	}
	NSMutableArray *countries = [[NSMutableArray alloc] init];

	
	OCFMResultSet *rs = [db executeQuery:@"select * from metros"];
    while ([rs next]) {
		GCMetro *metro = [[GCMetro alloc] initWithCountry:[rs stringForColumn:@"metro_country"] 
													   ID:[rs stringForColumn:@"metro_id"] 
													  lat:[rs stringForColumn:@"metro_lat"] 
													  lng:[rs stringForColumn:@"metro_lng"] 
													 name:[rs stringForColumn:@"metro_name"] 
													state:[rs stringForColumn:@"metro_state"]];
		
		
		BOOL typeFound = NO;
		if ([metro.metro_country isEqualToString:@"United States of America (USA)"]) {
			if ([metros count] == 0) {
				NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_state, @"name", [NSMutableArray array], @"metros", nil];
				[[dict objectForKey:@"metros"] addObject:metro];
				[metros addObject:dict];
				[dict release];
				
			} else {
				for (NSDictionary *dict in metros) {
					if ([[dict objectForKey:@"name"] isEqualToString:metro.metro_state]) {
						typeFound = YES;
						[[dict objectForKey:@"metros"] addObject:metro];
						break;
					}
				}
				if (!typeFound) {
					NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_state, @"name", [NSMutableArray array], @"metros", nil];
					[[dict objectForKey:@"metros"] addObject:metro];
					[metros addObject:dict];
					[dict release];
				}
			}
		} else {
			if ([countries count] == 0) {
				NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_country, @"name", [NSMutableArray array], @"metros", nil];
				[[dict objectForKey:@"metros"] addObject:metro];
				[countries addObject:dict];
				[dict release];
				
			} else {
				for (NSDictionary *dict in countries) {
					if ([[dict objectForKey:@"name"] isEqualToString:metro.metro_country]) {
						typeFound = YES;
						[[dict objectForKey:@"metros"] addObject:metro];
						break;
					}
				}
				if (!typeFound) {
					NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_country, @"name", [NSMutableArray array], @"metros", nil];
					[[dict objectForKey:@"metros"] addObject:metro];
					[countries addObject:dict];
					[dict release];
				}
			}
		}
		
		
		if ([metro.metro_id intValue] == currentMetroID) {
			self.currentMetro = metro;
		}
		
		[metro release];
    }
    [rs close]; 
	
	NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
								  initWithKey:@"name"
								  ascending:YES
								  selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
	NSArray *sortedArray = [metros sortedArrayUsingDescriptors:sortDescriptors];
	[metros removeAllObjects];
	[metros addObjectsFromArray:sortedArray];
	[typeName release];
		
	typeName = [[NSSortDescriptor alloc]
				initWithKey:@"name"
				ascending:YES
				selector:@selector(caseInsensitiveCompare:)];
	sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
	sortedArray = [countries sortedArrayUsingDescriptors:sortDescriptors];
	[metros addObjectsFromArray:sortedArray];
	[typeName release];
	[countries release];
	
	[db close];
	//NSLog(@"%@", states);
	if (!currentMetro) {
		currentMetro = [[GCMetro alloc] init];
	}


	return self;
}

-(void)setNewMetros:(NSArray *)newMetros
{
	[metros removeAllObjects];

	NSMutableArray *countries = [[NSMutableArray alloc] init];

	int count = 0;  //just to make sure all metros are being processed
	for (NSDictionary *dict in newMetros) {
		GCMetro *metro = [[GCMetro alloc] initWithCountry:[dict objectForKey:@"metro_country"] 
													   ID:[dict objectForKey:@"metro_id"] 
													  lat:[dict objectForKey:@"metro_lat"] 
													  lng:[dict objectForKey:@"metro_lng"] 
													 name:[dict objectForKey:@"metro_name"] 
													state:[dict objectForKey:@"metro_state"]];
		//NSLog(@"Metro: %@", metro);

	
		
		BOOL typeFound = NO;
		if (!metro.metro_country || (NSNull *)metro.metro_country == [NSNull null]) {
			if ([countries count] == 0) {
				NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_state, @"name", [NSMutableArray array], @"metros", nil];
				[[dict objectForKey:@"metros"] addObject:metro];
				[countries addObject:dict];
				[dict release];
				count ++;
			} else {
				for (NSDictionary *dict in countries) {
					if ([[dict objectForKey:@"name"] isEqualToString:metro.metro_state]) {
						typeFound = YES;
						[[dict objectForKey:@"metros"] addObject:metro];
						count ++;
						break;
					}
				}
				if (!typeFound) {
					NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_state, @"name", [NSMutableArray array], @"metros", nil];
					[[dict objectForKey:@"metros"] addObject:metro];
					[countries addObject:dict];
					[dict release];
					count ++;
				}
			}
		} else if ([metro.metro_country isEqualToString:@"United States of America (USA)"]) {
			if ([metros count] == 0) {
				NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_state, @"name", [NSMutableArray array], @"metros", nil];
				[[dict objectForKey:@"metros"] addObject:metro];
				[metros addObject:dict];
				[dict release];
				count ++;

			} else {
				for (NSDictionary *dict in metros) {
					if ([[dict objectForKey:@"name"] isEqualToString:metro.metro_state]) {
						typeFound = YES;
						[[dict objectForKey:@"metros"] addObject:metro];
						count ++;
						break;
					}
				}
				if (!typeFound) {
					NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_state, @"name", [NSMutableArray array], @"metros", nil];
					[[dict objectForKey:@"metros"] addObject:metro];
					[metros addObject:dict];
					[dict release];
					count ++;
				}
			}
		} else {
			if ([countries count] == 0) {
				NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_country, @"name", [NSMutableArray array], @"metros", nil];
				[[dict objectForKey:@"metros"] addObject:metro];
				[countries addObject:dict];
				[dict release];
				count ++;
			} else {
				for (NSDictionary *dict in countries) {
					if ([[dict objectForKey:@"name"] isEqualToString:metro.metro_country]) {
						typeFound = YES;
						[[dict objectForKey:@"metros"] addObject:metro];
						count ++;
						break;
					}
				}
				if (!typeFound) {
					NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:metro.metro_country, @"name", [NSMutableArray array], @"metros", nil];
					[[dict objectForKey:@"metros"] addObject:metro];
					[countries addObject:dict];
					[dict release];
					count ++;
				}
			}
		}

		
		if ([metro.metro_id intValue] == self.currentMetroID) {
			self.currentMetro = metro;
		}
		
		[metro release];
    }
	
	
	NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
								  initWithKey:@"name"
								  ascending:YES
								  selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
	NSArray *sortedArray = [metros sortedArrayUsingDescriptors:sortDescriptors];
	[metros removeAllObjects];
	[metros addObjectsFromArray:sortedArray];
	
	
	sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
	sortedArray = [countries sortedArrayUsingDescriptors:sortDescriptors];
	[metros addObjectsFromArray:sortedArray];
	[typeName release];
	[countries release];
	
	if (!currentMetro) {
		currentMetro = [[GCMetro alloc] init];
	}
	
	NSLog(@"Metros updated and saved");
	
	[NSThread detachNewThreadSelector:@selector(saveMetrosToDataBaseThread:) toTarget:self withObject:newMetros];
}


- (void)saveMetrosToDataBaseThread:(NSArray *)newMetros
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	
	
	
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"allMetros.sqlite"]];
	
	if (![db open]) {
		NSLog(@"Could not open db.");
		return;
	}
	
	
	[db executeUpdate:@"delete from metros"];
	
	[db beginTransaction];
	for (NSDictionary *dict in newMetros) {

		//NSLog(@"Metro: %@", metro);
		
		if (![db executeUpdate:@"insert into metros (metro_country, metro_id, metro_lat, metro_lng, metro_name, metro_state) values (?, ?, ?, ?, ?, ?)" ,
			  [dict objectForKey:@"metro_country"], 
			  [dict objectForKey:@"metro_id"] , 
			  [dict objectForKey:@"metro_lat"], 
			  [dict objectForKey:@"metro_lng"], 
			  [dict objectForKey:@"metro_name"] , 
			  [dict objectForKey:@"metro_state"]]) {
			NSLog(@"Update Failed: %@", [db lastErrorMessage]);
		}

	}
	[db commit];
	[db close];
	NSLog(@"Metros Saved To Database");
	[aPool release];
	
}





- (void)setCurrentMetro:(GCMetro *)newMetro
{
	if (currentMetro) {
		[currentMetro release];
		currentMetro = nil;
	}
	if (!newMetro) {
		return;
	}
	
	currentMetro = newMetro;
	[currentMetro retain];
	currentMetroID = [currentMetro.metro_id intValue];;

	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:currentMetroID] forKey:gcSavedPreviousMetro];
	
}



- (void)setMetroWithStringID:(NSString *)metroID
{
	for (NSDictionary *dict in metros) {
		for (GCMetro *metro in [dict objectForKey:@"metros"]) {
			if ([metro.metro_id isEqualToString:metroID]) {
				self.currentMetro = metro;
				currentMetroID = [metroID intValue];
				return;
			}
		}
	}
}

- (void)setCurrentMetroID:(int)aMetroId
{
  currentMetroID = aMetroId;
	for (NSDictionary *dict in metros) {
		for (GCMetro *metro in [dict objectForKey:@"metros"]) {
			if ([metro.metro_id intValue] == aMetroId) {
				self.currentMetro = metro;
				return;
			}
		}
	}
}

- (GCMetro *)metroForIntID:(int)metroID
{
	for (NSDictionary *dict in metros) {
		for (GCMetro *metro in [dict objectForKey:@"metros"]) {
			if ([metro.metro_id intValue] == metroID) {
				return metro;
			}
		}
	}
	return nil;
}

-(int)numberOfStates
{
	return [metros count];
}

-(int)numberOfCitiesInState:(int)index
{
	return [[[metros objectAtIndex:index] objectForKey:@"metros"] count];
}


-(NSMutableArray *)citiesForStateIndex:(int)index
{
	return [[metros objectAtIndex:index] objectForKey:@"metros"];


}

- (void)sortRecents {
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"metro_name" ascending:YES];
  [self.recents sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  [sortDescriptor release];
}

- (NSMutableArray *)recents {
  if (!recents) {
    NSArray *metroIds = [[NSUserDefaults standardUserDefaults] objectForKey:gcRecentMetrosKey];
    recents = [[NSMutableArray alloc] init];
    for (NSString *someId in metroIds) {
      GCMetro *metro = [self metroForIntID:[someId intValue]];
      [recents addObject:metro];
    }
    [self sortRecents];
  }
  return recents;
}

- (void)addRecent:(GCMetro *)metro {
  for (GCMetro *aMetro in recents) {
    if ([metro.metro_id isEqualToString:aMetro.metro_id]) return;
  }
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *metroIds = [defaults objectForKey:gcRecentMetrosKey];
  NSMutableArray *array = [[NSMutableArray alloc] initWithArray:metroIds];
  [array addObject:metro.metro_id];
  [defaults setObject:array forKey:gcRecentMetrosKey];
  [defaults synchronize];
  [array release];
  [recents addObject:metro];
  [self sortRecents];
}

- (void)deleteRecent:(GCMetro *)metro {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *metroIds = [defaults objectForKey:gcRecentMetrosKey];
  NSMutableArray *array = [[NSMutableArray alloc] initWithArray:metroIds];
  [array removeObject:metro.metro_id];
  [defaults setObject:array forKey:gcRecentMetrosKey];
  [defaults synchronize];
  [array release];
  [recents removeObject:metro];
}


	
-(void)dealloc
{
  [recents release];
	self.metros = nil;
	self.currentMetro = nil;
	[super dealloc];
}

@end
