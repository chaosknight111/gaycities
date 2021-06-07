//
//  GCEventDetail.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/23/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCEventDetailCell.h"


@implementation GCEventDetailCell

@synthesize eventImageView;
@synthesize eventHoursAndDateLabel, eventLocationLabel, eventDescriptionLabel;
@synthesize imageButton;

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
	self.eventImageView = nil;
	self.eventHoursAndDateLabel = nil;
	self.eventLocationLabel = nil;
	self.eventDescriptionLabel = nil;
	self.imageButton = nil;
    [super dealloc];
}


@end
