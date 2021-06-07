//
//  GCMyList.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/2/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCMyList.h"
#import "OCFMDatabase.h"
#import "OCFMResultSet.h"
#import "OCConstants.h"
#import "GCCommunicator.h"

@implementation GCMyList

@synthesize bookmarks, recents;

- (id)init
{
	self = [super init];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *savePath = [paths objectAtIndex:0];
	
	dbPath = [[NSString alloc] initWithString:[savePath stringByAppendingPathComponent:@"gc.db"]];
	
	bookmarks = [[NSMutableArray alloc] init];
	recents = [[NSMutableArray alloc] init];
	
	
	
	return self;
}

- (void)loadBookmarks
{
	[bookmarks removeAllObjects];
	[recents removeAllObjects];
	
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	OCFMResultSet *rs = [db executeQuery:@"select * from details indexed by detailIndex, tblRecents where tblRecents.listing_id = details.listing_id and tblRecents.type = details.type order by tblRecents.orderNum asc"];
//	NSLog(@"select recents error: %@", [db lastErrorMessage]);
	
	while ([rs next]) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [rs stringForColumn:@"city"], @"city", 
									 [rs stringForColumn:@"hood"], @"hood",
									 [rs stringForColumn:@"lat"], @"lat",
									 [rs stringForColumn:@"lng"], @"lng",
									 [rs stringForColumn:@"listing_id"], @"listing_id",
									 [rs stringForColumn:@"name"], @"name",
									 [rs stringForColumn:@"one_liner"], @"one_liner",
									 [rs stringForColumn:@"overall_rating"], @"rating",
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
		listing.stars = [OCConstants starsForRating:[listing.rating floatValue]];
		[recents addObject:listing];
		[listing release];
		[dict release];
	}
	
	[rs close];
	
	rs = [db executeQuery:@"select * from details indexed by detailIndex, tblBookmarks where  tblBookmarks.listing_id = details.listing_id and tblBookmarks.type = details.type order by tblBookmarks.orderNum asc"];
//	NSLog(@"select bookmarks error: %@", [db lastErrorMessage]);
	
	while ([rs next]) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [rs stringForColumn:@"city"], @"city", 
									 [rs stringForColumn:@"hood"], @"hood",
									 [rs stringForColumn:@"lat"], @"lat",
									 [rs stringForColumn:@"lng"], @"lng",
									 [rs stringForColumn:@"listing_id"], @"listing_id",
									 [rs stringForColumn:@"name"], @"name",
									 [rs stringForColumn:@"one_liner"], @"one_liner",
									 [rs stringForColumn:@"overall_rating"], @"rating",
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
		listing.stars = [OCConstants starsForRating:[listing.rating floatValue]];
		[bookmarks addObject:listing];
		[listing release];
		[dict release];
	}
	
	[rs close];
	[db close];
}

- (void)addRecent:(GCListing *)listing
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	OCFMResultSet *rs = [db executeQuery:@"select listing_id from tblRecentsindexed by recentIndex where listing_id = ? and type = ?", listing.listing_id, listing.type];
	
	if (![rs next]) {
		if ([db executeUpdate:@"insert into tblRecents (listing_id, type, orderNum) values (?, ?, ?)", listing.listing_id, listing.type, [NSNumber numberWithInt: [recents count]]]) {
//			NSLog(@"tblRecents updated");
			
		} else {
			NSLog(@"tblRecents update Failed: %@", [db lastErrorMessage]);
		}
	}
	[rs close];
	
	[db close];
	
	[recents addObject:listing];

}

- (BOOL)addBookmark:(GCListing *)listing
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	if ([db executeUpdate:@"insert into tblBookmarks (listing_id, type, orderNum) values (?, ?, ?)", listing.listing_id, listing.type, [NSNumber numberWithInt: [bookmarks count]]]) {
//		NSLog(@"tblBookmarks updated");
		
	} else {
		NSLog(@"tblBookmarks update Failed: %@", [db lastErrorMessage]);
		[db close];
		return NO;
	}
	
	[db close];
	[bookmarks addObject:listing];

	return YES;
}

- (void)deleteRecent:(NSString *)listing_id withType:(NSString *)type andOrderNum:(int)orderNum
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	int foundOrderNum = orderNum;
	
	if (foundOrderNum < 0) {
		OCFMResultSet *rs = [db executeQuery:@"select orderNum from tblRecents indexed by recentIndex where listing_id = ? and type = ?", listing_id, type];
		
		[rs next];
		
		foundOrderNum = [rs intForColumn:@"orderNum"];
		
		[rs close];
		
	}
