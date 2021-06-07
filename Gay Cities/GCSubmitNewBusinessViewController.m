//
//  SubmitNewBuisnessViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 2/5/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCSubmitNewBusinessViewController.h"
#import "GCUILabelExtras.h"
#import "GCLoginFieldCell.h"

@implementation GCSubmitNewBusinessViewController

@synthesize metroName, listingType, businessName, add_street, add_city, add_state, add_zip, phone, url, neighborhood_id;
@synthesize listingTypes, neighborhoodNames;
@synthesize gcDelegate;
@synthesize mainTable;
@synthesize metro;

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
	cells = [[NSMutableSet alloc] init];
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	self.title = @"Submit";
	typeChoosing = -1;
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	//mainTable.backgroundColor = [UIColor colorWithRed:.706 green:.792 blue:.867 alpha:1];
	
	if (metro) {
		if ([metro.metro_name length] > 0) {
			self.metroName = metro.metro_name;
			self.add_city = metro.metro_name;
		}
		if ([metro.metro_state length] > 0) {
			self.add_state = metro.metro_state;
		}
	}
	
	mainTable.backgroundColor = [UIColor clearColor];
	mainTable.frame = CGRectMake(0, 0, 320, 416);
	self.listingType = @"";
	
	if (!listingTypes) {
		listingTypes = [[NSArray alloc] init];
	} else {
		for (NSString *aName in listingTypes) {
			if ([aName isEqualToString:@"Bars"]) {
				self.listingType = @"Bars";
				break;
			}
		}
		if ([listingType length] == 0) {
			self.listingType = [listingTypes objectAtIndex:0];
		}
	}
	
	if (!neighborhoodNames) {
		neighborhoodNames = [[NSArray alloc] init];
	}
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSubmitBusiness)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	currentSender = nil;
	previousSender = nil;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if ([businessName length] > 0 && [listingType length] > 0) {
		[self showSubmitButton:YES];
	} else {
		[self showSubmitButton:NO];
	}
}

- (void)showSubmitButton:(BOOL)shouldShow
{
	if (shouldShow) {
		UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone	target:self action:@selector(processSubmitBusiness)];
		self.navigationItem.rightBarButtonItem = submitButton;
		[submitButton release];
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[mainTable reloadData];


}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	//mainTable.frame = CGRectMake(0, 0, 320, 283);

}
 

 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
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

- (void)willCloseAlertTableWithChoiceViewController:(GCAlertTableWithChoiceView *)viewController
{
	if (typeChoosing == GCSubmitListingType) {
		if (viewController.selectedRow >= 0 && viewController.selectedRow < [listingTypes count]) {
			self.listingType = [[listingTypes objectAtIndex:viewController.selectedRow] capitalizedString];
			[mainTable reloadData];
		}
	} else if (typeChoosing == GCSubmitNeighborhoodName) {
		if (viewController.selectedRow >= 0 && viewController.selectedRow < [neighborhoodNames count]) {
			self.neighborhood_id = [neighborhoodNames objectAtIndex:viewController.selectedRow];
			[mainTable reloadData];
		} else {
			self.neighborhood_id = @"";
		}
	}
}


- (IBAction)cancelSubmitBusiness
{
	if (currentSender && [currentSender canResignFirstResponder]) {
		previousSender = currentSender;
		[(UITextField *)currentSender resignFirstResponder];
		mainTable.frame = CGRectMake(0, 0, 320, 416);
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated:NO];
	}
	[self.navigationController dismissModalViewControllerAnimated:YES];
	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCancelSumbitNewBusinessViewController:)]) {
			[gcDelegate willCancelSumbitNewBusinessViewController:self];
		}
	}
}

