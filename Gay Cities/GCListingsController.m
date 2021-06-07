//
//  OCBrowseListings.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/7/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import "GCListingsController.h"
#import "OCFMDatabase.h"
#import "OCFMResultSet.h"
#import "GCListing.h"
#import "GCListingType.h"
#import "GCListingHood.h"
#import "GCListingReview.h"
#import "OCConstants.h"
#import "GCListingTag.h"
#import "GCEventSummary.h"
#import "GCEventsController.h"

int const sortAlphabetical = 0;
int const sortNeighborhood = 1;
int const sortRating = 2;
int const sortDistance = 3;

@implementation GCListingsController

@synthesize sortValue;
@synthesize listingTypes, neighborhoods, listings, listingTags, events,popularListings, closeByCheckinListings, allCloseByCheckinListings, allCloseByCheckinTypes;
@synthesize dbPath;
@synthesize filteredNeighborhoods, filteredListings, filteredTags, allFilteredListings, allFilteredHoods;
@synthesize myList;
@synthesize bookmarksLoaded, closeByCheckinListingsLoaded, cachedCheckinListingsLoaded;
@synthesize eventsController;
@synthesize foursquareIds;
@synthesize directoryPath;

- (NSString *)directoryPath {
  if (!directoryPath) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    directoryPath = [[paths objectAtIndex:0] retain];
  }
  return directoryPath;
  
}

-(id)init {
	if ((self = [super init])) {
    self.eventsController = [[[GCEventsController alloc] init] autorelease];
    listings = [NSMutableArray new];
    events = [NSMutableArray new];
    listingTypes = [NSMutableArray new];
    neighborhoods = [NSMutableArray new]; 
    listingTags = [NSMutableArray new];
    filteredNeighborhoods = [NSMutableArray new];
    filteredListings = [NSMutableArray new];
    filteredTags = [NSMutableArray new];
    allFilteredListings = [NSMutableArray new];
    allFilteredHoods = [NSMutableArray new];
    sortValue = sortAlphabetical;
    myList = [[GCMyList alloc] init];
    dbPath = [[NSString alloc] init];
    bookmarksLoaded = NO;
    popularListings = [[NSMutableArray alloc] init];
    closeByCheckinListings = [[NSMutableArray alloc] init];
    allCloseByCheckinListings = [[NSMutableArray alloc] init];
    allCloseByCheckinTypes = [[NSMutableArray alloc] init];
    closeByCheckinListingsLoaded = NO;
    closeByCheckinListingsAreLoadingNow = NO;
    cachedCheckinListingsLoaded = NO;
    foursquareIds = [[NSMutableSet alloc] init];
  }
	return self;
}

- (id)initWithMetroID:(int)metroID lat:(double)aLat lng:(double)aLng
{
	if (self = [self init]) {
    self.dbPath = [self.directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%imetros32.sqlite", metroID]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    BOOL success = [fileManager fileExistsAtPath:dbPath];  //copy the database to the app for saved data
    if (success) {
//      NSLog(@"listingsdatabase exists in documents");
    } else { // This should only happen when upgrading databases from old versions of the application prior to 3.2
      NSString *oldMetroNamePath = [self.directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%imetros.sqlite", metroID]];

      BOOL success3 = [fileManager fileExistsAtPath:oldMetroNamePath];  //copy the database to the app for saved data

      if (success3) {
//        NSLog(@"OLD listingsdatabase orig exists in documents, copying to new");
        success = [fileManager copyItemAtPath:oldMetroNamePath toPath:dbPath error:&error];
        
        if (success) {
          OCFMDatabase *dbTemp = [OCFMDatabase databaseWithPath:dbPath];
          [dbTemp open];
          
          if ([dbTemp executeUpdate:@"alter table events add column hours text"]) {
//            NSLog(@"events hours added");
          } else {
            NSLog(@"events hours Failed: %@", [dbTemp lastErrorMessage]);
          }
          
          if ([dbTemp executeUpdate:@"alter table events add column photo_url text"]) {
//            NSLog(@"events photo_url added");
          } else {
            NSLog(@"events photo_url Failed: %@", [dbTemp lastErrorMessage]);
          }
          
          if ([dbTemp executeUpdate:@"alter table events add column num_attending text"]) {
//            NSLog(@"events num_attending added");
          } else {
            NSLog(@"events num_attending Failed: %@", [dbTemp lastErrorMessage]);
          }
          
          [dbTemp close];
        } else {
          // There is a standard listing database setup with all the proper columns called listings.sqlite.  this method copies that database and saves it with a name specified by the metroId, that way we have a cache of listings for each metro to load while offline and when the app first opens to make the UI available almost immediately using those cached listings while the updated listings are loaded from the server.
          success = [self copyDefaultListingDBToDocumentsWithPath:dbPath];
        }
          
      } else {
        success = [self copyDefaultListingDBToDocumentsWithPath:dbPath];
      }
    }
    
    if (!success) {
      NSAssert1(0, @"Failed to copy database: %@", [error localizedDescription]);
    }

    OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];

    if (![db open]) {
      NSLog(@"Could not open db.");
      return nil;
    }
    
    NSNumberFormatter *numberFormatter;
    CLLocation *location;
    if (aLat == 0 && aLng == 0) {
      location = nil;
      numberFormatter = nil;
    } else {
      location = [[CLLocation alloc] initWithLatitude:aLat longitude:aLng];
      numberFormatter = [NSNumberFormatter new];
      [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
      [numberFormatter setMaximumFractionDigits:5];
      [numberFormatter setMinimumIntegerDigits:15];
      [numberFormatter setUsesGroupingSeparator:NO];
      closeByCheckinListingsAreLoadingNow = YES;
    }
    
    OCFMResultSet *rs = [db executeQuery:@"select * from listings"];

      while ([rs next]) {

      NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [rs stringForColumn:@"city"], @"city", 
                       [rs stringForColumn:@"hood"], @"hood",
                       [rs stringForColumn:@"lat"], @"lat",
                       [rs stringForColumn:@"lng"], @"lng",
                       [rs stringForColumn:@"listing_id"], @"listing_id",
                       [rs stringForColumn:@"name"], @"name",
                       [rs stringForColumn:@"one_liner"], @"one_liner",
                       [rs stringForColumn:@"rating"], @"rating",
                       [rs stringForColumn:@"state"], @"state",
                       [rs stringForColumn:@"street"], @"street",
                       [rs stringForColumn:@"tags"], @"tags",
                       [rs stringForColumn:@"type"], @"type", 
                     [rs stringForColumn:@"num_reviews"], @"num_reviews",
                     [rs stringForColumn:@"num_fans"], @"num_fans",
                     [rs stringForColumn:@"photo_url"], @"photo_url",
                     [rs stringForColumn:@"website"], @"website",
                     [rs stringForColumn:@"phone"], @"phone",
                     [rs stringForColumn:@"desc_editorial"], @"desc_editorial",
                     [rs stringForColumn:@"cross_street"], @"cross_street",
                     [rs stringForColumn:@"hours"], @"hours",
                     [rs stringForColumn:@"enhanced_listing"], @"enhanced_listing",
                     [rs stringForColumn:@"former_names"], @"former_names",
                     [rs stringForColumn:@"last_verified"], @"last_verified",
                     [rs stringForColumn:@"desc_mgmt"], @"desc_mgmt",
                     [rs stringForColumn:@"username"], @"username",nil];		
      GCListing *listing = [[GCListing alloc] init];
      [listing setValuesForKeysWithDictionary:dict];
      if ([listing.hood length] < 2) {
        listing.hood = @"zzzOther";
      }
      listing.stars = [OCConstants starsForRating:[listing.rating floatValue]];
      [listings addObject:listing];
      if ([listing.tags length] > 0) {
        listing.tagsArray = [listing.tags componentsSeparatedByString:@", "];
        //[tags addObjectsFromArray: listing.tagsArray];
      }
      BOOL typeFound = NO;
      if ([listingTypes count] == 0) {
        GCListingType *listingType = [[GCListingType alloc] init];
        listingType.name = listing.type;
        [listingType.listings addObject:listing];
        listingType.pinImage = [OCConstants imageForType:listing.type];
        listingType.typeImage = [OCConstants typeImageForType:listing.type];
        [listingTypes addObject:listingType];
        listing.listingType = listingType;
        [listingType release];
      } else {
        for (GCListingType *type in listingTypes) {
          if ([type.name isEqualToString:listing.type]) {
            typeFound = YES;
            [type.listings addObject:listing];
            listing.listingType = type;
            break;
          }
        }
        if (!typeFound) {
          GCListingType *listingType = [[GCListingType alloc] init];
          listingType.name = listing.type;
          [listingType.listings addObject:listing];
          listingType.pinImage = [OCConstants imageForType:listing.type];
          listingType.typeImage = [OCConstants typeImageForType:listing.type];
          [listingTypes addObject:listingType];
          listing.listingType = listingType;
          [listingType release];
        }
      }
      if (location) {
        double add_lat = [listing.lat doubleValue], add_lng = [listing.lng doubleValue];
        if (add_lat != 0 && add_lng != 0) {
          CLLocation *listingLocation = [[CLLocation alloc] initWithLatitude:add_lat longitude:add_lng];
          double distance = [location distanceFromLocation:listingLocation];
          [listingLocation release];
          
          if (distance * 0.00062137119 <= kDefaultCheckinDistance) {
            listing.distance = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:distance]];
            [closeByCheckinListings addObject:listing];
          }
        } else {
          listing.distance = @"10000";
        }
        [allCloseByCheckinListings addObject:listing];
        
      }
      
      [listing release];
      [dict release];
      }
      [rs close]; 

    rs = [db executeQuery:@"select * from events"];
    
      while ([rs next]) {
      NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[rs dateForColumn:@"start"], @"start", [rs dateForColumn:@"end"], @"end", [rs stringForColumn:@"event_id"], @"event_id", [rs stringForColumn:@"name"], @"name", [rs stringForColumn:@"hours"], @"hours", [rs stringForColumn:@"photo_url"], @"photo_url", [rs stringForColumn:@"metro_id"], @"metro_id", [rs stringForColumn:@"num_attending"], @"num_attending", nil];
      
      GCEventSummary *eventSummary = [[GCEventSummary alloc] init];
      
      
      eventSummary.event = event;
      eventSummary.startDate = [event objectForKey:@"start"];
      eventSummary.endDate = [event objectForKey:@"end"];
      eventSummary.event_id = [event objectForKey:@"event_id"];
      eventSummary.eventHours = [event objectForKey:@"hours"];
      eventSummary.eventName = [event objectForKey:@"name"];
      eventSummary.numAttending = [event objectForKey:@"num_attending"];
      eventSummary.photo_url = [event objectForKey:@"photo_url"];
      eventSummary.metro_id = [event objectForKey:@"metro_id"];
      eventSummary.isPopular = NO;
        
      [events addObject: eventSummary];
      [self.eventsController addNewEvent:eventSummary];
      [event release];
      [eventSummary release];
    }
    [rs close];

    NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
                    initWithKey:@"name"
                    ascending:YES
                    selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
    [listingTypes sortUsingDescriptors:sortDescriptors];

    [typeName release];
    if (location) {
      NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"distance"
                                    ascending:YES
                                     selector:@selector(localizedCaseInsensitiveCompare:)];
      
      NSArray *descriptors = [NSArray arrayWithObjects:descriptor1, nil];
      [descriptor1 release];
      [closeByCheckinListings sortUsingDescriptors:descriptors];
      [allCloseByCheckinListings sortUsingDescriptors:descriptors];
      [numberFormatter release];
      [location release];
      [allCloseByCheckinTypes setArray:listingTypes];
      closeByCheckinListingsAreLoadingNow = NO;
      cachedCheckinListingsLoaded = YES;

    }
    closeByCheckinListingsLoaded = YES;
    
    NSLog(@"*Listings: %i, types: %i",[listings count], [listingTypes count]);
    [db close];
  }
	
	return self;
}

