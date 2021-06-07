//
//  OCSearchBar.m
//  Gay Cities
//
//  Created by Brian Harmann on 7/6/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import "OCSearchBar.h"


@implementation OCSearchBar

@synthesize showCancel, ocCancelButton;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		UIImage *image = [UIImage imageNamed:@"searchbarOverlay.png"];
		self.background = [image stretchableImageWithLeftCapWidth:30 topCapHeight:0];
		self.ocCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[ocCancelButton setImage:[UIImage imageNamed:@"filterButtonListingsList.png"] forState:UIControlStateNormal];
		ocCancelButton.frame = CGRectMake(257, 6, 57, 32);
		UIImage *aSearchImage = [UIImage imageNamed:@"findfriendIconName.png"];
		showCancel = YES;
		self.leftViewMode = UITextFieldViewModeAlways;
		UIImageView *iv = [[UIImageView alloc] initWithImage:aSearchImage];
		self.leftView = iv;
		[iv release];
	}
	
	return self;
}

- (void)setShowCancel:(BOOL)show
{
	if (showCancel == show) {
		return;
	}
	showCancel = show;
	
	if (showCancel) {
		[self addSubview:ocCancelButton];
		[self setNeedsDisplay];
	} else {
		[ocCancelButton removeFromSuperview];
		[self setNeedsDisplay];
	}
}

- (CGRect)borderRectForBounds:(CGRect)bounds
{
	[super borderRectForBounds:bounds];
	if (showCancel) {
		CGRect aRect = CGRectMake(6, 6, 245, 30);
		return aRect;
	}
	
	CGRect aRect = CGRectMake(6, 6, 314, 30);
	return aRect;
}

- (void)dealloc
{
	self.ocCancelButton = nil;
	[super dealloc];
}


@end
