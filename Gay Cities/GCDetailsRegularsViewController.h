//
//  GCDetailsRegularsViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/17/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCDetailsRegularsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *mainTableView;
	NSMutableArray *regulars;
	
}

@property (nonatomic, retain) IBOutlet UITableView *mainTableView;
@property (nonatomic, assign) NSMutableArray *regulars;


- (void)openProfilePageForUser:(NSString *)username;



@end
