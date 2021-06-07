//
//  AskLoginCreateViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 4/26/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCAskLoginCreateViewController.h"


@implementation GCAskLoginCreateViewController

@synthesize greetingTextLabel, gcDelegate, greetingText, cancelButton, usernameText, passwordText;
@synthesize signinContentView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
 */

- (id)initWithGreeting:(NSString *)newGreeting
{
	if ((self = [super initWithNibName:nil bundle:nil])) {
		if (newGreeting && [newGreeting length] > 0) {
			self.greetingText = newGreeting;
		} else {
			self.greetingText = @"Sign in to share your take,\nsee what your friends are up to,\nand meet new people";
		}
        initialLaunch = NO;
    }
    return self;
}

- (id)initWithGreetingInitialLaunch:(NSString *)newGreeting
{
	if ((self = [super initWithNibName:nil bundle:nil])) {
		if (newGreeting && [newGreeting length] > 0) {
			self.greetingText = newGreeting;
		} else {
			self.greetingText = @"Sign in to share your take,\nsee what your friends are up to,\nand meet new people";
		}
		initialLaunch = YES;
		
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	self.title = @"Account";
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationController.navigationBar.topItem.titleView = titleView;
	[titleView release];
	
	
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (greetingText) {
		greetingTextLabel.text = greetingText;
		self.greetingText = nil;
	} else {
		greetingTextLabel.text = @"Sign in to share your take,\nsee what your friends are up to,\nand meet new people";
	}
	if (initialLaunch) {
		//[cancelButton setTitle:@"SKIP FOR NOW" forState:UIControlStateNormal];
		UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNow)];
		self.navigationController.navigationBar.topItem.leftBarButtonItem = close;
		
		[close release];

	} else {
		//[cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
		UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNow)];
		self.navigationController.navigationBar.topItem.leftBarButtonItem = close;
		
		[close release];
	}
	
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
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

- (IBAction)setUsername:(id)sender
{

	[passwordText becomeFirstResponder];
}

- (IBAction)setPassword:(id)sender
{

	if ([usernameText.text length] == 0) {
		[usernameText becomeFirstResponder];
		return;
	}
	
	if ([passwordText.text length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Required" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	if ([usernameText.text length] > 0 && [passwordText.text length] > 0) {
		//[self moveViewDown:nil];
		[self signInNow];
	}
	
	
}

- (IBAction)textFieldEditingStarted:(id)sender
{
	if ([usernameText isFirstResponder] || [passwordText isFirstResponder]) {
		UIBarButtonItem *hide = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignBothTextFields)];
		self.navigationController.navigationBar.topItem.rightBarButtonItem = hide;
		[hide release];
		self.navigationController.navigationBar.topItem.leftBarButtonItem = nil;
	}
	
}

- (void)resignBothTextFields
{

	if ([usernameText isFirstResponder]) {

		[usernameText resignFirstResponder];

	} else if ([passwordText isFirstResponder]) {

		[passwordText resignFirstResponder];
	}
	
	if (initialLaunch) {
		//[cancelButton setTitle:@"SKIP FOR NOW" forState:UIControlStateNormal];
		UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNow)];
		self.navigationController.navigationBar.topItem.leftBarButtonItem = close;
		
		[close release];
		
	} else {
		//[cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
		UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNow)];
		self.navigationController.navigationBar.topItem.leftBarButtonItem = close;
		
		[close release];
	}
	
	if ([usernameText.text length] > 0 && [passwordText.text length] > 0) {
		UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(signInNow)];
		self.navigationController.navigationBar.topItem.rightBarButtonItem = submit;
		[submit release];
	} else {
		self.navigationController.navigationBar.topItem.rightBarButtonItem = nil;
		
	}

}

/*
- (IBAction)moveViewUp:(id)sender
{
	if (signinContentView.frame.origin.y != -110) {
		signinContentView.frame= CGRectMake(0, -110, 320, 460);
	}
}

- (IBAction)moveViewDown:(id)sender
{
	if (signinContentView.frame.origin.y != 0) {
		signinContentView.frame= CGRectMake(0, 0, 320, 460);
	}
}
*/


- (IBAction)signInNow
{

	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCloseAskLoginCreateViewControllerToLogin:withUsername:andPassword:)]) {
			NSString *loginName = usernameText.text;
			NSString *loginPass = passwordText.text;
			[gcDelegate willCloseAskLoginCreateViewControllerToLogin:self withUsername:loginName andPassword:loginPass];
		} else {
			NSLog(@"gcDelegate doesnt respond to willCloseAskLoginCreateViewControllerToLogin: withUsername andPassword:");
		}
	}
	[self.navigationController dismissModalViewControllerAnimated:YES];

	
}

- (IBAction)signUpNewNow
{

	[self.navigationController dismissModalViewControllerAnimated:NO];

	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCloseAskLoginCreateViewControllerToCreate:)]) {
			[gcDelegate willCloseAskLoginCreateViewControllerToCreate:self];
		} else {
			NSLog(@"gcDelegate doesnt respond to willCloseAskLoginCreateViewControllerToCreate");
		}
	}
	
}

- (IBAction)cancelNow
{

	[self.navigationController dismissModalViewControllerAnimated:YES];

	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCancelAskLoginCreateViewController:)]) {
			[gcDelegate willCancelAskLoginCreateViewController:self];
		} else {
			NSLog(@"gcDelegate doesnt respond to willCancelAskLoginCreateViewController");
		}
	}
	
}



- (void)dealloc {
	self.greetingTextLabel = nil;
	self.usernameText = nil;
	self.passwordText = nil;
    [super dealloc];
}


@end
