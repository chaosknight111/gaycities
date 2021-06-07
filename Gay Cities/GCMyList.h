//
//  GCMyList.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/2/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCListing.h"

@interface GCMyList : NSObject {
	NSMutableArray *bookmarks, *recents;
	NSString *dbPath;
}

@property (nonatomic, retain) NSMutableArray *bookmarks, *recents;

- (void)loadBookmarks;
- (void)addRecent:(GCListing *)listing;
- (BOOL)addBookmark:(GCListing *)listing;
- (void)deleteRecent:(NSString *)listing_id withType:(NSString *)type andOrderNum:(int)orderNum;
- (void)deleteBookmark:(NSString *)listing_id withType:(NSString *)type andOrderNum:(int)orderNum;
- (void)moveRecentFrom:(int)fromRow to:(int)toRow;
- (void)moveBookmarkFrom:(int)fromRow to:(int)toRow;
- (void)deleteAllBookmarks;
- (void)deleteAllRecents;
- (BOOL)addRecentAndCheckBookmark:(GCListing *)listing;
- (BOOL)deleteBookmark:(NSString *)listing_id withType:(NSString *)type;

@end
