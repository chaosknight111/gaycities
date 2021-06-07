//
//  GCReviewVC.m
//  Gay Cities
//
//  Created by Brian Harmann on 7/4/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import "GCReviewVC.h"
#import "BAUIStarSlider.h"
#import "GCNSStringExtras.h"

@implementation GCReviewVC

@synthesize reviewTitle, reviewText, reviewVisited, reviewRating, previousReview;
@synthesize month, year;
@synthesize reviewDelegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithReview:(NSDictionary *)review
{
	if (self = [super init]) {
		if ([review count] > 0) {
			self.previousReview = review;
		} else {
			previousReview = [[NSDictionary alloc] init];
		}
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	self.title = @"Review";
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	
	
	dateFormatterY = [[NSDateFormatter alloc] init];
	[dateFormatterY setDateFormat:@"yyyy"];
	if (!previousReview) {
		previousReview = [[NSDictionary alloc] init];
	}
	reviewRating = [[BAUIStarSlider alloc] initWithFrame:CGRectMake(65, 30, 190, 35) andStars:5];
	[self.view addSubview:reviewRating];
	
	if ([previousReview count] >0) {
//		NSLog(@"previous review: %@", previousReview);
		

		int date = [[dateFormatterY stringFromDate:[NSDate date]] intValue];
		int vdate = [[previousReview objectForKey:@"r_visited_year"] intValue];
		if (vdate >= (date - 11)) {
			[reviewVisited selectRow:(11 - (date-vdate)) inComponent:1 animated:NO];
			[self pickerView:reviewVisited didSelectRow:(11 - (date-vdate)) inComponent:1];
		}
		else {
			[reviewVisited selectRow:11 inComponent:1 animated:NO];
			[self pickerView:reviewVisited didSelectRow:11 inComponent:1];
		}
		
		month = [[previousReview objectForKey:@"r_visited_month"] intValue];
		if (month > 0 && month <= 12) {
			[reviewVisited selectRow:(month - 1) inComponent:0 animated:NO];
			[self pickerView:reviewVisited didSelectRow:(month - 1) inComponent:0];
		}
		else {
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"MM"];
			int date = [[dateFormatter stringFromDate:[NSDate date]] intValue];
			[dateFormatter release];
			[reviewVisited selectRow:(date - 1) inComponent:0 animated:NO];
			[self pickerView:reviewVisited didSelectRow:(date - 1) inComponent:0];
		}
		
		reviewTitle.text = [previousReview objectForKey:@"r_title"];
		reviewText.text = [NSString filterString:[previousReview objectForKey:@"r_text"]];
		[reviewRating setValue:[[previousReview objectForKey:@"r_rating"] floatValue]];
		
	}
	else {
		[reviewVisited selectRow:11 inComponent:1 animated:NO];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MM"];
		int date = [[dateFormatter stringFromDate:[NSDate date]] intValue];
		[dateFormatter release];
		[reviewVisited selectRow:(date - 1) inComponent:0 animated:NO];
		[self pickerView:reviewVisited didSelectRow:(date - 1) inComponent:0];
		[self pickerView:reviewVisited didSelectRow:11 inComponent:1];
	}
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAndClose)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	self.navigationItem.rightBarButtonItem = nil;

}


- (void)submitReviewAndClose
{
	if (reviewDelegate) {
		if ([reviewDelegate respondsToSelector:@selector(willCloseReviewViewController:)]) {
			[reviewDelegate willCloseReviewViewController:self];
		}
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)cancelAndClose
{
	if (reviewDelegate) {
		if ([reviewDelegate respondsToSelector:@selector(willCancelReviewViewController:)]) {
			[reviewDelegate willCancelReviewViewController:self];
		}
	}
	
	[self dismissModalViewControllerAnimated:YES];
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
	self.reviewRating = nil;
	self.reviewTitle = nil;
	self.reviewText = nil;
	self.reviewVisited = nil;
	self.previousReview = nil;
	self.reviewDelegate = nil;
	[dateFormatterY release];
    [super dealloc];
}

- (IBAction)resignReviewTitle
{
	if ([[reviewText text] length] > 0 && [[reviewTitle text] length] > 0) {
		UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitReviewAndClose)];
		self.navigationItem.rightBarButtonItem = submitButton;
		[submitButton release];
	} else {
		self.navigationItem.rightBarButtonItem = nil;;
	}
	
	[reviewTitle resignFirstResponder];
	[reviewText becomeFirstResponder];
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([[textView text] length] < 1 && [[reviewTitle text] length] < 1) {
		self.navigationItem.rightBarButtonItem = nil;
	}
	
	if([text isEqualToString:@"\n"])
	 {
		[textView resignFirstResponder];
		if ([[textView text] length] > 0 && [[reviewTitle text] length] > 0) {
			UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitReviewAndClose)];
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
	
	if ([[reviewText text] length] > 0 && [[reviewTitle text] length] > 0) {
		UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitReviewAndClose)];
		self.navigationItem.rightBarButtonItem = submitButton;
		[submitButton release];
	} else {
		self.navigationItem.rightBarButtonItem = nil;;
	}
	
}



@end
