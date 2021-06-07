//
//  OCBrowseCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/14/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCListingsCell : UITableViewCell {
	IBOutlet UILabel *listingName, *listingAddress, *distance;
	IBOutlet UILabel *listingOneLiner;
	IBOutlet UIImageView *star, *disclosureImageView;

}

@property (nonatomic, retain) UILabel *listingName, *listingAddress, *distance;
@property (nonatomic, retain) UILabel *listingOneLiner;
@property (readwrite, retain) UIImageView *star, *disclosureImageView;

-(void)setNoStars;

@end
