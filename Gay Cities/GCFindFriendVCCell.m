//
//  GCFindFriendVCCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 10/1/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import "GCFindFriendVCCell.h"


@implementation GCFindFriendVCCell

@synthesize imageView, textLabel, twitterButton, fbButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	self.imageView = nil;
	self.textLabel = nil;
	self.twitterButton = nil;
	self.fbButton = nil;
	
    [super dealloc];
}


@end
