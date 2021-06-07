//
//  GCSumbitPhotoViewControllerDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/3/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCSubmitPhotoViewController;

@protocol GCSubmitPhotoViewControllerDelegate

@required
- (void)willCloseSubmitPhotoViewController:(GCSubmitPhotoViewController *)submitPhotoViewController;
@optional
- (void)willCancelSubmitPhotoViewController:(GCSubmitPhotoViewController *)submitPhotoViewController;

@end
