//
//  GCDataReportVC.m
//  Gay Cities
//
//  Created by Brian Harmann on 7/4/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import "GCDataReportVC.h"
#import "OCConstants.h"
#import "OCSearchBar.h"

@implementation GCDataReportVC

@synthesize delegate, reportTextView, month, year, reportDate, datePicker, dateView;;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

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
	
	
	dateFormatterY = [[NSDateFormatter alloc] init];
	[dateFormatterY setDateFormat:@"yyyy"];
	dateFormatterM = [[NSDateFormatter alloc] init];
	[dateFormatterM setDateFormat:@"MM"];
	
	year = [[dateFormatterY stringFromDate:[NSDate date]] intValue];
	month = [[dateFormatterM stringFromDate:[NSDate date]] intValue];
	
	NSString *dateString = [[NSString alloc] initWithFormat:@"%@ %i", [OCConstants monthForNumber:month], year];
	reportDate.text = dateString;
	[dateString release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAndClose:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	
	

}

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
	self.reportTextView = nil;
	self.delegate = nil;
	[dateFormatterY release];
	[dateFormatterM release];
	self.reportDate = nil;
	self.datePicker = nil;
	self.dateView = nil;
    [super dealloc];
}

- (id)initWithDelegate:(NSObject<GCDataReportVCDelegate> *)reportDelegate
{
	if (self = [super init]) {
		if (reportDelegate) {
			self.delegate = reportDelegate;		
		} else {
			self.delegate = nil;
		}
		

		
	}
	
	return self;
}
- (IBAction)submitReportAndClose:(id)sender
{
	if (delegate) {
		if ([delegate respondsToSelector:@selector(willCloseDataReportViewController:)]) {
			[delegate willCloseDataReportViewController:self];
		}
	}
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	
}

- (IBAction)cancelAndClose:(id)sender
{
	if (delegate) {
		if ([delegate respondsToSelector:@selector(willCancelDataReportViewController:)]) {
			[delegate willCancelDataReportViewController:self];
		}
	}
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	
	
}


- (IBAction)showDatePicker:(id)sender
{
	int currentYear = [[dateFormatterY stringFromDate:[NSDate date]] intValue];

	[datePicker selectRow:(month - 1) inComponent:0 animated:NO];
	[datePicker selectRow:(year - currentYear + 11) inComponent:1 animated:NO];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.5];
	dateView.frame = self.view.frame;
	[self.view addSubview:dateView];
	[UIView commitAnimations];
	
	[reportTextView resignFirstResponder];
	 self.navigationItem.leftBarButtonItem = nil;
	 self.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)closeDatePicker:(id)sender
{
	
	[dateView removeFromSuperview];
	
	if ([[reportTextView text] length] > 0) {
		UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitReportAndClose:)];
		self.navigationItem.rightBarButtonItem = submitButton;
		[submitButton release];
	}
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAndClose:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	NSString *dateString = [[NSString alloc] initWithFormat:@"%@ %i", [OCConstants monthForNumber:month], year];
	reportDate.text = dateString;
	[dateString release];
}



-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([[textView text] length] < 1) {
		self.navigationItem.rightBarButtonItem = nil;
	}
	
	if([text isEqualToString:@"\n"])
	 {
		[textView resignFirstResponder];
		if ([[textView text] length] > 0) {
			UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitReportAndClose:)];
			self.navigationItem.rightBarButtonItem = submitButton;
			[submitButton release];
		} else {
			self.navigationItem.rightBarButtonItem = nil;;
		}
		
		return NO;
	 }
	return YES;
}





- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 12;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (component == 0) {
		switch (row) {
			case 0:
				return @"January";
				break;
			case 1:
				return @"February";
				break;
			case 2:
				return @"March";
				break;
			case 3:
				return @"April";
				break;
			case 4:
				return @"May";
				break;
			case 5:
				return @"June";
				break;
			case 6:
				return @"July";
				break;
			case 7:
				return @"August";
				break;
			case 8:
				return @"September";
				break;
			case 9:
				return @"October";
				break;
			case 10:
				return @"November";
				break;
			case 11:
				return @"December";
				break;
				
		}
	}
	else if (component == 1) {
		
		int date = [[dateFormatterY stringFromDate:[NSDate date]] intValue];
		return [NSString stringWithFormat:@"%i",(date - (11 - row))];
		
	}
	
	return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0) {
		month = row + 1;
	}
	else if (component == 1) {
		
		int date = [[dateFormatterY stringFromDate:[NSDate date]] intValue];
		year = (date - (11 - row));
		
		
	}
	
}


@end
