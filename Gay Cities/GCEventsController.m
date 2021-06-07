//
//  GCEventsController.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/5/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "GCEventsController.h"
#import "GCEventGroup.h"
#import "GCEventSummary.h"

@implementation GCEventsController

@synthesize popularEvents, eventGroups;

- (id)init {
  if (self = [super init]) {
    popularEvents = [[NSMutableArray alloc] init];
    eventGroups = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  self.popularEvents = nil;
  self.eventGroups = nil;
  [super dealloc];
}


- (void)addNewEvent:(GCEventSummary *)event {
  NSTimeInterval secondsFromGMT = [[NSTimeZone systemTimeZone] secondsFromGMT];

  NSDate *today = [[NSDate date] dateByAddingTimeInterval:secondsFromGMT];
  unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekCalendarUnit;
  NSDateComponents *comps3 = [[NSCalendar currentCalendar] components:unitFlags fromDate:today];
  NSDateComponents *comps2 = [[NSCalendar currentCalendar] components:unitFlags fromDate:[event startDate]];
  NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:[[NSCalendar currentCalendar] dateFromComponents:comps3]  toDate:[[NSCalendar currentCalendar] dateFromComponents:comps2]  options:0];

  int yearDiff = [comps year];
  int monthDiff = [comps month];
  int dayDiff = [comps day];
  int weekDiff = [comps week];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
       
  NSString *groupTitle = nil;
  if (dayDiff < 0) {
    if (([[event endDate] timeIntervalSinceReferenceDate] > [[event startDate] timeIntervalSinceReferenceDate]) && ([[event endDate] timeIntervalSinceReferenceDate] >= [today timeIntervalSinceReferenceDate])) {
      groupTitle = @"Today";
    } else {
      groupTitle = @"Already Passed";
    }
  } else if (yearDiff == 0) {
    if (monthDiff == 0) {
      if (weekDiff == 0) {
        if (dayDiff == 0) {
          groupTitle = @"Today";
        } else if (dayDiff == 1) {
          groupTitle = @"Tomorrow";
        } else {
          [dateFormatter setDateFormat:@"EEEE"];
          groupTitle = [dateFormatter stringFromDate:[event startDate]];
        }
      } else if (weekDiff == 1) {
          groupTitle = @"Next Week";
      } else {
        groupTitle = [NSString stringWithFormat:@"%i Weeks", weekDiff];
      }
    } else if (monthDiff == 1) {
      groupTitle = @"Next Month";
    } else {
      [dateFormatter setDateFormat:@"MMMM"];
      groupTitle = [dateFormatter stringFromDate:[event startDate]];
    }
  } else if (yearDiff == 1) {
    if (monthDiff == 1) {
      groupTitle = @"Next Month";
    } else {
        [dateFormatter setDateFormat:@"MMMM"];
        groupTitle = [dateFormatter stringFromDate:[event startDate]];
    }
  } else {
    groupTitle = @"Later On";
  }
  
  if (!groupTitle || [groupTitle length] == 0) {
//    NSLog(@"No Group Title?");
    groupTitle = @"Later On";
  }
  //NSLog(@"%@, today: %@, start:%@, %i, %i, %i, %i", groupTitle,today, [event startDate], dayDiff, weekDiff, monthDiff, yearDiff);
  
  BOOL eventAdded = NO;
  for (GCEventGroup *group in eventGroups) {
    if ([groupTitle isEqualToString:group.title]) {
      [group.events addObject:event];
      eventAdded = YES;
      break;
    }
  }
  if (!eventAdded) {
    GCEventGroup *group = [[GCEventGroup alloc] init];
    group.title = groupTitle;
    [group.events addObject:event];
    [eventGroups addObject:group];
    [group release];
  }
  if (event.isPopular) {
    [popularEvents addObject:event];
  }
  
  [dateFormatter release];
}

- (void)removeAllEvents {
  [eventGroups removeAllObjects];
  [popularEvents removeAllObjects];
}

@end


//  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//  [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//  [dateFormatter setLocale:[NSLocale currentLocale]];
//  [dateFormatter setDoesRelativeDateFormatting:YES];
//  
//  NSString *dateString = [dateFormatter stringFromDate:[event startDate]];