- (IBAction)processSubmitBusiness
{
	if (currentSender && [currentSender canResignFirstResponder]) {
		previousSender = currentSender;
		[(UITextField *)currentSender resignFirstResponder];
		mainTable.frame = CGRectMake(0, 0, 320, 416);
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated:NO];
	}
	
	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCloseSumbitNewBusinessViewController:)]) {
			[gcDelegate willCloseSumbitNewBusinessViewController:self];
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
    if ([neighborhoodNames count] > 0) {
		return 9;
	}
	return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	
	return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	
	
	UILabel *label = [UILabel gcLabelForTableHeaderView];
	
	
	label.text = @"Tell us as much as you know:";
	return label;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	int row = [indexPath row] + 100;
	GCLoginFieldCell *cell = (GCLoginFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"loginFieldCell"];
	if ([cells count] == 0) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSubmitFieldCell" owner:self options:nil];
		cell = [[[nib objectAtIndex:0] retain] autorelease];
		[cell.textField addTarget:self action:@selector(retainYourself:) forControlEvents:UIControlEventEditingDidBegin];
		[cell.textField addTarget:self action:@selector(saveInformation:) forControlEvents:UIControlEventEditingDidEndOnExit];
		//[cell.textField addTarget:self action:@selector(saveInformation:) forControlEvents:UIControlEventEditingDidEnd];
		cell.tag = row;
		cell.textField.tag = row;
		[cells addObject:cell];
	} else {
		BOOL found = NO;
		for (GCLoginFieldCell *aCell in [cells allObjects]) {
			if (aCell.tag == row) {
				cell = aCell;
				found = YES;
				break;
			}
		}
		if (!found) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSubmitFieldCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
			[cell.textField addTarget:self action:@selector(retainYourself:) forControlEvents:UIControlEventEditingDidBegin];
			[cell.textField addTarget:self action:@selector(saveInformation:) forControlEvents:UIControlEventEditingDidEndOnExit];
			//[cell.textField addTarget:self action:@selector(saveInformation:) forControlEvents:UIControlEventEditingDidEnd];
			cell.tag = row;
			cell.textField.tag = row;
			[cells addObject:cell];
		}
	}
	
	
	
	switch (row) {
		case GCSubmitBusinessName:
		{
			cell.fieldLabel.text = @"Name:";
			cell.textField.placeholder = @"Business Name";
			if (businessName) {
				cell.textField.text = businessName;
			} else {
				cell.textField.text = @"";
			}
			//if ([cell.textField.text length] == 0) {
			//	[cell.textField becomeFirstResponder];
			//}
			cell.textField.returnKeyType = UIReturnKeyNext;
			cell.textField.userInteractionEnabled = YES;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
		case GCSubmitListingType:
		{
			cell.fieldLabel.text = @"Category:";
			cell.textField.placeholder = @"Category";
			if (listingType) {
				cell.textField.text = listingType;
			} else {
				cell.textField.text = @"";
			}
			cell.textField.userInteractionEnabled = NO;
			cell.textField.returnKeyType = UIReturnKeyNext;
			if ([listingTypes count] > 0) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			
		}
			break;
		case GCSubmitPhone:
		{
			cell.fieldLabel.text = @"Phone:";
			cell.textField.placeholder = @"Phone Number (Optional)";
			if (phone) {
				cell.textField.text = phone;
			} else {
				cell.textField.text = @"";
			}
			cell.textField.returnKeyType = UIReturnKeyNext;
			cell.textField.userInteractionEnabled = YES;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
		case GCSubmitAddStreet:
		{
			cell.fieldLabel.text = @"Street:";
			cell.textField.placeholder = @"Street (Optional)";
			if (add_street) {
				cell.textField.text = add_street;
			} else {
				cell.textField.text = @"";
			}
			cell.textField.returnKeyType = UIReturnKeyNext;
			cell.textField.userInteractionEnabled = YES;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
		case GCSubmitAddCity:
		{
			cell.fieldLabel.text = @"City:";
			cell.textField.placeholder = @"City (Optional)";
			if (add_city) {
				cell.textField.text = add_city;
			} else {
				cell.textField.text = @"";
			}
			cell.textField.returnKeyType = UIReturnKeyNext;
			cell.textField.userInteractionEnabled = YES;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
		case GCSubmitAddState:
		{
			cell.fieldLabel.text = @"State:";
			cell.textField.placeholder = @"State";
			if (add_state) {
				cell.textField.text = add_state;
			} else {
				cell.textField.text = @"";
			}
			cell.textField.returnKeyType = UIReturnKeyNext;
			cell.textField.userInteractionEnabled = NO;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
		case GCSubmitAddZip:
		{
			cell.fieldLabel.text = @"Zip:";
			cell.textField.placeholder = @"Postal Code (Optional)";
			if (add_zip) {
				cell.textField.text = add_zip;
			} else {
				cell.textField.text = @"";
			}
			cell.textField.returnKeyType = UIReturnKeyNext;
			cell.textField.userInteractionEnabled = YES;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
		case GCSubmitURL:
		{
			cell.fieldLabel.text = @"URL:";
			cell.textField.placeholder = @"Website Address (Optional)";
			if (url) {
				cell.textField.text = url;
			} else {
				cell.textField.text = @"";
			}
			cell.textField.returnKeyType = UIReturnKeyDone;
			cell.textField.userInteractionEnabled = YES;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
			break;
		case GCSubmitNeighborhoodName:
		{
			cell.fieldLabel.text = @"Where?:";
			cell.textField.placeholder = @"Neighborhood (Optional)";
			if (neighborhood_id) {
				cell.textField.text = neighborhood_id;
			} else {
				cell.textField.text = @"";
			}
			cell.textField.userInteractionEnabled = NO;
			if ([neighborhoodNames count] > 0) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
		}
			break;
	}
	
	
	

	
	return cell;
	
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (row == 1) {
		if (currentSender) {
			[self saveInformation:currentSender];
			previousSender = currentSender;
			[previousSender resignFirstResponder];
			mainTable.frame = CGRectMake(0, 0, 320, 416);
			currentSender = nil;
			previousSender = nil;
		}

		typeChoosing = GCSubmitListingType;
		GCAlertTableWithChoiceView *atwcv = [[GCAlertTableWithChoiceView alloc] init];
		for (NSString *typeName in listingTypes) {
			if ([[typeName capitalizedString] isEqualToString:listingType]) {
				atwcv.selectedRow = [listingTypes indexOfObject:typeName];
				break;
			}
		}
		atwcv.choices = listingTypes;
		atwcv.gcDelegate = self;
		[self.navigationController pushViewController:atwcv animated:YES];
		[atwcv release];
	} else if (row == 8) {
		if (currentSender) {
			[self saveInformation:currentSender];
			previousSender = currentSender;
			[previousSender resignFirstResponder];
			mainTable.frame = CGRectMake(0, 0, 320, 416);
			currentSender = nil;
			previousSender = nil;
		}
		typeChoosing = GCSubmitNeighborhoodName;
		GCAlertTableWithChoiceView *atwcv = [[GCAlertTableWithChoiceView alloc] init];
		atwcv.choices = neighborhoodNames;
		atwcv.gcDelegate = self;
		[self.navigationController pushViewController:atwcv animated:YES];
		[atwcv release];
	}
	[mainTable deselectRowAtIndexPath:indexPath animated:YES];
	
}


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

- (void)retainYourself:(id)sender
{
	if (mainTable.frame.size.height != 205) {
		mainTable.frame = CGRectMake(0, 0, 320, 205);
	}
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[(UITextField *)sender tag] - 100 inSection:0];
	[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionMiddle animated:YES];
	//[sender becomeFirstResponder];
	if (currentSender) {
		id oldSender = currentSender;
		currentSender = sender;
		[self saveInformation:oldSender];
	} else {
		currentSender = sender;
	}
}

- (void)saveInformation:(id)sender
{

	int row = [(UITextField *)sender tag];

	if (previousSender == sender) {
		return;
	}
	previousSender = sender;
	switch (row) {
		case GCSubmitBusinessName: //0
		{
			self.businessName = [(UITextField *)sender text];

			if ([sender canResignFirstResponder]) {
				[(UITextField *)sender resignFirstResponder];
				
				if (currentSender == previousSender) {
					currentSender = nil;
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
					//[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated:YES];
					GCLoginFieldCell *cell = (GCLoginFieldCell *)[mainTable cellForRowAtIndexPath:indexPath];
					[cell.textField becomeFirstResponder];
				}
				
			}
		}
			break;
		case GCSubmitListingType: //1

			break;
		case GCSubmitPhone: //2
		{
			self.phone = [(UITextField *)sender text];

			if ([sender canResignFirstResponder]) {
				[(UITextField *)sender resignFirstResponder];
				if (currentSender == previousSender) {
					currentSender = nil;
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
					//[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated:YES];
					GCLoginFieldCell *cell = (GCLoginFieldCell *)[mainTable cellForRowAtIndexPath:indexPath];
					[cell.textField becomeFirstResponder];
				}			}
		}
			break;
		case GCSubmitAddStreet: //3
		{
			self.add_street = [(UITextField *)sender text];

			if ([sender canResignFirstResponder]) {
				[(UITextField *)sender resignFirstResponder];
				if (currentSender == previousSender) {
					currentSender = nil;
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
					//[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated:YES];
					GCLoginFieldCell *cell = (GCLoginFieldCell *)[mainTable cellForRowAtIndexPath:indexPath];
					[cell.textField becomeFirstResponder];
				}
			}
		}
			break;
		case GCSubmitAddCity: //4
		{
			self.add_city = [(UITextField *)sender text];

			if ([sender canResignFirstResponder]) {
				[(UITextField *)sender resignFirstResponder];
				if (currentSender == previousSender) {
					currentSender = nil;
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:6 inSection:0];
					//[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated:YES];
					GCLoginFieldCell *cell = (GCLoginFieldCell *)[mainTable cellForRowAtIndexPath:indexPath];
					[cell.textField becomeFirstResponder];
				}
			}
		}
			break;
		case GCSubmitAddState: //5
		{
			self.add_state = [(UITextField *)sender text];

			if ([sender canResignFirstResponder]) {
				NSLog(@"save add_state?");
				[(UITextField *)sender resignFirstResponder];
				if (currentSender == previousSender) {
					currentSender = nil;
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:6 inSection:0];
					//[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated:YES];
					GCLoginFieldCell *cell = (GCLoginFieldCell *)[mainTable cellForRowAtIndexPath:indexPath];
					[cell.textField becomeFirstResponder];
				}
			}
		}
			break;
		case GCSubmitAddZip: //6
		{
			self.add_zip = [(UITextField *)sender text];

			if ([sender canResignFirstResponder]) {
				[(UITextField *)sender resignFirstResponder];
				if (currentSender == previousSender) {
					currentSender = nil;
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:7 inSection:0];
					//[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated:YES];
					GCLoginFieldCell *cell = (GCLoginFieldCell *)[mainTable cellForRowAtIndexPath:indexPath];
					[cell.textField becomeFirstResponder];
				}
			}
		}
			break;
		case GCSubmitURL: //7
		{
			if ([sender canResignFirstResponder]) {
				currentSender = nil;
				[(UITextField *)sender resignFirstResponder];
				mainTable.frame = CGRectMake(0, 0, 320, 416);
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
				[mainTable scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated:YES];
			}
			self.url = [(UITextField *)sender text];
			
			
		}
			break;
		case GCSubmitNeighborhoodName: //8
		{
			NSLog(@"save neighborhood?");

		}
			break;
	}

	
	if ([businessName length] > 0 && [listingType length] > 0) {
		[self showSubmitButton:YES];

	} else {
		[self showSubmitButton:NO];

	}
}





- (void)dealloc {
	self.metroName = nil;
	self.listingType = nil;
	self.businessName = nil;
	self.add_street = nil;
	self.add_city = nil;
	self.add_state = nil;
	self.add_zip = nil;
	self.phone = nil;
	self.url = nil;
	self.neighborhood_id = nil;
	self.listingTypes = nil;
	self.neighborhoodNames = nil;
	currentSender = nil;
	previousSender = nil;
	[cells removeAllObjects];
	[cells release];
	self.mainTable = nil;
	self.metro = nil;
    [super dealloc];
}


@end
