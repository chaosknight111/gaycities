//
//  GCListingTag.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/4/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GCListingTag : NSObject {
	NSString *name;
	//NSMutableArray *listings;
	BOOL isEnabled;
}

@property (nonatomic, retain) NSString *name;
//@property (nonatomic, retain) NSMutableArray *listings;
@property (readwrite) BOOL isEnabled;

@end
