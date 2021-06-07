//
//  GCCreateAccountViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 3/19/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCCreateAccountViewController.h"


@implementation GCCreateAccountViewController

@synthesize usernameField, passwordField1, passwordField2, emailField, zipField;
@synthesize birthdayLabel, passwordsVerifyLabel, headerReportLabel;
@synthesize genderControl, newsletterControl;
@synthesize birthdayPicker;
@synthesize birthdaySlideUpView;
@synthesize createUsername, createPassword, createEmail, createZip, createBirthMonth, createBirthDay, createBirthYear, createGender, createNewsletterOption;
@synthesize gcDelegate;
@synthesize birthDate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	self.createUsername = nil;
	self.createPassword = nil;
	self.createEmail = nil;
	self.createZip = nil;
	self.createBirthMonth = nil;
	self.createBirthDay = nil;
	self.createBirthYear = nil;
	self.createGender = nil;
	self.createNewsletterOption = @"1";
	birthdayPicker.datePickerMode = UIDatePickerModeDate;
	birthdayPicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:-568076800];
	birthdayPicker.date = [NSDate dateWithTimeIntervalSinceNow:-788400000];
  self.birthDate = birthdayPicker.date;
	birthdayPickerShown = NO;
	
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	self.title = @"Create Account";
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationController.navigationBar.topItem.titleView = titleView;
	[titleView release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNewAccount)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[usernameField becomeFirstResponder];
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)saveUsernameText
{
	if ([usernameField.text length] == 0) {
		headerReportLabel.text = @"Username is required";
		self.createUsername = nil;
		
	} else {
		headerReportLabel.text = @"";
		self.createUsername = usernameField.text;
		
	}
	
	
	
}

- (IBAction)savePasswordOneText
{
	if ([passwordField1.text length] == 0) {
		headerReportLabel.text = @"Password is Required";
		passwordsVerifyLabel.text = @"";
		self.createPassword = nil;
		
	} else if ([passwordField2.text length] == 0) {
		headerReportLabel.text = @"";
		passwordsVerifyLabel.text = @"";
		self.createPassword = nil;
		
		
	} else if (![passwordField1.text isEqualToString:passwordField2.text]) {
		headerReportLabel.text = @"Verify you have typed your password correctly";
		passwordsVerifyLabel.text = @"Passwords do not match";
		self.createPassword = nil;
		
	} else if ([passwordField1.text isEqualToString:passwordField2.text] && [passwordField1.text length] > 0){
		headerReportLabel.text = @"";
		passwordsVerifyLabel.text = @"";
		self.createPassword = passwordField1.text;
		
	} else {
		headerReportLabel.text = @"";
		passwordsVerifyLabel.text = @"";
		self.createPassword = nil;
	}
	
	
}

- (IBAction)savePasswordTwoText
{
	if ([passwordField2.text length] == 0) {
		headerReportLabel.text = @"";
		passwordsVerifyLabel.text = @"";
		self.createPassword = nil;
		
	} else if ([passwordField1.text length] == 0){
		headerReportLabel.text = @"Password is Required";
		passwordsVerifyLabel.text = @"Passwords do not match";
		self.createPassword = nil;
		
		
	} else if (![passwordField1.text isEqualToString:passwordField2.text]) {
		headerReportLabel.text = @"";
		passwordsVerifyLabel.text = @"Passwords do not match";
		self.createPassword = nil;
		

	}else if ([passwordField1.text isEqualToString:passwordField2.text] && [passwordField2.text length] > 0){
		headerReportLabel.text = @"";
		passwordsVerifyLabel.text = @"";
		self.createPassword = passwordField1.text;
		
	} else {
		headerReportLabel.text = @"";
		passwordsVerifyLabel.text = @"";
		self.createPassword = nil;
	}

}

- (IBAction)saveEmailText
{
	if ([emailField.text length] == 0) {
		headerReportLabel.text = @"Email address is required";
		self.createEmail = nil;
		
		return;
	} else {
		headerReportLabel.text = @"";
		self.createEmail = emailField.text;
		
	}

}

