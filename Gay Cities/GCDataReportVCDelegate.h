//
//  GCDataReportVCDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/3/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDataReportVC;

@protocol GCDataReportVCDelegate

@required
- (void)willCloseDataReportViewController:(GCDataReportVC *)dataReportViewController;
@optional
- (void)willCancelDataReportViewController:(GCDataReportVC *)dataReportViewController;

@end
