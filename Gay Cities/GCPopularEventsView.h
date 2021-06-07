//
//  GCPopularEventsView.h
//  Gay Cities
//
//  Created by Brian Harmann on 12/6/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCEventSummaryDelegate.h"

@class GCEventSummary;

@interface GCPopularEventsView : UIView <GCEventSummaryDelegate> {
  GCEventSummary *event;
  UIImageView *imageView;
  UILabel *popularTypeLabel;
  UIActivityIndicatorView *activityIndicator;
  UIButton *loadEventButton;
}

@property (nonatomic, retain) GCEventSummary *event;
@property (nonatomic, retain) UIButton *loadEventButton;

- (void)loadImage:(NSNotification *)note;

@end
