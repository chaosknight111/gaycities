//
//  GCReviewFanCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/15/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCReviewFanCell.h"


@implementation GCReviewFanCell

@synthesize reviewButton, fanButton, myListButton, checkInButton;

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
	self.reviewButton = nil;
	self.fanButton = nil;
	self.myListButton = nil;
	self.checkInButton = nil;
    [super dealloc];
}


@end
