//
//  NSString+GCSBJSON.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/29/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "NSString+GCSBJSON.h"
#import "GCSBJsonParser.h"


@implementation NSString (GCSBJSON)

- (id)JSONValueWithStrings
{
  GCSBJsonParser *jsonParser = [GCSBJsonParser new];
  id repr = [jsonParser objectWithString:self];
  if (!repr)
    NSLog(@"-JSONValue failed. Error trace is: %@", [jsonParser errorTrace]);
  [jsonParser release];
  return repr;
}

@end