- (BOOL)copyDefaultListingDBToDocumentsWithPath:(NSString *)newDBPath {
  if (!newDBPath) {
    NSLog(@"no new db path to save default db to...");
    return NO;
  }
  NSString *bundlePath = [[NSString alloc] initWithString:[[NSBundle mainBundle] bundlePath]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
  BOOL success = [fileManager copyItemAtPath:[bundlePath stringByAppendingPathComponent:@"listings.sqlite"] toPath:newDBPath error:&error];
  [bundlePath release];
//  NSLog(@"Default listings database copied in documents");
  if (!success) {
    NSLog(@"failed to copy default listings db: %@", [error localizedDescription]);
  }
  return success;
}

- (BOOL)loadNewMetroID:(int)metroID
{
	if (metroID <= 0) return NO;  // this is when we have default values set, typically on first launch of a newly installed app or often with iPod touches that never connect to the internet, either case, it means we have no defaults set and should return no to force a fetch from the server.
	
	self.dbPath = [self.directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%imetros32.sqlite", metroID]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	
  BOOL success = [fileManager fileExistsAtPath:dbPath];  //copy the database to the app for saved data
	if (success) {
//		NSLog(@"listingsdatabase exists in documents");
	} else {
    NSString *oldMetroNamePath = [self.directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%imetros.sqlite", metroID]];
    
    BOOL success3 = [fileManager fileExistsAtPath:oldMetroNamePath];  //copy the database to the app for saved data
    
		if (success3) {
//      NSLog(@"OLD listingsdatabase orig exists in documents, copying to new");
      success = [fileManager copyItemAtPath:oldMetroNamePath toPath: dbPath error:&error];
      
      if (success) {
        OCFMDatabase *dbTemp = [OCFMDatabase databaseWithPath:dbPath];
        
        [dbTemp open];
        
        if ([dbTemp executeUpdate:@"alter table events add column hours text"]) {
//          NSLog(@"events hours added");
          
        } else {
          NSLog(@"events hours Failed: %@", [dbTemp lastErrorMessage]);
        }
        
        if ([dbTemp executeUpdate:@"alter table events add column photo_url text"]) {
//          NSLog(@"events photo_url added");
          
        } else {
          NSLog(@"events photo_url Failed: %@", [dbTemp lastErrorMessage]);
        }
        
        if ([dbTemp executeUpdate:@"alter table events add column num_attending text"]) {
//          NSLog(@"events num_attending added");
          
        } else {
          NSLog(@"events num_attending Failed: %@", [dbTemp lastErrorMessage]);
        }
        
        [dbTemp close];
      } else {
        success = [self copyDefaultListingDBToDocumentsWithPath:dbPath];
      }
      
    } else {
      success = [self copyDefaultListingDBToDocumentsWithPath:dbPath];
      
    }
    
  }
  
	if (!success) {
		NSAssert1(0, @"Failed to copy database: %@", [error localizedDescription]);
	}
	
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	
	if (![db open]) {
		NSLog(@"Could not open db.");
		[self performSelectorOnMainThread:@selector(replaceListings:) withObject:nil waitUntilDone:YES];
		return NO;
	}
	NSMutableArray *newListings = [[NSMutableArray alloc] init];
	NSMutableArray *newTypes = [[NSMutableArray alloc] init];
	NSMutableArray *newEvents = [[NSMutableArray alloc] init];
	GCEventsController *newEventsController = [[GCEventsController alloc] init];
	

	OCFMResultSet *rs = [db executeQuery:@"select * from listings"];
    while ([rs next]) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [rs stringForColumn:@"city"], @"city", 
									 [rs stringForColumn:@"hood"], @"hood",
									 [rs stringForColumn:@"lat"], @"lat",
									 [rs stringForColumn:@"lng"], @"lng",
									 [rs stringForColumn:@"listing_id"], @"listing_id",
									 [rs stringForColumn:@"name"], @"name",
									 [rs stringForColumn:@"one_liner"], @"one_liner",
									 [rs stringForColumn:@"rating"], @"rating",
									 [rs stringForColumn:@"state"], @"state",
									 [rs stringForColumn:@"street"], @"street",
									 [rs stringForColumn:@"tags"], @"tags",
									 [rs stringForColumn:@"type"], @"type", 
									 [rs stringForColumn:@"num_reviews"], @"num_reviews",
									 [rs stringForColumn:@"num_fans"], @"num_fans",
									 [rs stringForColumn:@"photo_url"], @"photo_url",
									 [rs stringForColumn:@"website"], @"website",
									 [rs stringForColumn:@"phone"], @"phone",
									 [rs stringForColumn:@"desc_editorial"], @"desc_editorial",
									 [rs stringForColumn:@"cross_street"], @"cross_street",
									 [rs stringForColumn:@"hours"], @"hours",
									 [rs stringForColumn:@"enhanced_listing"], @"enhanced_listing",
									 [rs stringForColumn:@"former_names"], @"former_names",
									 [rs stringForColumn:@"last_verified"], @"last_verified",
									 [rs stringForColumn:@"desc_mgmt"], @"desc_mgmt",
									 [rs stringForColumn:@"username"], @"username",nil];
		//NSLog(@"listing dict: %@", dict);
		
		GCListing *listing = [[GCListing alloc] init];
		[listing setValuesForKeysWithDictionary:dict];
		if ([listing.hood length] < 2) {
			listing.hood = @"zzzOther";
		}
		listing.stars = [OCConstants starsForRating:[listing.rating floatValue]];

		[newListings addObject:listing];
		if ([listing.tags length] > 0) {
			listing.tagsArray = [listing.tags componentsSeparatedByString:@", "];
			//[tags addObjectsFromArray: listing.tagsArray];
		}
		BOOL typeFound = NO;
		if ([newTypes count] == 0) {
			GCListingType *listingType = [[GCListingType alloc] init];
			listingType.name = listing.type;
			[listingType.listings addObject:listing];
			listingType.pinImage = [OCConstants imageForType:listing.type];
			listingType.typeImage = [OCConstants typeImageForType:listing.type];
			[newTypes addObject:listingType];
			listing.listingType = listingType;
			[listingType release];
		} else {
			for (GCListingType *type in newTypes) {
				if ([type.name isEqualToString:listing.type]) {
					typeFound = YES;
					[type.listings addObject:listing];
					listing.listingType = type;
					break;
				}
			}
			if (!typeFound) {
				GCListingType *listingType = [[GCListingType alloc] init];
				listingType.name = listing.type;
				[listingType.listings addObject:listing];
				listingType.pinImage = [OCConstants imageForType:listing.type];
				listingType.typeImage = [OCConstants typeImageForType:listing.type];
				[newTypes addObject:listingType];
				listing.listingType = listingType;
				[listingType release];
			}
		}

		
		
		[listing release];
		[dict release];
    }
    [rs close]; 
	
	rs = [db executeQuery:@"select * from events"];
	//NSLog(@"select Listings Error: %@", [db lastErrorMessage]);
	
    while ([rs next]) {
		NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[rs dateForColumn:@"start"], @"start", [rs dateForColumn:@"end"], @"end", [rs stringForColumn:@"event_id"], @"event_id", [rs stringForColumn:@"name"], @"name", [rs stringForColumn:@"hours"], @"hours", [rs stringForColumn:@"photo_url"], @"photo_url", [rs stringForColumn:@"metro_id"], @"metro_id", [rs stringForColumn:@"num_attending"], @"num_attending", nil];
		
		GCEventSummary *eventSummary = [[GCEventSummary alloc] init];
		
		
		eventSummary.event = event;
		eventSummary.startDate = [event objectForKey:@"start"];
		eventSummary.endDate = [event objectForKey:@"end"];
		eventSummary.event_id = [event objectForKey:@"event_id"];
		eventSummary.eventHours = [event objectForKey:@"hours"];
		eventSummary.eventName = [event objectForKey:@"name"];
		eventSummary.numAttending = [event objectForKey:@"num_attending"];
		eventSummary.photo_url = [event objectForKey:@"photo_url"];
		eventSummary.metro_id = [event objectForKey:@"metro_id"];
    eventSummary.isPopular = NO;
    
    [events addObject: eventSummary];
    [newEventsController addNewEvent:eventSummary];
		[event release];
		[eventSummary release];
	}
	[rs close];

	
	NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
								  initWithKey:@"name"
								  ascending:YES
								  selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
	[newTypes sortUsingDescriptors:sortDescriptors];
	
	//NSLog(@"types: %@", listingTypes);
	
  [db close];

	
	[typeName release];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:newListings, @"listings", newTypes, @"types", newEvents, @"events", newEventsController, @"eventsOrganized", nil];
  [newEvents release];
	[newTypes release];
	[newListings release];
  [newEventsController release];
  
  if ([newListings count] == 0) {
    return NO;
  }
  
	[self performSelectorOnMainThread:@selector(replaceListings:) withObject:dict waitUntilDone:YES];
	
	return YES;
}

