//
//  GCURLConnection.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/30/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCURLConnection.h"
#import "NSString+UUID.h"
#import <CommonCrypto/CommonDigest.h>



@implementation GCURLConnection

@synthesize data, identifier, requestType;


- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(GCRequestType)newRequestType
{
	
    if (self = [super initWithRequest:request delegate:delegate]) {
        data = [[NSMutableData alloc] initWithCapacity:0];
        self.identifier = [NSString stringWithNewUUID];
        requestType = newRequestType;
    }
    
    return self;
}


- (void)dealloc
{
    self.data = nil;
    self.identifier = nil;
    [super dealloc];
}



#pragma mark Data helper methods


- (void)resetDataLength
{
    [data setLength:0];
}


- (void)appendData:(NSData *)newData
{
    [data appendData:newData];
}






- (NSString *)description
{
    NSString *description = [super description];
    
    return [description stringByAppendingFormat:@" (requestType = %d, identifier = %@)", requestType, identifier];
}


@end
