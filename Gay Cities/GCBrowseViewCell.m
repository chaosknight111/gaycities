//
//  GCBrowseViewCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/8/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCBrowseViewCell.h"


@implementation GCBrowseViewCell

@synthesize typeImage, typeName, someIdentifierWord;

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
	self.typeName = nil;
	self.typeImage = nil;
	self.someIdentifierWord = nil;
    [super dealloc];
}


@end
