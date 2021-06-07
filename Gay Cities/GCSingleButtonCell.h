//
//  GCSingleButtonCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 6/15/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCSingleButtonCell : UITableViewCell {
	IBOutlet UIButton *button;
}

@property (nonatomic, retain) UIButton *button;

@end
