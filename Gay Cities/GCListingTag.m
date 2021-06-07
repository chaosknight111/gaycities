//
//  GCListingTag.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/4/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCListingTag.h"


@implementation GCListingTag

//@synthesize listings;
@synthesize name;
@synthesize isEnabled;

- (id)init
{
	self = [super init];
	
	name = [[NSString alloc] init];
	//listings = [[NSMutableArray alloc] init];
	isEnabled = NO;
	
	return self;
}

- (void)dealloc
{
	self.name = nil;
	//self.listings = nil;
	
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Name:%@", name];
}

@end
