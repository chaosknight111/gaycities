//
//  GCFoursquareWebViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/31/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCFoursquareWebViewController : UIViewController <UIWebViewDelegate> {
  UIWebView *webView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
