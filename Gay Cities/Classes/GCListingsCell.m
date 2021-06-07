//
//  OCBrowseCell.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/14/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import "GCListingsCell.h"


@implementation GCListingsCell

@synthesize listingName, listingOneLiner, listingAddress, star, distance, disclosureImageView;

/*- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier

{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		[super setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}*/


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[listingName release], listingName = nil;
	[listingOneLiner release], listingOneLiner = nil;
	[listingAddress release], listingAddress = nil;
	[star release], star = nil;
	[distance release], distance = nil;
	self.disclosureImageView = nil;
    [super dealloc];
}

-(void)setStars:(float)stars
{	
	NSString *zero, *half, *one, *onehalf, *two, *twohalf, *three, *threehalf, *four, *fourhalf, *five;
	NSString *bundlePath;
	bundlePath = [[NSString alloc] initWithString:[[NSBundle mainBundle] bundlePath]];	
	zero = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"0.png"]];
	half = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"half.png"]];
	one = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"1.png"]];
	onehalf = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"1half.png"]];
	two = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"2.png"]];
	twohalf = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"2half.png"]];
	three = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"3.png"]];
	threehalf = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"3half.png"]];
	four = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"4.png"]];
	fourhalf = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"4half.png"]];
	five = [[NSString alloc]initWithString:[bundlePath stringByAppendingPathComponent:@"5.png"]];
	
	
	if (stars < .49) {
		[star setImage:[UIImage imageWithContentsOfFile:zero]];
	}
	else if (stars >= .49 && stars < 1) {
		[star setImage:[UIImage imageWithContentsOfFile:half]];
	}
	else if (stars >= 1 && stars <= 1.49) {

		[star setImage:[UIImage imageWithContentsOfFile:one]];
	}
	else if (stars > 1.49 && stars < 2) {
		[star setImage:[UIImage imageWithContentsOfFile:onehalf]];
	}
	else if (stars >= 2 && stars <= 2.49) {
		[star setImage:[UIImage imageWithContentsOfFile:two]];
	}
	else if (stars > 2.49 && stars < 3) {
		[star setImage:[UIImage imageWithContentsOfFile:twohalf]];
	}
	else if (stars >= 3 && stars <= 3.49) {
		[star setImage:[UIImage imageWithContentsOfFile:three]];
	}
	else if (stars >3.49 && stars < 4) {
		[star setImage:[UIImage imageWithContentsOfFile:threehalf]];
	}
	else if (stars >= 4 && stars <= 4.49) {
		[star setImage:[UIImage imageWithContentsOfFile:four]];
	}
	else if (stars > 4.49 && stars < 4.9) {
		[star setImage:[UIImage imageWithContentsOfFile:fourhalf]];
	}
	else if (stars >= 4.9) {
		[star setImage:[UIImage imageWithContentsOfFile:five]];
	}
	[bundlePath release];
	[zero release];
	[half release];
	[one release];
	[onehalf release];
	[two release];
	[twohalf release];
	[three release];
	[threehalf release];
	[four release];
	[fourhalf release];
	[five release];
	
}

-(void)setNoStars
{
	[star setImage:nil];

}



@end
