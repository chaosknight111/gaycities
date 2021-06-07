//
//  GCUILabelExtras.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/29/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCUILabelExtras.h"


@implementation UILabel (GCUILabelExtras)


+ (UILabel *)gcLabelForTableHeaderView
{
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
	label.font = [UIFont boldSystemFontOfSize:16];
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	label.textColor = [UIColor colorWithRed:.255 green:.302 blue:.396 alpha:1];
	//label.shadowColor = [UIColor blackColor];
	//label.shadowOffset = CGSizeMake(0, 1);
	label.backgroundColor = [UIColor clearColor];
	return label;
}

+ (UILabel *)gcLabelWhiteForTableHeaderView
{
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
	label.font = [UIFont boldSystemFontOfSize:16];
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	label.textColor = [UIColor colorWithRed:.255 green:.302 blue:.396 alpha:1];
	//label.shadowColor = [UIColor blackColor];
	//label.shadowOffset = CGSizeMake(0, 1);
	label.backgroundColor = [UIColor whiteColor];
	return label;
}

+ (UILabel *)gcLabelClearForTableHeaderView 
{
  UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 25)] autorelease];
	label.font = [UIFont boldSystemFontOfSize:15];
	label.textAlignment = UITextAlignmentLeft;
	label.numberOfLines = 0;
	label.textColor = [UIColor whiteColor];
	//label.shadowColor = [UIColor blackColor];
	//label.shadowOffset = CGSizeMake(0, 1);
	label.backgroundColor = [UIColor clearColor];
	return label;
}



+ (UILabel *)gcLabelBlueForTableHeaderView:(float)height
{
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
	label.font = [UIFont systemFontOfSize:12];
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	label.textColor = [UIColor whiteColor];
	//label.shadowColor = [UIColor blackColor];
	//label.shadowOffset = CGSizeMake(0, 1);
	label.backgroundColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	return label;
}

+ (UILabel *)gcLabelBlueForTableHeaderViewLarger:(float)height
{
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
	label.font = [UIFont boldSystemFontOfSize:15];
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
	label.shadowOffset = CGSizeMake(0, 1);
	label.backgroundColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	return label;
}

@end
