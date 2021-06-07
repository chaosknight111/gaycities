//
//  GCNSStringExtras.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/14/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCNSStringExtras.h"


@implementation NSString (GCNSStringExtras) 

+ (NSString *)filterString:(NSString *)aString
{
	if (!aString) {
		return @"";
	}
	NSMutableString *tempString = [NSMutableString stringWithString:aString];
	[tempString replaceOccurrencesOfString:@"&#039;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&lt;br&gt;" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&lt;i&gt;" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&lt;/i&gt;" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	

	return tempString;
}

- (NSMutableString *)filteredStringRemovingHTMLEntities
{
	if (!self) {
		return nil;
	}
	NSMutableString *tempString = [NSMutableString stringWithString:self];
	[tempString replaceOccurrencesOfString:@"&#039;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&lt;br&gt;" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&lt;i&gt;" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&lt;/i&gt;" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	
	
	return tempString;
}

- (NSMutableString *)filteredStringAddingHTMLEntitiesForAPI
{
	if (!self) {
		return nil;
	}
	NSString *actionString = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    
	NSMutableString *escaped = [NSMutableString stringWithString:actionString];
	[escaped replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	[escaped replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
	
	
	return escaped;
}

+ (NSString *)stringForCreatedTimeWithDate:(NSDate *)date
{
	double time = ([date timeIntervalSinceNow]  * -1);
	time = time / 60.0;
	
	if (time >= 60.0) {
		time = time/60.0;
		if (time >= 24.0) {
			time = time/24;
			if (time < 2) {
				return@"1 day ago";
			} else {
				return [NSString stringWithFormat:@"%1.0f days ago",time];
			}
		} else {
			if (time < 2) {
				return @"1 hour ago";
			} else {
				return [NSString stringWithFormat:@"%1.0f hours ago",time];
			}				
		}
	} else {
		if (time < 1) {
			return @"Just Now";
		}else if (time < 2) {
			return @"1 minute ago";
		}  else {
			return [NSString stringWithFormat:@"%1.0f minutes ago",time];
		}			
	}
	
	return @"";
}

@end
