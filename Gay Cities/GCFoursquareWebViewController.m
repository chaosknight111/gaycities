//
//  GCFoursquareWebViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/31/11.
//  Copyright 2011 Apple Inc. All rights reserved.
//

#import "GCFoursquareWebViewController.h"
#import "GayCitiesAppDelegate.h"
#import "GCCommunicator.h"
#import "GCConnectController.h"

//#define kGCFoursquareURL [NSURL URLWithString:@"https://foursquare.com/oauth2/authenticate?client_id=LSUTR4SEWTCRFIKSO00H5YNDCCSY0GOY0OUKZMX0AACYP4GO&response_type=token&display=touch&redirect_uri=http://www.gaycities.com/foursquare/callback.php/"]

#define kGCFoursquareURL [NSURL URLWithString:@"http://www.gaycities.com/foursquare/?go=1&iphone=1"]

@implementation GCFoursquareWebViewController

@synthesize webView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
  UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
}
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];	
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	[gcad showProcessing:@"Loading..."];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:kGCFoursquareURL];

//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:kGCFoursquareURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
	GCCommunicator *communicator = [GCCommunicator sharedCommunicator];
	
	if (communicator.ul.currentLoginStatus) {
		NSString *string = [NSString stringWithFormat:@"%@|%@", communicator.ul.gcLoginUsername, communicator.ul.authToken];
		NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
									@"gaycities.com", NSHTTPCookieDomain,
									@"\\", NSHTTPCookiePath,  // IMPORTANT!
									@"appsignedin", NSHTTPCookieName,
									string, NSHTTPCookieValue,
									nil];
		
		NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
		NSArray *cookies = [NSArray arrayWithObjects:cookie, nil];
		
		NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
		
		[request setAllHTTPHeaderFields:headers];
	}
	
	[webView loadRequest:request];
	[request autorelease];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [webView release];
  webView = nil;
    [super dealloc];
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	NSLog(@"Foursquare webview start load");
	

}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	NSLog(@"Foursquare webview finish load");
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	[gcad hideProcessing];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
	NSLog(@"Foursquare webview error, present alert...");
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	[gcad hideProcessing];
	[self.navigationController popViewControllerAnimated:YES];

}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{
	NSURL *aURL = [request URL];

	if ([aURL isEqual:kGCFoursquareURL]) {
		NSLog(@"GC FS Auth Start");
		return YES;
	}
	
	if ([aURL isEqual:[NSURL URLWithString:@"http://www.gaycities.com/foursquare/callback.php?error=access_denied"]]) {
		NSLog(@"FS login failed, pop view controller & present error");
		[self.navigationController popViewControllerAnimated:YES];
		return NO;
	} 
	
	if ([[aURL host] isEqualToString:@"www.gaycities.com"]) {
		NSLog(@"GayCities Request, check for API token");
		GayCitiesAppDelegate *appDelegate = [GayCitiesAppDelegate sharedAppDelegate];
		[appDelegate.connectController checkForFoursquareTokenWithStatus:YES];
		[self.navigationController popViewControllerAnimated:YES];
		return NO;
	} 
	
	if ([aURL isEqual:[NSURL URLWithString:@"https://foursquare.com/"]]) {
		NSLog(@"Redirected to FS home page, pop view controller");
		[self.navigationController popViewControllerAnimated:YES];
		return NO;
	}
	
	NSLog(@"FS request not handled, URL: %@", aURL);
	return YES;
}


@end
