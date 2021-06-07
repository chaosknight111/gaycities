//
//  OCWebViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/3/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCProfileWebViewController.h"
#import "GayCitiesAppDelegate.h"

@implementation GCProfileWebViewController

@synthesize wv, profileRequest;

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
	[self initWithNibName:@"GCProfileWebViewController" bundle:nil];
	return self;
}




- (void)webViewDidStartLoad:(UIWebView *)webView
{
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];	
	[self setTitle:@"Profile"];

	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	[gcad.adBackgroundView setHidden:YES];
	gcad.shouldShowAdView = NO;
	
	[gcad showProcessing:@"Loading..."];

	[wv loadRequest:profileRequest];
	//[gcad.mainTabBar setHidden:YES];
	
	
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];	
	//GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, CGRectGetHeight(self.view.superview.bounds) - 49.f);
	
	
	
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	//[gcad.mainTabBar setHidden:NO];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	[gcad hideProcessing];

	[gcad.adBackgroundView setHidden:NO];
	gcad.shouldShowAdView = YES;
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
	self.wv = nil;
	self.profileRequest = nil;
    [super dealloc];
}


@end
