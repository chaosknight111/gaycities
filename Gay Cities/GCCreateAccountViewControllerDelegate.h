//
//  GCCreateAccountViewControllerDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 3/19/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCCreateAccountViewController;

@protocol GCCreateAccountViewControllerDelegate

@required
- (void)willCloseCompletedCreateAccountViewController:(GCCreateAccountViewController *)createAccountViewController;
@optional
- (void)willCancelCreateAccountViewController:(GCCreateAccountViewController *)createAccountViewController;

@end
