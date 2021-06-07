//
//  GCNSStringExtras.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/14/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (GCNSStringExtras) 

+ (NSString *)filterString:(NSString *)aString;
+ (NSString *)stringForCreatedTimeWithDate:(NSDate *)date;
- (NSMutableString *)filteredStringRemovingHTMLEntities;
- (NSMutableString *)filteredStringAddingHTMLEntitiesForAPI;

@end
