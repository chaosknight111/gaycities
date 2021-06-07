//
//  GCEventGroup.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/6/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "GCEventGroup.h"


@implementation GCEventGroup

@synthesize title, events, indexNumber;

- (id)init {
  if (self = [super init]) {
    events = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  self.events = nil;
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@, %@", title, events];
}

@end
