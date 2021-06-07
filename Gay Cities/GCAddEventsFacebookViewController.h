//
//  GCAddEventsFacebookViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/22/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GayCitiesAppDelegate, GCConnectController;

@interface GCAddEventsFacebookViewController : UIViewController {
  UILabel *topLabel, *bottomLabel;
  UIButton *fbConnectButton;
	GayCitiesAppDelegate *gcad;
}

@property (nonatomic, retain) IBOutlet UILabel *topLabel, *bottomLabel;
@property (nonatomic, retain) IBOutlet UIButton *fbConnectButton;
@property (nonatomic, assign) GayCitiesAppDelegate *gcad;

- (IBAction)connectWithFacebook:(id)sender;
- (void)closeMe;

@end
