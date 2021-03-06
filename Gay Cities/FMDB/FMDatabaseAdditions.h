//
//  FMDatabaseAdditions.h
//  fmkit
//
//  Created by August Mueller on 10/30/05.
//  Copyright 2005 Flying Meat Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface OCFMDatabase (FMDatabaseAdditions)


- (int) intForQuery:(NSString*)objs, ...;
- (long) longForQuery:(NSString*)objs, ...; 
- (BOOL) boolForQuery:(NSString*)objs, ...;
- (double) doubleForQuery:(NSString*)objs, ...;
- (NSString*) stringForQuery:(NSString*)objs, ...; 
- (NSData*) dataForQuery:(NSString*)objs, ...;

// Notice that there's no dataNoCopyForQuery:.
// That would be a bad idea, because we close out the result set, and then what
// happens to the data that we just didn't copy?  Who knows, not I.

- (id)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
- (BOOL) executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;

@end
