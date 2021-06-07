//
//  GCAlertTableWithChoiceView.m
//  Gay Cities
//
//  Created by Brian Harmann on 2/7/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCAlertTableWithChoiceView.h"
#import "GCGeneralTextCell.h"

@implementation GCAlertTableWithChoiceView

@synthesize choices;
@synthesize gcDelegate;
@synthesize selectedRow;
@synthesize mainTable;

- (id)init 
{
	if (self = [super init]) {
		choices = [[NSArray alloc] init];
		selectedRow = -1;
	}
	return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Choose";
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	mainTable.backgroundColor = [UIColor clearColor];
    
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (gcDelegate) {
		if ([gcDelegate respondsToSelector:@selector(willCloseAlertTableWithChoiceViewController:)]) {
			[gcDelegate willCloseAlertTableWithChoiceViewController:self];
		}
	}
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [choices count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GCGeneralTextCell *cell  = (GCGeneralTextCell *)[tableView dequeueReusableCellWithIdentifier:@"generalTextCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCGeneralTextCell" owner:self options:nil];
		cell = [[[nib objectAtIndex:0] retain] autorelease];
		cell.cellLabel.font = [UIFont boldSystemFontOfSize:15];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	cell.cellLabel.text = [choices objectAtIndex:[indexPath row]];
	if ([indexPath row] == selectedRow) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    // Set up the cell...
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedRow = [indexPath row];
	[tableView reloadData];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


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


- (void)dealloc {
	self.choices = nil;
	self.mainTable = nil;
    [super dealloc];
}


@end