//	NSLog(@"row: %i", foundOrderNum);

	if ([db executeUpdate:@"delete from tblRecents indexed by recentIndex where listing_id = ? and type = ?", listing_id, type]) {
//		NSLog(@"tblRecents updated");
		
	} else {
		NSLog(@"tblRecents update Failed: %@", [db lastErrorMessage]);
	}
	
	if ([db executeUpdate:@"update tblRecents indexed by recentOrderIndex set orderNum = (orderNum - 1) where orderNum > ?", [NSNumber numberWithInt: foundOrderNum]]) {
//		NSLog(@"tblRecents order updated");
		
	} else {
		NSLog(@"tblRecents order update Failed: %@", [db lastErrorMessage]);
	}
	
	[db close];
	
	[recents removeObjectAtIndex:foundOrderNum];
	
}

- (void)deleteBookmark:(NSString *)listing_id withType:(NSString *)type andOrderNum:(int)orderNum
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	int foundOrderNum = orderNum;
	
	if (foundOrderNum < 0) {
		OCFMResultSet *rs = [db executeQuery:@"select orderNum from tblBookmarks indexed by bookmarkIndex where listing_id = ? and type = ?", listing_id, type];
		
		[rs next];
		
		foundOrderNum = [rs intForColumn:@"orderNum"];
		
		[rs close];
		
	}
	

	if ([db executeUpdate:@"delete from tblBookmarks indexed by bookmarkIndex where listing_id = ? and type = ?", listing_id, type]) {
		
	} else {
		NSLog(@"tblBookmarks update Failed: %@", [db lastErrorMessage]);

	}
	
	if ([db executeUpdate:@"update tblBookmarks indexed by bookmarkOrderIndex set orderNum = (orderNum - 1) where orderNum > ?", [NSNumber numberWithInt: foundOrderNum]]) {
		
	} else {
		NSLog(@"tblBookmarks order update Failed: %@", [db lastErrorMessage]);
	}
	
	[db close];
	
	[bookmarks removeObjectAtIndex:foundOrderNum];
	
}

- (BOOL)deleteBookmark:(NSString *)listing_id withType:(NSString *)type
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	
	
	OCFMResultSet *rs = [db executeQuery:@"select orderNum from tblBookmarks indexed by bookmarkIndex where listing_id = ? and type = ?", listing_id, type];
	
	[rs next];
	
	int foundOrderNum = [rs intForColumn:@"orderNum"];
	
	[rs close];
		
	
	if ([db executeUpdate:@"delete from tblBookmarks indexed by bookmarkIndex where listing_id = ? and type = ?", listing_id, type]) {
		
	} else {
		NSLog(@"tblBookmarks update Failed: %@", [db lastErrorMessage]);
		[db close];
		return NO;
	}
	
	if ([db executeUpdate:@"update tblBookmarks indexed by bookmarkOrderIndex set orderNum = (orderNum - 1) where orderNum > ?", [NSNumber numberWithInt: foundOrderNum]]) {
		
	} else {
		NSLog(@"tblBookmarks order update Failed: %@", [db lastErrorMessage]);
	}
	
	[db close];
	
	[bookmarks removeObjectAtIndex:foundOrderNum];
	return YES;
	
}

- (void)moveBookmarkFrom:(int)fromRow to:(int)toRow
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	NSLog(@"from: %i to:%i", fromRow, toRow);
	
	if (fromRow > toRow) {
		if ([db executeUpdate:@"update tblBookmarks indexed by bookmarkOrderIndex set orderNum = -1 where orderNum = ?", [NSNumber numberWithInt: fromRow]]) {
			
		} else {
			NSLog(@"tblBookmarks order update Failed: %@", [db lastErrorMessage]);
		}
		
		if ([db executeUpdate:@"update tblBookmarks indexed by bookmarkOrderIndex set orderNum = (orderNum + 1) where orderNum < ? and orderNum >= ?", [NSNumber numberWithInt: fromRow], [NSNumber numberWithInt: toRow]]) {
			
		} else {
			NSLog(@"tblBookmarks order update Failed: %@", [db lastErrorMessage]);
		}
		
		if ([db executeUpdate:@"update tblBookmarks indexed by bookmarkOrderIndex set orderNum = ? where orderNum = -1", [NSNumber numberWithInt: toRow]]) {
			
		} else {
			NSLog(@"tblBookmarks order update Failed: %@", [db lastErrorMessage]);
		}
	} else {
		if ([db executeUpdate:@"update tblBookmarks indexed by bookmarkOrderIndex set orderNum = -1 where orderNum = ?", [NSNumber numberWithInt: fromRow]]) {
			
		} else {
			NSLog(@"tblBookmarks order update Failed: %@", [db lastErrorMessage]);
		}
		
		if ([db executeUpdate:@"update tblBookmarks indexed by bookmarkOrderIndex set orderNum = (orderNum - 1) where orderNum > ? and orderNum <= ?", [NSNumber numberWithInt: fromRow], [NSNumber numberWithInt: toRow]]) {
			
		} else {
			NSLog(@"tblBookmarks order update Failed: %@", [db lastErrorMessage]);
		}
		
		if ([db executeUpdate:@"update tblBookmarks indexed by bookmarkOrderIndex set orderNum = ? where orderNum = -1", [NSNumber numberWithInt: toRow]]) {
			
		} else {
			NSLog(@"tblBookmarks order update Failed: %@", [db lastErrorMessage]);
		}
	}
	
	[db close];
	
	GCListing *listing = [[bookmarks objectAtIndex:fromRow] retain];
	[bookmarks removeObjectAtIndex:fromRow];
	[bookmarks insertObject:listing atIndex:toRow];
	[listing release];
	
}