- (IBAction)saveZipText
{
	if ([zipField.text length] == 0) {
		headerReportLabel.text = @"Postal Code is Required";
		self.createZip = nil;
	} else {
		self.createZip = zipField.text;
		headerReportLabel.text = @"";
	}
}

- (IBAction)showBirthdayPicker
{
	if (birthdayPickerShown) {
		return;
	}
	if  ([usernameField isFirstResponder]  && [usernameField canResignFirstResponder]) {
		[usernameField resignFirstResponder];
	} else if  ([passwordField1 isFirstResponder]  && [passwordField1 canResignFirstResponder]) {
		[passwordField1 resignFirstResponder];
	} else if  ([passwordField2 isFirstResponder]  && [passwordField2 canResignFirstResponder]) {
		[passwordField2 resignFirstResponder];
	} else if  ([emailField isFirstResponder]  && [emailField canResignFirstResponder]) {
		[emailField resignFirstResponder];
	} else if  ([zipField isFirstResponder]  && [zipField canResignFirstResponder]) {
		[zipField resignFirstResponder];
	}
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.4];
	//[UIView setAnimationDidStopSelector:@selector(birthdayPickerShown)];
	//[UIView setAnimationDelegate:self];
	birthdaySlideUpView.frame = CGRectMake(0, 0, 320, 460);
	[UIView commitAnimations];	
	birthdayPickerShown = YES;
	UIBarButtonItem *saveBDayButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(closeBirthdayPicker)];
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = saveBDayButton;
	[saveBDayButton release];
}



- (IBAction)closeBirthdayPicker
{
	if (!birthdayPickerShown) {
		
		return;
	}
	birthdayPickerShown = NO;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.4];
	[UIView setAnimationDidStopSelector:@selector(birthdayPickerClosed)];
	[UIView setAnimationDelegate:self];
	birthdaySlideUpView.frame = CGRectMake(0, 411, 320, 460);
	[UIView commitAnimations];	
	
}

- (void)birthdayPickerClosed
{
	
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:birthdayPicker.date];
	
  self.birthDate = birthdayPicker.date;
  
	self.createBirthDay = [NSString stringWithFormat:@"%i", comps.day];
	self.createBirthMonth = [NSString stringWithFormat:@"%i", comps.month];
	self.createBirthYear = [NSString stringWithFormat:@"%i", comps.year];
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNewAccount)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = nil;;
	[cancelButton release];
	[self selectNextField:birthdayPicker];
	birthdayLabel.text = [NSString stringWithFormat:@"%@/%@/%@", createBirthMonth, createBirthDay, createBirthYear];
	birthdayLabel.textColor = [UIColor blackColor];
	
}

- (IBAction)saveGenderSelection
{
	if (genderControl.selectedSegmentIndex == 0) {
		self.createGender = @"M";
	} else if (genderControl.selectedSegmentIndex == 1) {
		self.createGender = @"F";
	} else if (genderControl.selectedSegmentIndex == 2) {
		self.createGender = @"T";
	} else {
		self.createGender = nil;
	}
	[self selectNextField:genderControl];
	
}

- (IBAction)saveNewsletterSelection
{
	if (newsletterControl.selectedSegmentIndex == 0) {
		self.createNewsletterOption = @"0";
	} else if (newsletterControl.selectedSegmentIndex == 1) {
		self.createNewsletterOption = @"1";
	} else {
		self.createNewsletterOption = nil;
	}
	[self selectNextField:newsletterControl];
	
}

- (void)cancelNewAccount
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCancelCreateAccountViewController:)]) {
			[gcDelegate willCancelCreateAccountViewController:self];
		} else {
			NSLog(@"gcDelegate doesnt respond to willCancelCreateAccountViewController");
		}
	}
	

}

