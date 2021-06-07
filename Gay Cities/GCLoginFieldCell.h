//
//  GCLoginFieldCell.h
//  Gay Cities
//
//  Created by Brian Harmann on 2/4/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCLoginFieldCell : UITableViewCell {
	UITextField *textField;
	UILabel *fieldLabel;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UILabel *fieldLabel;

@end