- (void)replaceListings:(NSDictionary *)newData
{
	if (newData) {
		[events setArray:[newData objectForKey:@"events"]];
		[listings setArray:[newData objectForKey:@"listings"]];
		[listingTypes setArray:[newData objectForKey:@"types"]];
    self.eventsController = [newData objectForKey:@"eventsOrganized"];
		NSLog(@"*Replace Listings: %i, types: %i",[listings count], [listingTypes count]);
	} else {
		[events removeAllObjects];
		[listings removeAllObjects];
		[listingTypes removeAllObjects];
    self.eventsController = [[[GCEventsController alloc] init] autorelease];
	}
	
}



-(void)setNewListings:(NSMutableDictionary *)dict forMetroID:(int)metroID lat:(double)aLat lng:(double)aLng addPopular:(BOOL)addPopular
{
	
  [listings removeAllObjects];
	[events removeAllObjects];
	[listingTypes removeAllObjects];
	[neighborhoods removeAllObjects];


	if (!dict) {
		NSLog(@"No Listings Downloaded");
		return;
	}
	
	NSNumberFormatter *numberFormatter;
	CLLocation *location;
	if (aLat == 0 && aLng == 0) {
		location = nil;
		numberFormatter = nil;
	} else {
		location = [[CLLocation alloc] initWithLatitude:aLat longitude:aLng];
		numberFormatter = [NSNumberFormatter new];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:5];
		[numberFormatter setMinimumIntegerDigits:15];
		[numberFormatter setUsesGroupingSeparator:NO];
		[closeByCheckinListings removeAllObjects];
		[allCloseByCheckinListings removeAllObjects];
		[allCloseByCheckinTypes removeAllObjects];
		closeByCheckinListingsAreLoadingNow = YES;
	}
	
	if (addPopular) {
		[popularListings removeAllObjects];
	}

	self.dbPath = [self.directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%imetros32.sqlite", metroID]];
	

	NSMutableDictionary *tempEvents = [dict objectForKey:@"events_response"];
	NSMutableDictionary *tempListings = [dict objectForKey:@"listings_response"];
	NSMutableArray *newListings = [[NSMutableArray alloc] init];
	NSMutableArray *newPopular = [[NSMutableArray alloc] init];
  if ([dict objectForKey:@"organized_events"]) {  // this is stupid, I have no idea why I've made a new event controller within the communicator to set here, but i'll leave it for now.
    self.eventsController = [dict objectForKey:@"organized_events"];
  } else {
    self.eventsController = [[[GCEventsController alloc] init] autorelease];
  }
  
	if (tempEvents) {
		if ([[tempEvents objectForKey:@"events"] isKindOfClass: [NSMutableArray class]]) {
			[events setArray:[tempEvents objectForKey:@"events"]];
		}
	}
	if (tempListings) {
		if ([[tempListings objectForKey:@"listings"] isKindOfClass: [NSMutableArray class]]) {
			[newListings setArray:[tempListings objectForKey:@"listings"]];
		}
		if (addPopular) {
			if ([[tempListings objectForKey:@"popular"] isKindOfClass: [NSMutableArray class]]) {
				[newPopular setArray:[tempListings objectForKey:@"popular"]];
			}		
		}
	}
	
	for (NSMutableDictionary *dict in newListings) {
		GCListing *listing = [[GCListing alloc] init];
		//NSLog(@"listing: %@", dict);
		//[listing setValuesForKeysWithDictionary:dict];
		listing.city = [dict objectForKey:@"city"] ? [dict objectForKey:@"city"]: @""; 
		listing.hood = [dict objectForKey:@"hood"] ? [dict objectForKey:@"hood"]: @""; 
		listing.lat = [dict objectForKey:@"lat"] ? [dict objectForKey:@"lat"]: @"0"; 
		listing.lng = [dict objectForKey:@"lng"] ? [dict objectForKey:@"lng"]: @"0"; 
		listing.listing_id = [dict objectForKey:@"listing_id"]; 
		listing.name = [dict objectForKey:@"name"] ? [[dict objectForKey:@"name"] filteredStringRemovingHTMLEntities] : @""; 
		listing.one_liner = [dict objectForKey:@"one_liner"] ? [dict objectForKey:@"one_liner"] : @""; 
		//NSLog(@"rating: %@", [dict objectForKey:@"rating"]);
		listing.rating = [dict objectForKey:@"rating"] ? [dict objectForKey:@"rating"]: @"0"; 
		listing.state = [dict objectForKey:@"state"] ? [dict objectForKey:@"state"] : @""; 
		listing.street = [dict objectForKey:@"street"] ? [dict objectForKey:@"street"]: @""; 
		listing.tags = [dict objectForKey:@"tags"] ? [dict objectForKey:@"tags"]: @""; 
		listing.type = [dict objectForKey:@"type"] ? [dict objectForKey:@"type"]: @""; 
		listing.num_reviews = [dict objectForKey:@"num_reviews"] ? [dict objectForKey:@"num_reviews"]: @"0"; 
		listing.num_fans = [dict objectForKey:@"num_fans"] ? [dict objectForKey:@"num_fans"]: @"0"; 
		listing.photo_url = [dict objectForKey:@"photo_url"] ? [dict objectForKey:@"photo_url"]: @""; 
		listing.website = [dict objectForKey:@"website"] ? [dict objectForKey:@"website"]: @""; 
		listing.phone = [dict objectForKey:@"phone"] ? [dict objectForKey:@"phone"]: @""; 
		listing.desc_editorial = [dict objectForKey:@"desc_editorial"] ? [dict objectForKey:@"desc_editorial"]: @""; 
		listing.cross_street = [dict objectForKey:@"cross_street"] ? [dict objectForKey:@"cross_street"]: @""; 
		listing.hours = [dict objectForKey:@"hours"] ? [dict objectForKey:@"hours"]: @""; 
		listing.enhanced_listing = [dict objectForKey:@"enhanced_listing"] ? [dict objectForKey:@"enhanced_listing"]: @""; 
		listing.former_names = [dict objectForKey:@"former_names"] ? [dict objectForKey:@"former_names"]: @""; 
		listing.last_verified = [dict objectForKey:@"last_verified"] ? [dict objectForKey:@"last_verified"]: @""; 
		listing.desc_mgmt = [dict objectForKey:@"desc_mgmt"] ? [dict objectForKey:@"desc_mgmt"]: @""; 
		listing.username = [dict objectForKey:@"username"] ? [dict objectForKey:@"username"]: @""; 
		
		if ([listing.hood length] < 2) {
			listing.hood = @"zzzOther";
		}
    
    if ([dict objectForKey:@"foursquare_ids"]) {
      NSArray *foursquare = [dict objectForKey:@"foursquare_ids"];
      int count = 0;
      for (NSString *fsId in foursquare) {
        if (count == 0) listing.foursquareId = fsId;
        count ++;
        [foursquareIds addObject:fsId];
      }
    }
		listing.stars = [OCConstants starsForRating:[listing.rating floatValue]];
		[listings addObject:listing];
		if ([listing.tags length] > 0) {
			listing.tagsArray = [listing.tags componentsSeparatedByString:@", "];
			//[tags addObjectsFromArray: listing.tagsArray];
		}
		BOOL typeFound = NO;
		if ([listingTypes count] == 0) {
			GCListingType *listingType = [[GCListingType alloc] init];
			listingType.name = listing.type;
			[listingType.listings addObject:listing];
			listingType.pinImage = [OCConstants imageForType:listing.type];
			listingType.typeImage = [OCConstants typeImageForType:listing.type];
			[listingTypes addObject:listingType];
			listing.listingType = listingType;
			[listingType release];
		} else {
			for (GCListingType *type in listingTypes) {
				if ([type.name isEqualToString:listing.type]) {
					typeFound = YES;
					[type.listings addObject:listing];
					listing.listingType = type;
					break;
				}
			}
			if (!typeFound) {
				GCListingType *listingType = [[GCListingType alloc] init];
				listingType.name = listing.type;
				[listingType.listings addObject:listing];
				listingType.pinImage = [OCConstants imageForType:listing.type];
				listingType.typeImage = [OCConstants typeImageForType:listing.type];
				[listingTypes addObject:listingType];
				listing.listingType = listingType;
				[listingType release];
			}
		}

		if (location) {
			double add_lat = [listing.lat doubleValue], add_lng = [listing.lng doubleValue];
			if (add_lat != 0 && add_lng != 0) {
				CLLocation *listingLocation = [[CLLocation alloc] initWithLatitude:add_lat longitude:add_lng];
				double distance = [location distanceFromLocation:listingLocation];
				[listingLocation release];
				
				if (distance * 0.00062137119 <= kDefaultCheckinDistance) {
					listing.distance = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:distance]];
					[closeByCheckinListings addObject:listing];
					for (NSMutableDictionary *aPopular in newPopular) {
						if ([[aPopular objectForKey:@"listing_id"] isEqualToString:listing.listing_id] && [[aPopular objectForKey:@"type"] isEqualToString:listing.type]) {
							[popularListings addObject:listing];
							break;
						}
					}
				}
			} else {
				listing.distance = @"10000";
			}
			[allCloseByCheckinListings addObject:listing];

		}
		
		[listing release];
	}
	NSMutableArray *saveListings = [[NSMutableArray alloc] initWithArray:listings];
	NSMutableArray *saveEvents = [[NSMutableArray alloc] initWithArray:events];
	//NSLog(@"New Events: %@", saveEvents);
	NSString *saveDBPath = [[NSString alloc] initWithString:dbPath];
	NSDictionary *aDict = [[NSDictionary alloc] initWithObjectsAndKeys:saveListings, @"listings",saveEvents, @"events", saveDBPath, @"dbPath",[NSString stringWithFormat:@"%i", metroID], @"metroID", nil];
	[NSThread detachNewThreadSelector:@selector(saveNewListingsToDatabase:) toTarget:self withObject:aDict];
	[saveListings release];
	[saveEvents release];
	[saveDBPath release];
	[aDict release];
	

	BOOL typesFiltered = NO;
	if (tempListings) {
		if ([[tempListings objectForKey:@"available_types"] isKindOfClass: [NSMutableArray class]]) {
			NSMutableArray *newTypes = [tempListings objectForKey:@"available_types"];
			if (newTypes) {
				if ([newTypes count] == [listingTypes count]) {
					NSMutableArray *tempListingTypes = [[NSMutableArray alloc] init];
					for (NSString *type in newTypes) {
						for (GCListingType *savedType in listingTypes) {
							if ([type isEqualToString:savedType.name]) {
								[tempListingTypes addObject: savedType];
								break;
							}
						}
					}
					if ([tempListingTypes count] == [listingTypes count]) {
						[listingTypes setArray:tempListingTypes];
						typesFiltered = YES;
					}
					[tempListingTypes release];
				}
			}
		}
	}
	
	if (!typesFiltered) {

		NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
									  initWithKey:@"name"
									  ascending:YES
									  selector:@selector(caseInsensitiveCompare:)];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
		[listingTypes sortUsingDescriptors:sortDescriptors];
		[typeName release];
	}

	if (location) {
		NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"distance"
																	ascending:YES
																	 selector:@selector(localizedCaseInsensitiveCompare:)];
		
		NSArray *descriptors = [NSArray arrayWithObjects:descriptor1, nil];
		[descriptor1 release];
		[closeByCheckinListings sortUsingDescriptors:descriptors];
		[allCloseByCheckinListings sortUsingDescriptors:descriptors];
		if ([popularListings count] > 0 && addPopular) {
			[popularListings sortUsingDescriptors:descriptors];
		}
		[numberFormatter release];
		[location release];
		[allCloseByCheckinTypes setArray:listingTypes];
		closeByCheckinListingsAreLoadingNow = NO;
		cachedCheckinListingsLoaded = YES;
	}
	[newListings release];
	[newPopular release];
	closeByCheckinListingsLoaded = YES;
	
	NSLog(@"*Set New Listings: %i, types: %i",[listings count], [listingTypes count]);
}

