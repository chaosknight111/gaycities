//
//  GCAlertTableWithChoiceView.h
//  Gay Cities
//
//  Created by Brian Harmann on 2/7/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCAlertTableWithChoiceViewDelegate.h"

@interface GCAlertTableWithChoiceView : UIViewController {
	NSArray *choices;
	int selectedRow;
	NSObject<GCAlertTableWithChoiceViewDelegate> *gcDelegate;
	UITableView *mainTable;
}

@property (nonatomic, retain) NSArray *choices;
@property (readwrite) int selectedRow;
@property (nonatomic, assign) NSObject<GCAlertTableWithChoiceViewDelegate> *gcDelegate;
@property (nonatomic, retain) IBOutlet UITableView *mainTable;

@end
