//
//  GCFindFriendVCCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 10/1/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCFindFriendVCCell : UITableViewCell {
	UIImageView *imageView;
	UILabel *textLabel;
	UIButton *twitterButton, *fbButton;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UIButton *twitterButton, *fbButton;

@end
