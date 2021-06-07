//
//  GCLoginFieldCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 2/4/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCLoginFieldCell.h"


@implementation GCLoginFieldCell

@synthesize textField, fieldLabel;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	self.textField = nil;
	self.fieldLabel = nil;
    [super dealloc];
}


@end
