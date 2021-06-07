//
//  GCEventsController.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/5/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCEventSummary;


@interface GCEventsController : NSObject {
  NSMutableArray *eventGroups;
  NSMutableArray *popularEvents;
}

@property (nonatomic, retain) NSMutableArray *eventGroups;
@property (nonatomic, retain) NSMutableArray *popularEvents;

- (void)addNewEvent:(GCEventSummary *)event;
- (void)removeAllEvents;

@end
