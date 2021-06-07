//
//  GCListingDetailCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/15/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCListingDetailCell : UITableViewCell {
	UIImageView *cellImage, *disclosureImage;
	UILabel *cellLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *cellImage, *disclosureImage;
@property (nonatomic, retain) IBOutlet UILabel *cellLabel;

@end