#if 0
-(void)setNewCheckinListings:(NSMutableDictionary *)dict forMetroID:(int)metroID lat:(double)aLat lng:(double)aLng
{
	if (!dict) {
		NSLog(@"No Checkin Listings Downloaded");
		return;
	}
	
	if (aLat == 0 && aLng == 0) {
		return;
	}

  CLLocation *location = [[CLLocation alloc] initWithLatitude:aLat longitude:aLng];
  NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
  [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
  [numberFormatter setMaximumFractionDigits:5];
  [numberFormatter setMinimumIntegerDigits:15];
  [numberFormatter setUsesGroupingSeparator:NO];
  
  NSMutableArray *newCheckinListings = [[NSMutableArray alloc] init];
  
  [closeByCheckinListings removeAllObjects];
  [allCloseByCheckinListings removeAllObjects];
  [allCloseByCheckinTypes removeAllObjects];
  closeByCheckinListingsAreLoadingNow = YES;
  [popularListings removeAllObjects];
  
	NSString *checkinDBPath = [self.directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%imetros32.sqlite", metroID]];
	
  
	NSMutableDictionary *tempListings = [dict objectForKey:@"listings_response"];
	NSMutableArray *newListings = [[NSMutableArray alloc] init];
	NSMutableArray *newPopular = [[NSMutableArray alloc] init];

  
	if (tempListings) {
		if ([[tempListings objectForKey:@"listings"] isKindOfClass: [NSMutableArray class]]) {
			[newListings setArray:[tempListings objectForKey:@"listings"]];
		}
    
    if ([[tempListings objectForKey:@"popular"] isKindOfClass: [NSMutableArray class]]) {
      [newPopular setArray:[tempListings objectForKey:@"popular"]];
    }		
	}
	
	for (NSMutableDictionary *dict in newListings) {
		GCListing *listing = [[GCListing alloc] init];
		//NSLog(@"listing: %@", dict);
		//[listing setValuesForKeysWithDictionary:dict];
		listing.city = [dict objectForKey:@"city"] ? [dict objectForKey:@"city"]: @""; 
		listing.hood = [dict objectForKey:@"hood"] ? [dict objectForKey:@"hood"]: @""; 
		listing.lat = [dict objectForKey:@"lat"] ? [dict objectForKey:@"lat"]: @"0"; 
		listing.lng = [dict objectForKey:@"lng"] ? [dict objectForKey:@"lng"]: @"0"; 
		listing.listing_id = [dict objectForKey:@"listing_id"]; 
		listing.name = [dict objectForKey:@"name"] ? [[dict objectForKey:@"name"] filteredStringRemovingHTMLEntities] : @""; 
		listing.one_liner = [dict objectForKey:@"one_liner"] ? [dict objectForKey:@"one_liner"] : @""; 
		//NSLog(@"rating: %@", [dict objectForKey:@"rating"]);
		listing.rating = [dict objectForKey:@"rating"] ? [dict objectForKey:@"rating"]: @"0"; 
		listing.state = [dict objectForKey:@"state"] ? [dict objectForKey:@"state"] : @""; 
		listing.street = [dict objectForKey:@"street"] ? [dict objectForKey:@"street"]: @""; 
		listing.tags = [dict objectForKey:@"tags"] ? [dict objectForKey:@"tags"]: @""; 
		listing.type = [dict objectForKey:@"type"] ? [dict objectForKey:@"type"]: @""; 
		listing.num_reviews = [dict objectForKey:@"num_reviews"] ? [dict objectForKey:@"num_reviews"]: @"0"; 
		listing.num_fans = [dict objectForKey:@"num_fans"] ? [dict objectForKey:@"num_fans"]: @"0"; 
		listing.photo_url = [dict objectForKey:@"photo_url"] ? [dict objectForKey:@"photo_url"]: @""; 
		listing.website = [dict objectForKey:@"website"] ? [dict objectForKey:@"website"]: @""; 
		listing.phone = [dict objectForKey:@"phone"] ? [dict objectForKey:@"phone"]: @""; 
		listing.desc_editorial = [dict objectForKey:@"desc_editorial"] ? [dict objectForKey:@"desc_editorial"]: @""; 
		listing.cross_street = [dict objectForKey:@"cross_street"] ? [dict objectForKey:@"cross_street"]: @""; 
		listing.hours = [dict objectForKey:@"hours"] ? [dict objectForKey:@"hours"]: @""; 
		listing.enhanced_listing = [dict objectForKey:@"enhanced_listing"] ? [dict objectForKey:@"enhanced_listing"]: @""; 
		listing.former_names = [dict objectForKey:@"former_names"] ? [dict objectForKey:@"former_names"]: @""; 
		listing.last_verified = [dict objectForKey:@"last_verified"] ? [dict objectForKey:@"last_verified"]: @""; 
		listing.desc_mgmt = [dict objectForKey:@"desc_mgmt"] ? [dict objectForKey:@"desc_mgmt"]: @""; 
		listing.username = [dict objectForKey:@"username"] ? [dict objectForKey:@"username"]: @""; 
		
		if ([listing.hood length] < 2) {
			listing.hood = @"zzzOther";
		}
    
    if ([dict objectForKey:@"foursquare_ids"]) {
      NSArray *foursquare = [dict objectForKey:@"foursquare_ids"];
      int count = 0;
      for (NSString *fsId in foursquare) {
        if (count == 0) listing.foursquareId = fsId;
        count ++;
        [foursquareIds addObject:fsId];
      }
    }
		listing.stars = [OCConstants starsForRating:[listing.rating floatValue]];
		[listings addObject:listing];
		if ([listing.tags length] > 0) {
			listing.tagsArray = [listing.tags componentsSeparatedByString:@", "];
			//[tags addObjectsFromArray: listing.tagsArray];
		}
		BOOL typeFound = NO;
		if ([listingTypes count] == 0) {
			GCListingType *listingType = [[GCListingType alloc] init];
			listingType.name = listing.type;
			[listingType.listings addObject:listing];
			listingType.pinImage = [OCConstants imageForType:listing.type];
			listingType.typeImage = [OCConstants typeImageForType:listing.type];
			[listingTypes addObject:listingType];
			listing.listingType = listingType;
			[listingType release];
		} else {
			for (GCListingType *type in listingTypes) {
				if ([type.name isEqualToString:listing.type]) {
					typeFound = YES;
					[type.listings addObject:listing];
					listing.listingType = type;
					break;
				}
			}
			if (!typeFound) {
				GCListingType *listingType = [[GCListingType alloc] init];
				listingType.name = listing.type;
				[listingType.listings addObject:listing];
				listingType.pinImage = [OCConstants imageForType:listing.type];
				listingType.typeImage = [OCConstants typeImageForType:listing.type];
				[listingTypes addObject:listingType];
				listing.listingType = listingType;
				[listingType release];
			}
		}
    
		if (location) {
			double add_lat = [listing.lat doubleValue], add_lng = [listing.lng doubleValue];
			if (add_lat != 0 && add_lng != 0) {
				CLLocation *listingLocation = [[CLLocation alloc] initWithLatitude:add_lat longitude:add_lng];
				double distance = [location distanceFromLocation:listingLocation];
				[listingLocation release];
				
				if (distance * 0.00062137119 <= kDefaultCheckinDistance) {
					listing.distance = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:distance]];
					[closeByCheckinListings addObject:listing];
					for (NSMutableDictionary *aPopular in newPopular) {
						if ([[aPopular objectForKey:@"listing_id"] isEqualToString:listing.listing_id] && [[aPopular objectForKey:@"type"] isEqualToString:listing.type]) {
							[popularListings addObject:listing];
							break;
						}
					}
				}
			} else {
				listing.distance = @"10000";
			}
			[allCloseByCheckinListings addObject:listing];
      
		}
		
		[listing release];
	}
	NSMutableArray *saveListings = [[NSMutableArray alloc] initWithArray:listings];
	NSMutableArray *saveEvents = [[NSMutableArray alloc] initWithArray:events];
	//NSLog(@"New Events: %@", saveEvents);
	NSString *saveDBPath = [[NSString alloc] initWithString:dbPath];
	NSDictionary *aDict = [[NSDictionary alloc] initWithObjectsAndKeys:saveListings, @"listings",saveEvents, @"events", saveDBPath, @"dbPath",[NSString stringWithFormat:@"%i", metroID], @"metroID", nil];
	[NSThread detachNewThreadSelector:@selector(saveNewListingsToDatabase:) toTarget:self withObject:aDict];
	[saveListings release];
	[saveEvents release];
	[saveDBPath release];
	[aDict release];
	
  
	BOOL typesFiltered = NO;
	if (tempListings) {
		if ([[tempListings objectForKey:@"available_types"] isKindOfClass: [NSMutableArray class]]) {
			NSMutableArray *newTypes = [tempListings objectForKey:@"available_types"];
			if (newTypes) {
				if ([newTypes count] == [listingTypes count]) {
					NSLog(@"Listing Types counts are the same");
					NSMutableArray *tempListingTypes = [[NSMutableArray alloc] init];
					for (NSString *type in newTypes) {
						for (GCListingType *savedType in listingTypes) {
							if ([type isEqualToString:savedType.name]) {
								[tempListingTypes addObject: savedType];
								break;
							}
						}
					}
					if ([tempListingTypes count] == [listingTypes count]) {
						[listingTypes setArray:tempListingTypes];
						typesFiltered = YES;
						NSLog(@"Listing Types Filtered");
					}
					[tempListingTypes release];
				}
			}
		}
	}
	
	if (!typesFiltered) {
		NSLog(@"Listing Types Not Filtered?");
    
		NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
                                  initWithKey:@"name"
                                  ascending:YES
                                  selector:@selector(caseInsensitiveCompare:)];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
		[listingTypes sortUsingDescriptors:sortDescriptors];
		[typeName release];
	}
  
	if (location) {
		NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"distance"
                                                                ascending:YES
                                                                 selector:@selector(localizedCaseInsensitiveCompare:)];
		
		NSArray *descriptors = [NSArray arrayWithObjects:descriptor1, nil];
		[descriptor1 release];
		[closeByCheckinListings sortUsingDescriptors:descriptors];
		[allCloseByCheckinListings sortUsingDescriptors:descriptors];
		if ([popularListings count] > 0 && addPopular) {
			NSLog(@"Populars added and being filtered.");
			[popularListings sortUsingDescriptors:descriptors];
		}
		[numberFormatter release];
		[location release];
		[allCloseByCheckinTypes setArray:listingTypes];
		closeByCheckinListingsAreLoadingNow = NO;
		cachedCheckinListingsLoaded = YES;
	}
	[newListings release];
	[newPopular release];
	closeByCheckinListingsLoaded = YES;
	
	NSLog(@"*Listings: %i, types: %i",[listings count], [listingTypes count]);
}
#endif



