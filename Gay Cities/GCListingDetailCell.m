//
//  GCListingDetailCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/15/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCListingDetailCell.h"


@implementation GCListingDetailCell

@synthesize cellImage, cellLabel, disclosureImage;


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	self.cellImage = nil;
	self.cellLabel = nil;
	self.disclosureImage = nil;
    [super dealloc];
}


@end
