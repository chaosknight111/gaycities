//
//  GCLoginViewConroller.m
//  Gay Cities
//
//  Created by Brian Harmann on 2/4/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCLoginViewConroller.h"
#import "OCConstants.h"
#import "GCLoginFieldCell.h"
#import "GCUILabelExtras.h"
#import "GayCitiesAppDelegate.h"

@implementation GCLoginViewConroller

@synthesize usernameText, passwordText, mainTable, gcDelegate, headerText, passwordField;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder{
	if (self = [super init]) {
		headerText = [[NSString alloc] init];
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	passwordField = nil;
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	self.title = @"Login";

	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationController.navigationBar.topItem.titleView = titleView;
	[titleView release];
	//mainTable.backgroundColor = [UIColor colorWithRed:.706 green:.792 blue:.867 alpha:1];
	mainTable.backgroundColor = [UIColor clearColor];
	usernameText = [[NSString alloc] init];
	passwordText = [[NSString alloc] init];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelLogin)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)cancelLogin
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCancelLoginViewController:)]) {
			[gcDelegate willCancelLoginViewController:self];
		}
	}
}

- (IBAction)saveAndCloseLogin
{
	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCloseLoginViewController:)]) {
			[gcDelegate willCloseLoginViewController:self];
		}
	}
	[self.navigationController dismissModalViewControllerAnimated:YES];

}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	
	return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	
			
	UILabel *label = [UILabel gcLabelForTableHeaderView];
			
	if ([headerText length] > 0) {
		label.text = headerText;
	} else {
		label.text = @"Please enter your login information";
	}
	return label;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if ([indexPath row] == 0) {
		GCLoginFieldCell *cell  = (GCLoginFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"loginFieldCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCLoginFieldCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
			[cell.textField becomeFirstResponder];
			[cell.textField addTarget:self action:@selector(resignUsername:) forControlEvents:UIControlEventEditingDidEndOnExit];  //
			[cell.textField addTarget:self action:@selector(saveUsername:) forControlEvents:UIControlEventEditingDidEnd];
		}
		
		// Set up the cell...
		
		return cell;
	}
	GCLoginFieldCell *cell  = (GCLoginFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"loginFieldCellPassword"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCLoginFieldCellPassword" owner:self options:nil];
		cell = [[[nib objectAtIndex:0] retain] autorelease];
		[cell.textField addTarget:cell.textField action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];  //
		[cell.textField addTarget:self action:@selector(savePassword:) forControlEvents:UIControlEventEditingDidEnd];
		cell.textField.returnKeyType = UIReturnKeyGo;
	}
	self.passwordField = cell.textField;
	
	return cell;

    
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
//}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
			

- (void)saveUsername:(id)sender
{
	if (usernameText) {
		if ([usernameText isEqualToString:[(UITextField *)sender text]]) {
			return;
		}
	}

	self.usernameText = [(UITextField *)sender text];
	if ([usernameText length] > 0 && [passwordText length] > 0) {
		UIBarButtonItem *signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:self action:@selector(saveAndCloseLogin)];
		self.navigationItem.rightBarButtonItem = signInButton;
		[signInButton release];
		
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
	
	if (passwordField) {
		if (![passwordField isFirstResponder]) {
			[passwordField becomeFirstResponder];
			
		}
	}
	
}

- (void)resignUsername:(id)sender
{
	if (passwordField) {
		if (![passwordField isFirstResponder]) {
			[passwordField becomeFirstResponder];
			
		}
	}
}

- (void)savePassword:(id)sender
{
	//[(UITextField *)sender resignFirstResponder];
	self.passwordText = [(UITextField *)sender text];
	if ([usernameText length] > 0 && [passwordText length] > 0) {
		UIBarButtonItem *signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:self action:@selector(saveAndCloseLogin)];
		self.navigationItem.rightBarButtonItem = signInButton;
		[signInButton release];
		[self saveAndCloseLogin];
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
}

- (void)dealloc {
	self.usernameText = nil;
	self.passwordText = nil;
	self.mainTable = nil;
	self.gcDelegate = nil;
	self.headerText = nil;
	self.passwordField = nil;
    [super dealloc];
}


@end

