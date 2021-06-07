//
//  GCLoginViewConroller.h
//  Gay Cities
//
//  Created by Brian Harmann on 2/4/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCLoginViewControllerDelegate.h"

@interface GCLoginViewConroller : UIViewController {
	NSString *usernameText, *passwordText, *headerText;
	UITableView *mainTable;
	NSObject<GCLoginViewControllerDelegate> *gcDelegate;
	UITextField *passwordField;
	
}

@property (nonatomic, copy) NSString *usernameText, *passwordText, *headerText;
@property (nonatomic, retain) IBOutlet UITableView *mainTable;
@property (nonatomic, assign) NSObject<GCLoginViewControllerDelegate> *gcDelegate;
@property (nonatomic, retain) UITextField *passwordField;

- (IBAction)cancelLogin;
- (IBAction)saveAndCloseLogin;

@end
