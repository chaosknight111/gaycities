//
//  GCEventDetail.h
//  Gay Cities
//
//  Created by Brian Harmann on 6/23/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCEventDetailCell : UITableViewCell {
	IBOutlet UIImageView *eventImageView;
	IBOutlet UILabel *eventHoursAndDateLabel, *eventLocationLabel, *eventDescriptionLabel;
	IBOutlet UIButton *imageButton;
}

@property (nonatomic, retain) UIImageView *eventImageView;
@property (nonatomic, retain) UILabel *eventHoursAndDateLabel, *eventLocationLabel, *eventDescriptionLabel;
@property (nonatomic, retain) UIButton *imageButton;

@end
