//
//  GCReviewFanCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 6/15/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCReviewFanCell : UITableViewCell {
	IBOutlet UIButton *reviewButton, *fanButton, *myListButton, *checkInButton;
}

@property (nonatomic, retain) UIButton *reviewButton, *fanButton, *myListButton, *checkInButton;

@end