- (void)saveNewListingsToDatabase:(NSDictionary *)dict
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
  NSString *aDBPath = [dict objectForKey:@"dbPath"];
  BOOL success = [fileManager fileExistsAtPath:aDBPath];  //copy the database to the app for saved data
	if (success) {
	} else {
    NSString *oldMetroNamePath = [self.directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@metros.sqlite", [dict objectForKey:@"metroID"]]];
    
    BOOL success3 = [fileManager fileExistsAtPath:oldMetroNamePath];  //copy the database to the app for saved data
    
		if (success3) {
      success = [fileManager copyItemAtPath:oldMetroNamePath toPath: aDBPath error:&error];
      
      if (success) {
        OCFMDatabase *dbTemp = [OCFMDatabase databaseWithPath:aDBPath];
        
        [dbTemp open];
        
        if ([dbTemp executeUpdate:@"alter table events add column hours text"]) {
          
        } else {
          NSLog(@"events hours Failed: %@", [dbTemp lastErrorMessage]);
        }
        
        if ([dbTemp executeUpdate:@"alter table events add column photo_url text"]) {
          
        } else {
          NSLog(@"events photo_url Failed: %@", [dbTemp lastErrorMessage]);
        }
        
        if ([dbTemp executeUpdate:@"alter table events add column num_attending text"]) {
          
        } else {
          NSLog(@"events num_attending Failed: %@", [dbTemp lastErrorMessage]);
        }
        
        [dbTemp close];
      } else {
        success = [self copyDefaultListingDBToDocumentsWithPath:aDBPath];
      }
      
    } else {
      success = [self copyDefaultListingDBToDocumentsWithPath:aDBPath];
      
    }
    
  }
  
	if (!success) {
		NSAssert1(0, @"Failed to copy database: %@", [error localizedDescription]);
	}
	
	NSMutableArray *newListings = [dict objectForKey:@"listings"];
	NSMutableArray *newEvents = [dict objectForKey:@"events"];

	OCFMDatabase *db = [OCFMDatabase databaseWithPath:aDBPath];
	
	
	if (![db open]) {
		NSLog(@"Could not open db.");
		return;
	}
	
	if (![db executeUpdate:@"delete from listings"]) {
		NSLog(@"delete Listings Error: %@", [db lastErrorMessage]);
	}
	
	if (![db executeUpdate:@"delete from events"]) {
		NSLog(@"delete events Error: %@", [db lastErrorMessage]);
	}

	[db beginTransaction];
	for (GCListing *listing in newListings) {
		
		
		if (![db executeUpdate:@"insert or ignore into listings (listing_id , type , name  , rating , one_liner , num_reviews , num_fans , photo_url , website , phone , hood , street , city , state , lat , lng , desc_editorial , cross_street , hours, tags, enhanced_listing, former_names, last_verified, desc_mgmt, username) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?, ?, ?)" , 
		 listing.listing_id,
		 listing.type,
		 listing.name,
		 listing.rating,
		 listing.one_liner,
		 listing.num_reviews,
		 listing.num_fans,
		 listing.photo_url,
		 listing.website,
		 listing.phone,
		 listing.hood,
		 listing.street,
		 listing.city,
		 listing.state,
		 listing.lat,
		 listing.lng,
		 listing.desc_editorial,
		 listing.cross_street,
		 listing.hours,
		 listing.tags,
		 listing.enhanced_listing,
		 listing.former_names,
		 listing.last_verified,
		 listing.desc_mgmt,
		 listing.username]) {
//			NSLog(@"Save Listings Error: %@", [db lastErrorMessage]);
		}

	}
	[db commit];
	
	[db beginTransaction];
	for (GCEventSummary *event in newEvents) {
		
		if (![db executeUpdate:@"insert or ignore into events (start , end , event_id  , name, metro_id, num_attending, hours , photo_url) values (?, ?, ?, ?, ?, ?, ?, ?)" , 
          [event startDate], [event endDate], [event event_id], [event eventName], [event metro_id], [event numAttending], [event eventHours], [event photo_url]]) {
			NSLog(@"Save events Error: %@", [db lastErrorMessage]);
		}
		
	}
	[db commit];
	
	//NSLog(@"Save Listings Error: %@", [db lastErrorMessage]);
	[db close];
	
	[aPool release];
}

