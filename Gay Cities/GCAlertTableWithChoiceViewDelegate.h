//
//  GCAlertTableWithChoiceViewDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 2/7/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCAlertTableWithChoiceView;

@protocol GCAlertTableWithChoiceViewDelegate
@required
- (void)willCloseAlertTableWithChoiceViewController:(GCAlertTableWithChoiceView *)viewController;

@end
