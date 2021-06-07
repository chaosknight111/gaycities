//
//  OCWebViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/3/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GCProfileWebViewController : UIViewController {
	IBOutlet UIWebView *wv;
	NSURLRequest *profileRequest;
}

@property (nonatomic, retain) UIWebView *wv;
@property (nonatomic, retain) NSURLRequest *profileRequest;


@end
