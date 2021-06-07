//
//  GCGeneralTextCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/24/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCGeneralTextCell.h"


@implementation GCGeneralTextCell

@synthesize cellLabel;




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	self.cellLabel = nil;
    [super dealloc];
}


@end