- (void)submitNewAccount
{
	
	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCloseCompletedCreateAccountViewController:)]) {
			[gcDelegate willCloseCompletedCreateAccountViewController:self];
		} else {
			NSLog(@"gcDelegate doesnt respond to willCloseCompletedCreateAccountViewController");
		}
	}
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)selectNextField:(id)sender
{
	self.navigationItem.rightBarButtonItem = nil;
	
	if (!createUsername || [createUsername length] == 0) {
		if (birthdayPickerShown) {
			[self closeBirthdayPicker];
		}
		headerReportLabel.text = @"Username is required";
		if (sender) {
			if (sender == usernameField) {
				[emailField becomeFirstResponder];
			} else {
				[usernameField becomeFirstResponder];
			}
		}
		
		
	} else if (!createEmail || [createEmail length] == 0) {
		if (birthdayPickerShown) {
			[self closeBirthdayPicker];
		}
		headerReportLabel.text = @"Please enter a Email Address";
		if (sender) {
			if (sender == emailField) {
				[passwordField1 becomeFirstResponder];
			} else {
				[emailField becomeFirstResponder];
			}
		}
	} else if (!createPassword || [createPassword length] == 0) {
		if (birthdayPickerShown) {
			[self closeBirthdayPicker];
		}
		
		if ([passwordField1.text length] > 0 && ![passwordField1.text isEqualToString:passwordField2.text]) {
			//self.createPassword = passwordField1.text;
			headerReportLabel.text = @"Please verify your password";
			if ([passwordField2.text length] > 0) {
				passwordsVerifyLabel.text = @"Passwords do not match";
			} else {
				passwordsVerifyLabel.text = @"";
			}
			if (sender) {
				if (sender == passwordField2) {
					[zipField becomeFirstResponder];
				} else {
					[passwordField2 becomeFirstResponder];
				}
			}
			

		} else {
			
			//passwordField1.text = @"";
			headerReportLabel.text = @"Please enter a password";
			if ([passwordField2.text length] > 0) {
				passwordsVerifyLabel.text = @"Passwords do not match";
			} else {
				passwordsVerifyLabel.text = @"";
			}if (sender) {
				if (sender == passwordField1) {
					[passwordField2 becomeFirstResponder];
				} else {
					[passwordField1 becomeFirstResponder];
				}
			}
			
		}
	} else if (!createZip || [createZip length] == 0) {
		headerReportLabel.text = @"Please enter a Postal Code";
		if (birthdayPickerShown) {
			[self closeBirthdayPicker];
		}
		if (sender) {
			if (sender == zipField) {
				[zipField resignFirstResponder];
			} else {
				[zipField becomeFirstResponder];
			}
		}
		
	} else if (!createGender || [createGender length] == 0) {
		if  ([usernameField isFirstResponder]  && [usernameField canResignFirstResponder]) {
			[usernameField resignFirstResponder];
		} else if  ([passwordField1 isFirstResponder]  && [passwordField1 canResignFirstResponder]) {
			[passwordField1 resignFirstResponder];
		} else if  ([passwordField2 isFirstResponder]  && [passwordField2 canResignFirstResponder]) {
			[passwordField2 resignFirstResponder];
		} else if  ([emailField isFirstResponder]  && [emailField canResignFirstResponder]) {
			[emailField resignFirstResponder];
		} else if  ([zipField isFirstResponder]  && [zipField canResignFirstResponder]) {
			[zipField resignFirstResponder];
		}
		if (birthdayPickerShown) {
			[self closeBirthdayPicker];
		}
		headerReportLabel.text = @"Please select your gender";
		
	} else if ((!createBirthDay || !createBirthMonth || !createBirthYear) && !birthdayPickerShown) {
		headerReportLabel.text = @"Please enter your birthday";
		if  ([usernameField isFirstResponder]  && [usernameField canResignFirstResponder]) {
			[usernameField resignFirstResponder];
		} else if  ([passwordField1 isFirstResponder]  && [passwordField1 canResignFirstResponder]) {
			[passwordField1 resignFirstResponder];
		} else if  ([passwordField2 isFirstResponder]  && [passwordField2 canResignFirstResponder]) {
			[passwordField2 resignFirstResponder];
		} else if  ([emailField isFirstResponder]  && [emailField canResignFirstResponder]) {
			[emailField resignFirstResponder];
		} else if  ([zipField isFirstResponder]  && [zipField canResignFirstResponder]) {
			[zipField resignFirstResponder];
		}
		if (sender) {
			[self showBirthdayPicker];
		}
		
		return;
	} else if (!createNewsletterOption || [createNewsletterOption length] == 0) {
		if  ([usernameField isFirstResponder]  && [usernameField canResignFirstResponder]) {
			[usernameField resignFirstResponder];
		} else if  ([passwordField1 isFirstResponder]  && [passwordField1 canResignFirstResponder]) {
			[passwordField1 resignFirstResponder];
		} else if  ([passwordField2 isFirstResponder]  && [passwordField2 canResignFirstResponder]) {
			[passwordField2 resignFirstResponder];
		} else if  ([emailField isFirstResponder]  && [emailField canResignFirstResponder]) {
			[emailField resignFirstResponder];
		} else if  ([zipField isFirstResponder]  && [zipField canResignFirstResponder]) {
			[zipField resignFirstResponder];
		}
		if (birthdayPickerShown) {
			[self closeBirthdayPicker];
		}
		headerReportLabel.text = @"Would you like to recieve our newsletter?";
		
	} else if (birthdayPickerShown) {
		headerReportLabel.text = @"";
		[self closeBirthdayPicker];
		
	}
		
	if ([passwordField1.text length] > 0 && [passwordField1.text isEqualToString:passwordField2.text]) {
		if (![passwordField1.text isEqualToString:createPassword]) {
			self.createPassword = passwordField1.text;
		}
		
		passwordsVerifyLabel.text = @"";
	}
	
	if (createUsername && createPassword && createEmail && createZip && createBirthDay && createBirthMonth && createBirthYear && createGender && createNewsletterOption) {
		if ([createUsername length] > 0 && [createPassword length] > 0 && [createEmail length] > 0 && [createZip length] > 0 && [createBirthDay length] > 0 && [createBirthMonth length] > 0 && [createBirthYear length] > 0 && [createGender length] > 0 && [createNewsletterOption length] > 0) {

			headerReportLabel.text = @"Thank You for completing this form\nPlease press 'Submit' to create your account";
			if  ([usernameField isFirstResponder]  || [passwordField1 isFirstResponder] || [passwordField2 isFirstResponder] || [emailField isFirstResponder] || [zipField isFirstResponder]  || birthdayPickerShown) {
				self.navigationItem.rightBarButtonItem = nil;
			} else {
				UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitNewAccount)];
				self.navigationItem.rightBarButtonItem = submitButton;
				[submitButton release];
			}
			
			
		} else {
			self.navigationItem.rightBarButtonItem = nil;
		}
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
}

- (IBAction)resignNow:(id)sender
{
	if ([sender canResignFirstResponder]) {
		[sender resignFirstResponder];
	}
	[self selectNextField:sender];
	
}

- (IBAction)editingBeginning:(id)sender
{
	if (sender == usernameField || sender == emailField || sender == passwordField1 || sender == passwordField2 || sender == zipField) {
		self.navigationItem.rightBarButtonItem = nil;
	}
	[self selectNextField:nil];
}



- (void)dealloc {
	self.usernameField = nil;
	self.passwordField1 = nil;
	self.passwordField2 = nil;
	self.emailField = nil;
	self.zipField = nil;
	self.birthdayLabel = nil;
	self.passwordsVerifyLabel = nil;
	self.headerReportLabel = nil;
	self.genderControl = nil;
	self.newsletterControl = nil;
	self.birthdayPicker = nil;
	self.birthdaySlideUpView = nil;
	self.createUsername = nil;
	self.createPassword = nil;
	self.createEmail = nil;
	self.createZip = nil;
	self.createBirthMonth = nil;
	self.createBirthDay = nil;
	self.createBirthYear = nil;
	self.createGender = nil;
	self.createNewsletterOption = nil;
  [birthDate release];
    [super dealloc];
}


@end
