//
//  OCWebViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/3/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OCWebViewController : UIViewController {
	NSURL *url;
	NSString *name;
	IBOutlet UIWebView *wv;
	IBOutlet UIActivityIndicatorView *webProgress;
	IBOutlet UITextField *urlString;
}

@property (nonatomic, retain) UIWebView *wv;
@property (nonatomic, retain) UIActivityIndicatorView *webProgress;
@property (nonatomic, retain) UITextField *urlString;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *name;

-(void)setURL:(NSURL *)u andName:(NSString *)aName;

@end
