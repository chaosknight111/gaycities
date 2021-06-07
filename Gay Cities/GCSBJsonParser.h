//
//  GCSBJsonParser.h
//  Gay Cities
//
//  Created by Brian Harmann on 6/29/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//


// This is a HACK!!!!!!!
// When the initial part of this app was written, I used an old JSON like library that just imported strings of dictionaries.
// When it was replaced with this, it was easier to just copy SBJson and replace the NULL and Number objects with strings
// But this needs to be removed and the codebase updated accordingly.

#import "FBSBJsonBase.h"

@protocol GCSBJsonParser

- (id)objectWithString:(NSString *)repr;

@end

@interface GCSBJsonParser : FBSBJsonBase <GCSBJsonParser> {
  
@private
  const char *c;
}

@end

// don't use - exists for backwards compatibility with 2.1.x only. Will be removed in 2.3.
@interface GCSBJsonParser (Private)
- (id)fragmentWithString:(id)repr;
@end

