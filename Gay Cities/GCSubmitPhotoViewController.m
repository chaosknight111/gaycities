//
//  GCSumbitPhotoViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 7/4/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import "GCSubmitPhotoViewController.h"
#import "GayCitiesAppDelegate.h"

@implementation GCSubmitPhotoViewController

@synthesize captionTextField, imageView, showCaption, captionLabel, image, delegate;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		showCaption = NO;
		self.image = nil;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	self.title = @"Photo";
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	[captionTextField addTarget:captionTextField action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
	
	if (image) {
		imageView.image = image;
	}
	
	if (showCaption) {
		captionTextField.hidden = NO;
	} else {
		captionTextField.hidden = YES;
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
  [gcad.mainTabBar setHidden:YES];
	[gcad.adBackgroundView setHidden:YES];
	gcad.shouldShowAdView = NO;
  
  
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAndClose:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitImageAndClose:)];
	self.navigationItem.rightBarButtonItem = submitButton;
	[submitButton release];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!image) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Image" message:@"We were not able to use the selected image.  Please try again later and contact support on gaycities.com if the issue persists." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self cancelAndClose:nil];

}


- (id)initWithImage:(UIImage *)anImage showingCaption:(BOOL)show withDelegate:(NSObject<GCSubmitPhotoViewControllerDelegate> *)photoDelegate
{
	if (self = [super init]) {
		if (anImage) {
			self.image = anImage;
		} else {
			image = [[UIImage alloc] init];
		}
		
		showCaption = show;
		
		if (photoDelegate) {
			self.delegate = photoDelegate;
		} else {
			self.delegate = nil;
		}
	}
	
	return self;
}
- (IBAction)submitImageAndClose:(id)sender
{
	if (delegate) {
		if ([delegate respondsToSelector:@selector(willCloseSubmitPhotoViewController:)]) {
			[delegate willCloseSubmitPhotoViewController:self];
		}
	}
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelAndClose:(id)sender
{
	if (delegate) {
		if ([delegate respondsToSelector:@selector(willCancelSubmitPhotoViewController:)]) {
			[delegate willCancelSubmitPhotoViewController:self];
		}
	}
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.captionTextField = nil;
	self.imageView = nil;
	self.captionLabel = nil;
	if (image) {
		self.image = nil;
	}
    [super dealloc];
}


@end
