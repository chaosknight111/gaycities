//
//  GCListingType.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/30/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCListingType.h"


@implementation GCListingType

@synthesize name, isEnabled, listings, pinImage, typeImage;

- (id)init
{
	self = [super init];
	name = [[NSString alloc] init];
	isEnabled = YES;
	listings = [[NSMutableArray alloc] init];
	pinImage = [[UIImage alloc] init];
	typeImage = [[UIImage alloc] init];
	return self;
}

- (void)dealloc
{
	self.name = nil;
	self.pinImage = nil;
	self.listings = nil;
	self.typeImage = nil;
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Name:%@\nListings:%@", name, listings];
}

@end
