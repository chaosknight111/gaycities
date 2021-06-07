//
//  OCWebViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/3/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "OCWebViewController.h"
#import "GayCitiesAppDelegate.h"

@implementation OCWebViewController

@synthesize wv, webProgress, urlString, url, name;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
-(id)init
{
	self = [super init];
	[self initWithNibName:@"OCWebViewController" bundle:nil];
	return self;
}


-(void)setURL:(NSURL *)u andName:(NSString *)aName
{
	if ([u isEqual:url]) {
		return;
	}
	
	self.url = u;
	self.name = aName;
	
	//NSURLRequest *request = [NSURLRequest requestWithURL:url];
	//[wv loadRequest:request];
	
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[webProgress startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[webProgress stopAnimating];
	[webProgress setHidden:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[webProgress stopAnimating];
	[webProgress setHidden:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//  NSURL *aURL = [request URL];
//  if ([[aURL host] isEqualToString:@"www.gaycities.com"]) {
//    NSArray *array = [[aURL absoluteString] componentsSeparatedByString:@"#access_token="];
//    if (array && [array count] == 2) {
//      NSLog(@"Foursquare Token: %@", [array lastObject]);
//      [self.navigationController popViewControllerAnimated:YES];
//      return NO;
//    }
//  }

  return YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];	
	// [super viewDidLoad];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	
	[self setTitle:name];
	[urlString setText:[url absoluteString]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[wv loadRequest:request];
	
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	NSLog(@"Webview deallocd");
	self.wv = nil;
	self.webProgress = nil;
	self.urlString = nil;
	self.url = nil;
	self.name = nil;
    [super dealloc];
}


@end
