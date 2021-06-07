//
//  GCSubmitNewBusinessViewControllerDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 2/7/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCSubmitNewBusinessViewController;

@protocol GCSubmitNewBusinessViewControllerDelegate
@required
- (void)willCloseSumbitNewBusinessViewController:(GCSubmitNewBusinessViewController *)viewController;
- (void)willCancelSumbitNewBusinessViewController:(GCSubmitNewBusinessViewController *)viewController;


@end
