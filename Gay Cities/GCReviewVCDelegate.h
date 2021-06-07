//
//  GCSumbitPhotoViewControllerDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/3/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCReviewVC;

@protocol GCReviewVCDelegate

@required
- (void)willCloseReviewViewController:(GCReviewVC *)reviewViewController;
@optional
- (void)willCancelReviewViewController:(GCReviewVC *)reviewViewController;

@end
