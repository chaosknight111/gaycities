//
//  GCAskLoginCReateViewControllerDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 4/26/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCAskLoginCreateViewController;

@protocol GCAskLoginCreateViewControllerDelegate

@required
- (void)willCloseAskLoginCreateViewControllerToCreate:(GCAskLoginCreateViewController *)askLoginCreateViewController;
- (void)willCloseAskLoginCreateViewControllerToLogin:(GCAskLoginCreateViewController *)askLoginCreateViewController withUsername:(NSString *)loginName andPassword:(NSString *)loginPassword;

@optional
- (void)willCancelAskLoginCreateViewController:(GCAskLoginCreateViewController *)askLoginCreateViewController;
- (void)willCloseAskLoginCreateViewControllerToLogin:(GCAskLoginCreateViewController *)askLoginCreateViewController;

@end