-(void)loadCheckinListingsFromDatabaseKnowingCurrentMetroID:(NSString *)currentID
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	int metroID = [[defaults valueForKey:gcSavedHomeMetro] intValue];
	
	if (metroID == -1) {
		[aPool release];
		NSLog(@"Load Cached Checkins, metro is -1");
		cachedCheckinListingsLoaded = YES;
		return;
	}
	
	int cid = [currentID intValue];
	
	if (cid == -2 || cid == metroID) {
		[aPool release];
		NSLog(@"Load Cached Checkins, metro == current id or cid = -2");
		cachedCheckinListingsLoaded = YES;
		return;
	}
	
	NSString *checkInPath = [self.directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%imetros32.sqlite", metroID]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	BOOL success = [fileManager fileExistsAtPath:checkInPath];//check for previous listings.
	if (success) {
	} else {
		NSLog(@"No Checkin Database for listings");
		cachedCheckinListingsLoaded = YES;
		[aPool release];
		return;
	}
	
	if (closeByCheckinListingsLoaded || closeByCheckinListingsAreLoadingNow) {
		cachedCheckinListingsLoaded = YES;
		[aPool release];
		return;  // think about this
	}

	OCFMDatabase *db = [OCFMDatabase databaseWithPath:checkInPath];
	
	
	if (![db open]) {
		NSLog(@"Could not open db.");
		cachedCheckinListingsLoaded = YES;
		[aPool release];
		return;
	}
	double aLat = [[defaults valueForKey:gcSavedLatitude] doubleValue];
	double aLng = [[defaults valueForKey:gcSavedLongitude] doubleValue];
	CLLocation *location = [[CLLocation alloc] initWithLatitude:aLat longitude:aLng];
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setMaximumFractionDigits:5];
	[numberFormatter setMinimumIntegerDigits:15];
	[numberFormatter setUsesGroupingSeparator:NO];
	
	NSMutableArray *newTypes = [[NSMutableArray alloc] init];
	NSMutableArray *newClose = [[NSMutableArray alloc] init];
	NSMutableArray *newAll = [[NSMutableArray alloc] init];

	
	
	OCFMResultSet *rs = [db executeQuery:@"select * from listings"];
    while ([rs next]) {
		if (closeByCheckinListingsLoaded || closeByCheckinListingsAreLoadingNow) {
			break;
		}
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [rs stringForColumn:@"city"], @"city", 
									 [rs stringForColumn:@"hood"], @"hood",
									 [rs stringForColumn:@"lat"], @"lat",
									 [rs stringForColumn:@"lng"], @"lng",
									 [rs stringForColumn:@"listing_id"], @"listing_id",
									 [rs stringForColumn:@"name"], @"name",
									 [rs stringForColumn:@"one_liner"], @"one_liner",
									 [rs stringForColumn:@"rating"], @"rating",
									 [rs stringForColumn:@"state"], @"state",
									 [rs stringForColumn:@"street"], @"street",
									 [rs stringForColumn:@"tags"], @"tags",
									 [rs stringForColumn:@"type"], @"type", 
									 [rs stringForColumn:@"num_reviews"], @"num_reviews",
									 [rs stringForColumn:@"num_fans"], @"num_fans",
									 [rs stringForColumn:@"photo_url"], @"photo_url",
									 [rs stringForColumn:@"website"], @"website",
									 [rs stringForColumn:@"phone"], @"phone",
									 [rs stringForColumn:@"desc_editorial"], @"desc_editorial",
									 [rs stringForColumn:@"cross_street"], @"cross_street",
									 [rs stringForColumn:@"hours"], @"hours",
									 [rs stringForColumn:@"enhanced_listing"], @"enhanced_listing",
									 [rs stringForColumn:@"former_names"], @"former_names",
									 [rs stringForColumn:@"last_verified"], @"last_verified",
									 [rs stringForColumn:@"desc_mgmt"], @"desc_mgmt",
									 [rs stringForColumn:@"username"], @"username",nil];
		//NSLog(@"listing dict: %@", dict);
		
		GCListing *listing = [[GCListing alloc] init];
		[listing setValuesForKeysWithDictionary:dict];
		if ([listing.hood length] < 2) {
			listing.hood = @"zzzOther";
		}
		listing.stars = [OCConstants starsForRating:[listing.rating floatValue]];
		if ([listing.tags length] > 0) {
			listing.tagsArray = [listing.tags componentsSeparatedByString:@", "];
			//[tags addObjectsFromArray: listing.tagsArray];
		}
		BOOL typeFound = NO;
		if ([newTypes count] == 0) {
			GCListingType *listingType = [[GCListingType alloc] init];
			listingType.name = listing.type;
			[listingType.listings addObject:listing];
			listingType.pinImage = [OCConstants imageForType:listing.type];
			listingType.typeImage = [OCConstants typeImageForType:listing.type];
			[newTypes addObject:listingType];
			listing.listingType = listingType;
			[listingType release];
		} else {
			for (GCListingType *type in newTypes) {
				if ([type.name isEqualToString:listing.type]) {
					typeFound = YES;
					[type.listings addObject:listing];
					listing.listingType = type;
					break;
				}
			}
			if (!typeFound) {
				GCListingType *listingType = [[GCListingType alloc] init];
				listingType.name = listing.type;
				[listingType.listings addObject:listing];
				listingType.pinImage = [OCConstants imageForType:listing.type];
				listingType.typeImage = [OCConstants typeImageForType:listing.type];
				[newTypes addObject:listingType];
				listing.listingType = listingType;
				[listingType release];
			}
		}
		double add_lat = [listing.lat doubleValue], add_lng = [listing.lng doubleValue];
		if (add_lat != 0 && add_lng != 0) {
			CLLocation *listingLocation = [[CLLocation alloc] initWithLatitude:add_lat longitude:add_lng];
			double distance = [location distanceFromLocation:listingLocation];
			[listingLocation release];
			
			if (distance * 0.00062137119 <= kDefaultCheckinDistance) {
				listing.distance = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:distance]];
				[newClose addObject:listing];
			}
		} else {
			listing.distance = @"10000";
		}
		[newAll addObject:listing];
		
		[listing release];
		[dict release];
    }
    [rs close]; 
	[db close];
	if (closeByCheckinListingsLoaded || closeByCheckinListingsAreLoadingNow) {
		[numberFormatter release];
		[location release];
		[newClose release];
		[newTypes release];
		[newAll release];
		cachedCheckinListingsLoaded = YES;
		[aPool release];
		return;
	}
	
	NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
								  initWithKey:@"name"
								  ascending:YES
								  selector:@selector(caseInsensitiveCompare:)];
	[newTypes sortUsingDescriptors:[NSArray arrayWithObject:typeName]];

	NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"distance"
																ascending:YES
																 selector:@selector(localizedCaseInsensitiveCompare:)];
	
	NSArray *descriptors = [NSArray arrayWithObjects:descriptor1, nil];
	[descriptor1 release];
	[newClose sortUsingDescriptors:descriptors];
	[newAll sortUsingDescriptors:descriptors];

	[numberFormatter release];
	[location release];
	if (!closeByCheckinListingsLoaded || closeByCheckinListingsAreLoadingNow) {
		NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:newClose, @"close", newTypes, @"types", newAll, @"all", nil];
		[self performSelectorOnMainThread:@selector(replaceCheckinListingsWithCachedListings:) withObject:dict waitUntilDone:YES];
		[dict release];

	}
	[newClose release];
	[newTypes release];
	[newAll release];
	[typeName release];
	
	[aPool release];
}

- (void)replaceCheckinListingsWithCachedListings:(NSDictionary *)newCheckins
{
	if ([newCheckins count] == 3) {
		[closeByCheckinListings setArray:[newCheckins objectForKey:@"close"]];
		[allCloseByCheckinTypes setArray:[newCheckins objectForKey:@"types"]];
		[allCloseByCheckinListings setArray:[newCheckins objectForKey:@"all"]];
		//[popularListings removeAllObjects];
		cachedCheckinListingsLoaded = YES;
		closeByCheckinListingsLoaded = YES;
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:gcCheckinListingsLoadedNotification object:nil];
	}

}

- (void)updateCheckinListingsForNewLocation:(CLLocation *)location
{
	if (!location || (location.coordinate.latitude == 0 && location.coordinate.longitude == 0)) {
		NSLog(@"cant update checkins for location, no location");
		return;
	}
	if ([allCloseByCheckinListings count] == 0 || !closeByCheckinListingsLoaded || closeByCheckinListingsAreLoadingNow) {
		NSLog(@"cant update checkins for location, no checkins or they are loading right now...");
		return;
	}
	NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setMaximumFractionDigits:5];
	[numberFormatter setMinimumIntegerDigits:15];
	[numberFormatter setUsesGroupingSeparator:NO];
	NSMutableArray *newClose = [[NSMutableArray alloc] init];
	NSMutableArray *newAll = [[NSMutableArray alloc] initWithArray:allCloseByCheckinListings];
	for (GCListing *listing in newAll) {
		double add_lat = [listing.lat doubleValue], add_lng = [listing.lng doubleValue];
		if (add_lat != 0 && add_lng != 0) {
			CLLocation *listingLocation = [[CLLocation alloc] initWithLatitude:add_lat longitude:add_lng];
			double distance = [location distanceFromLocation:listingLocation];
			[listingLocation release];
			
			if (distance * 0.00062137119 <= kDefaultCheckinDistance) {
				listing.distance = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:distance]];
				[newClose addObject:listing];
			}
		} else {
			listing.distance = @"10000";
		}
	}
	[numberFormatter release];
	NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"distance"
																ascending:YES
																 selector:@selector(localizedCaseInsensitiveCompare:)];
	
	NSArray *descriptors = [NSArray arrayWithObjects:descriptor1, nil];
	[descriptor1 release];
	if (!closeByCheckinListingsLoaded || closeByCheckinListingsAreLoadingNow) {
		NSLog(@"2 - cant update checkins for location, no checkins or they are loading right now...");
		[newAll release];
		[newClose release];
		return;
	}
	[closeByCheckinListings setArray:newClose];
	[newAll release];
	[newClose release];
	[closeByCheckinListings sortUsingDescriptors:descriptors];
	[allCloseByCheckinListings sortUsingDescriptors:descriptors];
	if ([popularListings count] > 0) {
		[popularListings sortUsingDescriptors:descriptors];
	}
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:gcCheckinListingsLoadedNotification object:nil];
	
}

#pragma mark -
#pragma mark Listing Browse Filtering


-(int)numberOfTypes
{
	return [listingTypes count];
}
-(int)numberOfNeighborhoods
{
	return [neighborhoods count];
}
-(int)numberOfTags
{
	return [listingTags count];
}
-(int)numberOfListings
{
	return [listings count];
}

