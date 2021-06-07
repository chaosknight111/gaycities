//
//  GCGeneralTextCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/24/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCGeneralTextCell : UITableViewCell {
	UILabel *cellLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *cellLabel;

@end
