//
//  GCEventGroup.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/6/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GCEventGroup : NSObject {
  NSString *title;
  NSMutableArray *events;
  NSUInteger *indexNumber;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSMutableArray *events;
@property (readwrite) NSUInteger *indexNumber;

@end
