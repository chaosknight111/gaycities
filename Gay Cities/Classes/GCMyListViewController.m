//
//  MyListViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/28/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCMyListViewController.h"
#import "GCDetailViewController.h"
#import "GayCitiesAppDelegate.h"
#import "GCGeneralTextCell.h"
#import "GCUILabelExtras.h"

@implementation GCMyListViewController

@synthesize myList, mainTableView;
@synthesize communicator;


- (id)init
{
	if (self = [super init]) {
		self.communicator = [GCCommunicator sharedCommunicator];
	}
	return self;
}



- (void)viewDidLoad {
	[super viewDidLoad];
	
	
}



- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//[self.navigationController setNavigationBarHidden:NO];
	if (!communicator.listings.bookmarksLoaded) {
		[communicator.listings loadBookmarks];
	}
	
	self.myList = communicator.listings.myList;
	[self setTitle:@"My List"];
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	mainTableView.backgroundColor = [UIColor colorWithRed:.706 green:.792 blue:.867 alpha:1];

	
	self.navigationItem.hidesBackButton = YES;
	UIBarButtonItem *clearBookmarks = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearBookmarks)];
	self.navigationItem.leftBarButtonItem = clearBookmarks;
	[clearBookmarks release];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	[mainTableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {

}


- (void)dealloc {
	self.mainTableView = nil;
    [super dealloc];
}


-(void)clearBookmarks
{
	UIActionSheet *clearAction = [[UIActionSheet alloc] initWithTitle:@"Clear:" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@"All Bookmarks",@"All Recents", @"Both", nil];
	
	[clearAction showInView:[[GayCitiesAppDelegate sharedAppDelegate] window]];
	[clearAction release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==1) {
		[myList deleteAllBookmarks];
	}
	else if (buttonIndex==2) {
		[myList deleteAllRecents];

	}
	else if (buttonIndex==3) {
		[myList deleteAllBookmarks];
		[myList deleteAllRecents];

	}
	[mainTableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [myList.bookmarks count];

	} else if (section == 1) {
		return [myList.recents count];
	}
	
	return 0;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == 0) {
		return @"Bookmarks";
	}
	else if (section == 1) {
		return @"Recently Viewed";
	}
	return @"";
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

	return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		UILabel *label = [UILabel gcLabelForTableHeaderView];
		
		label.text = @"Bookmarks";
		return label;
	} else if (section == 1) {
		UILabel *label = [UILabel gcLabelForTableHeaderView];
		
		label.text = @"Recently Viewed";
		return label;	
	}
	
	return nil;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	GCGeneralTextCell *cell  = (GCGeneralTextCell *)[tableView dequeueReusableCellWithIdentifier:@"generalTextCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCGeneralTextCell" owner:self options:nil];
		cell = [[[nib objectAtIndex:0] retain] autorelease];
	}
    
	if ([indexPath section]==0) {
		cell.cellLabel.text = [[[myList.bookmarks objectAtIndex:[indexPath row]] name] filteredStringRemovingHTMLEntities];
	}
	else if ([indexPath section]==1) {
		cell.cellLabel.text = [[[myList.recents objectAtIndex:[indexPath row]] name] filteredStringRemovingHTMLEntities];
	}
   
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	if ([indexPath section] == 0) {
		//[communicator loadDetailsForListing:[myList.bookmarks objectAtIndex:[indexPath row]]];
		GCDetailViewController *dvc = [[GCDetailViewController alloc] init];
		//dvc.communicator = communicator;
		dvc.listing = (GCListing *)[myList.bookmarks objectAtIndex:[indexPath row]];
		[self.navigationController pushViewController:dvc animated:YES];
		[dvc release];
	}
	else if ([indexPath section] == 1) {
		//[communicator loadDetailsForListing:[myList.recents objectAtIndex:[indexPath row]]];
		GCDetailViewController *dvc = [[GCDetailViewController alloc] init];
		//dvc.communicator = communicator;
		dvc.listing = (GCListing *)[myList.recents objectAtIndex:[indexPath row]];
		[self.navigationController pushViewController:dvc animated:YES];
		[dvc release];

	}

	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		int x = [indexPath row];
		if ([indexPath section] == 0) {
			[myList deleteBookmark:[[myList.bookmarks objectAtIndex:x] listing_id] withType:[[myList.bookmarks objectAtIndex:x] type] andOrderNum:x];
		}	
		else if ([indexPath section]==1) {
			[myList deleteRecent:[[myList.recents objectAtIndex:x] listing_id] withType:[[myList.recents objectAtIndex:x] type] andOrderNum:x];

			
		}
		[mainTableView reloadData];
		
		
	}   
	if (editingStyle == UITableViewCellEditingStyleInsert) {
	}   
}





- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

	return YES;
	
}




- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	if ([fromIndexPath section] != [toIndexPath section]) {
		//tableView.editing = NO;
		//[browseTable reloadData];
		//[searchTable reloadData];
		return;
	}
	
	if ([fromIndexPath section] ==0) {
		[myList moveBookmarkFrom:[fromIndexPath row] to:[toIndexPath row]];
		
	}
	else if ([fromIndexPath section] ==1) {
		[myList moveRecentFrom:[fromIndexPath row] to:[toIndexPath row]];

		
	}
		
	//[mainTableView reloadData];
	
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if ([sourceIndexPath section] == [proposedDestinationIndexPath section]) {
		return proposedDestinationIndexPath;
	} 
	
	return sourceIndexPath;

}




- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[mainTableView setEditing:editing animated:animated];
	
}


@end