- (void)setAllFilteredListings:(NSMutableArray *)newFilteredListings withLocation:(CLLocation *)location
{
	[allFilteredListings removeAllObjects];
	[allFilteredHoods removeAllObjects];
	[filteredListings removeAllObjects];
	[filteredTags removeAllObjects];
	[filteredNeighborhoods removeAllObjects];
	NSNumberFormatter *numberFormatter;
	if (location) {
		numberFormatter = [NSNumberFormatter new];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:5];
		[numberFormatter setMinimumIntegerDigits:15];
		[numberFormatter setUsesGroupingSeparator:NO];
	}
	
	for (GCListing *aListing in newFilteredListings) {
		GCListing *listing = [[GCListing alloc] init];
		
		listing.stars = aListing.stars;
		listing.city = aListing.city;
		listing.hood = aListing.hood;
		listing.lat = aListing.lat;
		listing.lng = aListing.lng;
		listing.listing_id = aListing.listing_id;
		listing.name = [NSString filterString:aListing.name];
		listing.one_liner = [NSString filterString:aListing.one_liner];
		listing.rating = aListing.rating;
		listing.state = aListing.state;
		listing.street = aListing.street;
		listing.tags = aListing.tags;
		listing.type = aListing.type;
		listing.tagsArray = aListing.tagsArray;
		listing.num_reviews = aListing.num_reviews; 
		listing.num_fans = aListing.num_fans; 
		listing.photo_url = aListing.photo_url; 
		listing.website = aListing.website; 
		listing.phone = aListing.phone; 
		listing.desc_editorial = aListing.desc_editorial; 
		listing.cross_street = aListing.cross_street; 
		listing.hours = aListing.hours; 
		listing.enhanced_listing = aListing.enhanced_listing; 
		listing.former_names = aListing.former_names; 
		listing.last_verified = aListing.last_verified; 
		listing.desc_mgmt = aListing.desc_mgmt; 
		listing.username = aListing.username; 
		
		
		[allFilteredListings addObject:listing];
		[filteredListings addObject:listing];
		
			
		if (location) {
			double add_lat = [listing.lat doubleValue], add_lng = [listing.lng doubleValue];
			if (add_lat == 0 && add_lng == 0) {
				listing.distance = @"10000";
			} else {
				CLLocation *listingLocation = [[CLLocation alloc] initWithLatitude:add_lat longitude:add_lng];
				
				listing.distance = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[location distanceFromLocation:listingLocation]]];
				[listingLocation release];
			}
			
		}
		
		[filteredTags addObjectsFromArray: listing.tagsArray];
		
		BOOL typeFound = NO;
		
		if ([filteredNeighborhoods count] == 0) {
			GCListingHood *hood = [[GCListingHood alloc] init];
			hood.name = listing.hood;
			[hood.listings addObject:listing];
			GCListingHood *aHood = [[GCListingHood alloc] init];
			aHood.name = listing.hood;
			[aHood.listings addObject:listing];
			[filteredNeighborhoods addObject:hood];
			[allFilteredHoods addObject:aHood];
			listing.listingHood = hood;
			[hood release];
			[aHood release];
		} else {
			for (GCListingHood *hood in filteredNeighborhoods) {
				if ([hood.name isEqualToString:listing.hood]) {
					typeFound = YES;
					[hood.listings addObject:listing];
					listing.listingHood = hood;
					for (GCListingHood *aHood in allFilteredHoods) {
						if ([aHood.name isEqualToString:listing.hood]) {
							[aHood.listings addObject:listing];
							break;
						}
					}
					break;
				}
			}
			if (!typeFound) {
				GCListingHood *hood = [[GCListingHood alloc] init];
				hood.name = listing.hood;
				[hood.listings addObject:listing];
				GCListingHood *aHood = [[GCListingHood alloc] init];
				aHood.name = listing.hood;
				[aHood.listings addObject:listing];
				[filteredNeighborhoods addObject:hood];
				[allFilteredHoods addObject:aHood];
				listing.listingHood = hood;
				[hood release];
				[aHood release];
			}
		}
		
		[listing release];
	}
	
	
	if (location) {
		[numberFormatter release];
	}
	
	
	NSSet *tagSet = [NSSet setWithArray:filteredTags];
	[filteredTags removeAllObjects];
	NSMutableArray *tempTags = [[NSMutableArray alloc] init];
	[filteredTags addObjectsFromArray:[[tagSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];

	for (NSString *tag in filteredTags) {
		GCListingTag *newTag = [[GCListingTag alloc] init];
		newTag.name = tag;
		[tempTags addObject:newTag];
		[newTag release];
	}
	[filteredTags setArray:tempTags];
	[tempTags release];
	//NSLog(@"tags: %@", listingTags);
	
	NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
								  initWithKey:@"name"
								  ascending:YES
								  selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
	
	
	[filteredNeighborhoods sortUsingDescriptors:sortDescriptors];
	[allFilteredHoods sortUsingDescriptors:sortDescriptors];
	
	//NSLog(@"hoods: %@", neighborhoods);
	
	
	[typeName release];
	
	NSLog(@"Copied Listings: listings: %i, neighborhoods: %i, tags: %i",[allFilteredListings count], [filteredNeighborhoods count], [filteredTags count]);
}


- (void)setFilteredListingsKeepingTags:(NSMutableArray *)newFilteredListings usingAllTags:(BOOL)usingAllTags
{
	if (!newFilteredListings) {
		NSLog(@"No Filtered Listings, keeping tags?");
		return;
	}
	
	[filteredListings removeAllObjects];
	[filteredListings addObjectsFromArray:newFilteredListings];
	if (!usingAllTags) {
		[self filterListingsForFilteredTags];
	}
	[self setNewFilteredHoods];

}



- (void)filterListingsForFilteredTags
{
	NSMutableSet *tempSet = [[NSMutableSet alloc] init];
	for (GCListing *listing in filteredListings) {
		for (GCListingTag *tag in filteredTags) {
			if (tag.isEnabled) {
				NSRange rr = [listing.tags rangeOfString:tag.name options:NSCaseInsensitiveSearch];
				if (rr.length > 0) {
					[tempSet addObject:listing];
				} else {
					[tempSet removeObject:listing];
					break;
				}

			}
		}
	}

	NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
								  initWithKey:@"name"
								  ascending:YES
								  selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
	[filteredListings setArray: [[tempSet allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
	[tempSet release];
	[typeName release];
}

- (void)setNewFilteredTags:(NSMutableArray *)someListings
{
	NSMutableArray *tags = [NSMutableArray new];
	for (GCListing *listing in someListings) {
		[tags addObjectsFromArray:listing.tagsArray];
	}
	NSSet *tagSet = [NSSet setWithArray:tags];
	[tags release];
	[filteredTags removeAllObjects];
	[filteredTags addObjectsFromArray:[[tagSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
	NSMutableArray *tempTags = [[NSMutableArray alloc] init];
	for (NSString *tag in filteredTags) {
		GCListingTag *newTag = [[GCListingTag alloc] init];
		newTag.name = tag;
		[tempTags addObject:newTag];
		[newTag release];
	}
	[filteredTags setArray:tempTags];
	[tempTags release];
}

- (void)setNewFilteredHoods
{
	[filteredNeighborhoods removeAllObjects];
	for (GCListing *listing in filteredListings) {
		BOOL typeFound = NO;
		if ([filteredNeighborhoods count] == 0) {
			GCListingHood *hood = [[GCListingHood alloc] init];
			hood.name = listing.hood;
			[hood.listings addObject:listing];
			[filteredNeighborhoods addObject:hood];
			listing.listingHood = hood;
			[hood release];
		} else {
			for (GCListingHood *hood in filteredNeighborhoods) {
				if ([hood.name isEqualToString:listing.hood]) {
					typeFound = YES;
					[hood.listings addObject:listing];
					listing.listingHood = hood;
					break;
				}
			}
			if (!typeFound) {
				GCListingHood *hood = [[GCListingHood alloc] init];
				hood.name = listing.hood;
				[hood.listings addObject:listing];
				[filteredNeighborhoods addObject:hood];
				listing.listingHood = hood;
				[hood release];
			}
		}
	}
	NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
								  initWithKey:@"name"
								  ascending:YES
								  selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
	[filteredNeighborhoods setArray: [[self valueForKeyPath: @"filteredListings.@distinctUnionOfObjects.listingHood"] sortedArrayUsingDescriptors:sortDescriptors]];
	
	[typeName release];
}





-(void)filterListingsForKeyword:(NSString *)searchString withListings:(NSMutableArray *)someListings usingAllTags:(BOOL)usingAllTags;
{
	if (!someListings) {
		NSLog(@"No Filtered Listings, Search?");
		return;
	}
	
	[filteredListings removeAllObjects];
	[filteredListings addObjectsFromArray:someListings];
	if (!usingAllTags) {
		[self filterListingsForFilteredTags];
	}
	NSMutableSet *tempSet = [[NSMutableSet alloc] init];
	
	NSArray *keywords = [searchString componentsSeparatedByString:@" "];
	for (GCListing *listing in filteredListings) {
		for (NSString *word in keywords) {
			NSRange rr = [listing.name rangeOfString:word options:NSCaseInsensitiveSearch];
			if (rr.length > 0) {
				[tempSet addObject:listing];
			} else {
				rr = [listing.one_liner rangeOfString:word options:NSCaseInsensitiveSearch];
				if (rr.length > 0) {
					[tempSet addObject:listing];
				} else {
					rr = [listing.type rangeOfString:word options:NSCaseInsensitiveSearch];
					if (rr.length > 0) {
						[tempSet addObject:listing];
					} else {
						rr = [listing.hood rangeOfString:word options:NSCaseInsensitiveSearch];
						if (rr.length > 0) {
							[tempSet addObject:listing];
						} else {
							rr = [listing.tags rangeOfString:word options:NSCaseInsensitiveSearch];
							if (rr.length > 0) {
								[tempSet addObject:listing];
							}
							else {
								[tempSet removeObject:listing];
								break;
							}
						}
					}
				}
			}
		}
	}
	
	NSSortDescriptor *typeName = [[NSSortDescriptor alloc]
								  initWithKey:@"name"
								  ascending:YES
								  selector:@selector(caseInsensitiveCompare:)];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:typeName, nil];
	[filteredListings setArray: [[tempSet allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
	[tempSet release];
	[typeName release];
	[self setNewFilteredHoods];
}



-(void)sortFilteredListingsAlphabetical
{
	NSSortDescriptor *descriptor =
	[[NSSortDescriptor alloc] initWithKey:@"name"
								 ascending:YES
								  selector:@selector(localizedCaseInsensitiveCompare:)];
	
	NSArray *descriptors = [NSArray arrayWithObjects:descriptor, nil];
	[descriptor release];
	
	[filteredListings sortUsingDescriptors:descriptors];
}

-(void)sortFilteredListingsRating
{
	NSSortDescriptor *descriptor1 =
	[[NSSortDescriptor alloc] initWithKey:@"rating"
								 ascending:NO
								  selector:@selector(localizedCaseInsensitiveCompare:)];
	NSSortDescriptor *descriptor2 =
	[[NSSortDescriptor alloc] initWithKey:@"name"
								 ascending:YES
								  selector:@selector(localizedCaseInsensitiveCompare:)];
	
	NSArray *descriptors = [NSArray arrayWithObjects:descriptor1,descriptor2, nil];
	[descriptor1 release];
	[descriptor2 release];
	
	[filteredListings sortUsingDescriptors:descriptors];
}


-(void)sortFilteredListingsDistance
{
	
	
	NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"distance"
								 ascending:YES
								  selector:@selector(localizedCaseInsensitiveCompare:)];
	
	NSArray *descriptors = [NSArray arrayWithObjects:descriptor1, nil];
	[descriptor1 release];
	[filteredListings sortUsingDescriptors:descriptors];
	
}



- (void)loadBookmarks
{
	if (!bookmarksLoaded) {
		[myList loadBookmarks];
		bookmarksLoaded = YES;
	}
}




#pragma mark Details for listings

- (BOOL)loadListingDetails:(GCListing *)listing
{

	
	
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:[self.directoryPath stringByAppendingPathComponent:@"gc.db"]];

	
	if (![db open]) {
		NSLog(@"Could not open db.");
		return NO;
	}
	
	
	
	OCFMResultSet *rs = [db executeQuery:@"select * from details where listing_id = ? and type = ?",listing.listing_id,listing.type];
    
	if ([rs next]) {
		listing.num_reviews = [rs stringForColumn:@"num_reviews"];
		listing.num_fans = [rs stringForColumn:@"num_fans"];
		listing.photo_url = [rs stringForColumn:@"photo_url"];
		listing.website = [rs stringForColumn:@"website"];
		listing.phone = [rs stringForColumn:@"phone"];
		listing.desc_editorial = [rs stringForColumn:@"desc_editorial"];
		listing.cross_street = [rs stringForColumn:@"cross_street"];
		listing.hours = [rs stringForColumn:@"hours"];
		listing.enhanced_listing = [rs stringForColumn:@"enhanced_listing"];
		listing.former_names = [rs stringForColumn:@"former_names"];
		listing.last_verified = [rs stringForColumn:@"last_verified"];

    } else {
		[rs close];
		[db close];
		return NO;
	}

    [rs close];
	
	
	
	
	[db close];

	return YES;
	
}



- (void)saveListingToDatabase:(GCListing *)listing
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:[self.directoryPath stringByAppendingPathComponent:@"gc.db"]];
	
	if (![db open]) {
		NSLog(@"Could not open db.");
		return;
	}
	OCFMResultSet *rs = [db executeQuery:@"select * from details indexed by detailIndex where listing_id = ? and type = ?",listing.listing_id,listing.type];
    if ([rs next]) {
		
	} else {
		if (![db executeUpdate:@"insert into details (listing_id , type , name  , overall_rating , one_liner , num_reviews , num_fans , photo_url , website , phone , hood , street , city , state , lat , lng , desc_editorial , cross_street , hours, tags, enhanced_listing, former_names, last_verified, desc_mgmt, username) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?, ?, ?)" , 
			  listing.listing_id,
			  listing.type,
			  listing.name,
			  listing.rating,
			  listing.one_liner,
			  listing.num_reviews,
			  listing.num_fans,
			  listing.photo_url,
			  listing.website,
			  listing.phone,
			  listing.hood,
			  listing.street,
			  listing.city,
			  listing.state,
			  listing.lat,
			  listing.lng,
			  listing.desc_editorial,
			  listing.cross_street,
			  listing.hours,
			  listing.tags,
			  listing.enhanced_listing,
			  listing.former_names,
			  listing.last_verified,
			  listing.desc_mgmt,
			  listing.username]) {
			NSLog(@"Error insert listing details %@", [db lastErrorMessage]);
			
		}
	}
	
	[rs close];
	[db close];
	

	[aPool release];
	
	
}

- (BOOL)loadListingReviews:(GCListing *)listing
{
	
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:[self.directoryPath stringByAppendingPathComponent:@"gc.db"]];
	
	if (![db open]) {
		NSLog(@"Could not open db.");
		return NO;
	}
	
	[listing.reviews removeAllObjects];
	OCFMResultSet *rs2 = [db executeQuery:@"select * from allReviews indexed by reviewIndex where listing_id = ? and type = ?",listing.listing_id,listing.type];
    if ([rs2 next]) {
		//NSLog(@"openning archived review");
		do {
			GCListingReview *review = [[GCListingReview alloc] init];
			review.r_rating = [rs2 stringForColumn:@"r_rating"];
			review.r_id = [rs2 stringForColumn:@"r_id"];
			review.r_date = [rs2 stringForColumn:@"r_date"];
			review.r_title = [rs2 stringForColumn:@"r_title"];
			review.r_text = [rs2 stringForColumn:@"r_text"];
			review.username = [rs2 stringForColumn:@"username"];
			review.u_age = [rs2 stringForColumn:@"u_age"];
			review.u_gender = [rs2 stringForColumn:@"u_gender"];
			review.u_num_reviews = [rs2 stringForColumn:@"u_num_reviews"];
			review.u_photo = [rs2 stringForColumn:@"u_photo"];
			review.stars = [OCConstants reviewStarsForRating:[review.r_rating floatValue]];
			[listing.reviews addObject:review];
			[review release];
		} while ([rs2 next]);
		
    } else {
		[rs2 close];
		[db close];
		return NO;
	}
    [rs2 close];
	[db close];
	
	return YES;
}



-(void)saveReviewsToDatabase:(GCListing *)listing
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:[self.directoryPath stringByAppendingPathComponent:@"gc.db"]];
	
	if (![db open]) {
		NSLog(@"Could not open db.");
		return;
	}
	
	if (![db executeUpdate:@"delete from allReviews indexed by reviewIndex where listing_id = ? and type = ?",listing.listing_id,listing.type]) {
		NSLog(@"error delete reviews: %@", [db lastErrorMessage]);
	}
	[db beginTransaction];
	for (GCListingReview *review in listing.reviews) {
		//NSLog(@"Saving %@ %@", [reviewIDs objectForKey:@"listing_id"], [reviewIDs objectForKey:@"type"]);
		
		//NSLog(@"%@", review);
		
		if (![db executeUpdate:@"insert or ignore into allReviews (listing_id , type , r_rating  , r_id , r_date , r_title , r_text , username , u_age , u_gender , u_num_reviews , u_photo) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" , 
		 listing.listing_id, 
		 listing.type, 
		 review.r_rating,
		 review.r_id,
		 review.r_date,
		 review.r_title,
		 review.r_text,
		 review.username,
		 review.u_age,
		 review.u_gender,
		 review.u_num_reviews,
		 review.u_photo]) {
			NSLog(@"error writing review: %@", [db lastErrorMessage]);
		}
		 /*
		 ([review objectForKey:@"r_rating"] == nil ? @"0" : [review objectForKey:@"r_rating"]), 
		 ([review objectForKey:@"r_id"] == nil ? @"0" : [review objectForKey:@"r_id"]), 
		 ([review objectForKey:@"r_date"] == nil ? @"-" : [review objectForKey:@"r_date"]), 
		 ([review objectForKey:@"r_title"] == nil ? @"-" : [review objectForKey:@"r_title"]), 
		 ([review objectForKey:@"r_text"] == nil ? @"-" : [review objectForKey:@"r_text"]), 
		 ([review objectForKey:@"username"] == nil ? @"-" : [review objectForKey:@"username"]), 
		 ([review objectForKey:@"u_age"] == nil ? @"0" : [review objectForKey:@"u_age"]), 
		 ([review objectForKey:@"u_gender"] == nil ? @"-" : [review objectForKey:@"u_gender"]), 
		 ([review objectForKey:@"u_num_reviews"] == nil ? @"0" : [review objectForKey:@"u_num_reviews"]), 
		 ([review objectForKey:@"u_photo"] == nil ? @"" : [review objectForKey:@"u_photo"])];*/
		
		
	}
	if (![db commit] ) {
		NSLog(@"error commit review: %@", [db lastErrorMessage]);
	}
	
	if (![db executeUpdate:@"delete from details indexed by detailIndex where listing_id = ? and type = ?",listing.listing_id,listing.type]) {
		NSLog(@"Error delete %@", [db lastErrorMessage]);
	} 
	if (![db executeUpdate:@"insert into details (listing_id , type , name  , overall_rating , one_liner , num_reviews , num_fans , photo_url , website , phone , hood , street , city , state , lat , lng , desc_editorial , cross_street , hours, tags, enhanced_listing, former_names, last_verified, desc_mgmt, username) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?, ?, ?)" , 
		  listing.listing_id,
		  listing.type,
		  listing.name,
		  listing.rating,
		  listing.one_liner,
		  listing.num_reviews,
		  listing.num_fans,
		  listing.photo_url,
		  listing.website,
		  listing.phone,
		  listing.hood,
		  listing.street,
		  listing.city,
		  listing.state,
		  listing.lat,
		  listing.lng,
		  listing.desc_editorial,
		  listing.cross_street,
		  listing.hours,
		  listing.tags,
		  listing.enhanced_listing,
		  listing.former_names,
		  listing.last_verified,
		  listing.desc_mgmt,
		  listing.username]) {
		NSLog(@"Error insert listing details %@", [db lastErrorMessage]);
		
	}
	
	
	[db close];
	[aPool release];
	
}

-(void)dealloc
{
  self.eventsController = nil;
	[directoryPath release];
	[listings release];
	[listingTags release];
	[listingTypes release];
	[neighborhoods release];
	self.events = nil;
	self.filteredNeighborhoods = nil;
	self.filteredListings = nil;
	self.filteredTags = nil;
	self.allFilteredListings = nil;
	self.dbPath = nil;
	self.closeByCheckinListings = nil;
	self.allCloseByCheckinListings = nil;
	self.allCloseByCheckinTypes = nil;
	self.popularListings = nil;
	[super dealloc];
}

@end