- (void)moveRecentFrom:(int)fromRow to:(int)toRow
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	NSLog(@"from: %i to:%i", fromRow, toRow);
	
	if (fromRow > toRow) {
		if ([db executeUpdate:@"update tblRecents indexed by recentOrderIndex set orderNum = -1 where orderNum = ?", [NSNumber numberWithInt: fromRow]]) {
			
		} else {
			NSLog(@"tblRecents order update Failed: %@", [db lastErrorMessage]);
		}
		
		if ([db executeUpdate:@"update tblRecents indexed by recentOrderIndex set orderNum = (orderNum + 1) where orderNum < ? and orderNum >= ?", [NSNumber numberWithInt: fromRow], [NSNumber numberWithInt: toRow]]) {
			
		} else {
			NSLog(@"tblRecents order update Failed: %@", [db lastErrorMessage]);
		}
		
		if ([db executeUpdate:@"update tblRecents indexed by recentOrderIndex set orderNum = ? where orderNum = -1", [NSNumber numberWithInt: toRow]]) {
			
		} else {
			NSLog(@"tblRecents order update Failed: %@", [db lastErrorMessage]);
		}
	} else {
		if ([db executeUpdate:@"update tblRecents indexed by recentOrderIndex set orderNum = -1 where orderNum = ?", [NSNumber numberWithInt: fromRow]]) {
			
		} else {
			NSLog(@"tblRecents order update Failed: %@", [db lastErrorMessage]);
		}
		
		if ([db executeUpdate:@"update tblRecents indexed by recentOrderIndex set orderNum = (orderNum - 1) where orderNum > ? and orderNum <= ?", [NSNumber numberWithInt: fromRow], [NSNumber numberWithInt: toRow]]) {
			
		} else {
			NSLog(@"tblRecents order update Failed: %@", [db lastErrorMessage]);
		}
		
		if ([db executeUpdate:@"update tblRecents indexed by recentOrderIndex set orderNum = ? where orderNum = -1", [NSNumber numberWithInt: toRow]]) {
			
		} else {
			NSLog(@"tblRecents order update Failed: %@", [db lastErrorMessage]);
		}
	}
	
	[db close];
	
	GCListing *listing = [[recents objectAtIndex:fromRow] retain];
	[recents removeObjectAtIndex:fromRow];
	[recents insertObject:listing atIndex:toRow];
	[listing release];
}

- (void)deleteAllBookmarks
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	if ([db executeUpdate:@"delete from tblBookmarks"]) {
		
	} else {
		NSLog(@"tblBookmarks delete Failed: %@", [db lastErrorMessage]);
	}
	
	[db close];
	
	[bookmarks removeAllObjects];
	
}

- (void)deleteAllRecents
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	if ([db executeUpdate:@"delete from tblRecents"]) {
		
	} else {
		NSLog(@"tblRecents delete Failed: %@", [db lastErrorMessage]);
	}
	
	[db close];
	
	[recents removeAllObjects];
	
}

- (BOOL)addRecentAndCheckBookmark:(GCListing *)listing
{
	OCFMDatabase *db = [OCFMDatabase databaseWithPath:dbPath];
	
	[db open];
	
	OCFMResultSet *rs = [db executeQuery:@"select listing_id, type from tblRecents indexed by recentIndex where listing_id = ? and type = ?", listing.listing_id, listing.type];

	if (![rs next]) {
		if ([db executeUpdate:@"insert into tblRecents (listing_id, type, orderNum) values (?, ?, ?)", listing.listing_id, listing.type, [NSNumber numberWithInt: [recents count]]]) {
			[recents addObject:listing];
			
		} else {
			NSLog(@"tblRecents update Failed: %@", [db lastErrorMessage]);
		}
	} else {
		NSLog(@"Recent Exists");
	}
	[rs close];
	
	rs = [db executeQuery:@"select listing_id, type from tblBookmarks indexed by bookmarkIndex where listing_id = ? and type = ?", listing.listing_id, listing.type];
	

	if ([rs next]) {
		[rs close];
		[db close];
		[NSThread detachNewThreadSelector:@selector(saveListingToDatabase:) toTarget:[[GCCommunicator sharedCommunicator] listings] withObject:listing];

		return YES;
	} else {
		[rs close];
		[db close];
		[NSThread detachNewThreadSelector:@selector(saveListingToDatabase:) toTarget:[[GCCommunicator sharedCommunicator] listings] withObject:listing];

		return NO;
	}

}

- (void)dealloc 
{
	self.recents = nil;
	self.bookmarks = nil;
	[dbPath release];
	dbPath = nil;
	[super dealloc];
}

@end
