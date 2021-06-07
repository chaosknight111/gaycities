//
//  GCSingleButtonCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/15/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCSingleButtonCell.h"


@implementation GCSingleButtonCell
@synthesize button;

/*
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
			// Initialization code
    }
    return self;
}
*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
		// Configure the view for the selected state
}


- (void)dealloc {
	[button release];
    [super dealloc];
}


@end
