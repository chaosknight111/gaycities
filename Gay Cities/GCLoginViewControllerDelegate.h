//
//  GCLoginViewControllerDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 2/4/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCLoginViewConroller;

@protocol GCLoginViewControllerDelegate

@required
- (void)willCloseLoginViewController:(GCLoginViewConroller *)loginViewController;
@optional
- (void)willCancelLoginViewController:(GCLoginViewConroller *)loginViewController;

@end
