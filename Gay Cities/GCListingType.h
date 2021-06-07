//
//  GCListingType.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/30/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GCListingType : NSObject {
	NSString *name;
	BOOL isEnabled;
	NSMutableArray *listings;
	UIImage *pinImage, *typeImage;
}

@property (nonatomic, retain) NSString *name;
@property (readwrite) BOOL isEnabled;
@property (nonatomic, retain) NSMutableArray *listings;
@property (nonatomic, retain) UIImage *pinImage, *typeImage;

@end
