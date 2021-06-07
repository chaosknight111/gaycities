//
//  GCDetailsRegularsViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/17/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCDetailsRegularsViewController.h"
#import "GCListingPeopleCell.h"
#import "GCProfileWebViewController.h"
#import "GayCitiesAppDelegate.h"
#import "GCPerson.h"
#import "GCCommunicator.h"

@implementation GCDetailsRegularsViewController

@synthesize mainTableView, regulars;

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
	 UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	 titleView.contentMode = UIViewContentModeScaleAspectFit;
	 titleView.frame = CGRectMake(90, 0, 140, 30);
	 self.navigationItem.titleView = titleView;
	 [titleView release];
	mainTableView.backgroundColor = [UIColor clearColor];
}
-(void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	
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


- (void)dealloc {
	self.mainTableView = nil;
    [super dealloc];
}


- (void)openProfilePageForUser:(NSString *)username
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gaycities.com/reviewer/%@?iphone=1",username]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	GCProfileWebViewController	*webViewController = [[GCProfileWebViewController alloc] init];
	GCCommunicator *communicator = [GCCommunicator sharedCommunicator];
	if (communicator.ul.currentLoginStatus) {
		NSString *string = [NSString stringWithFormat:@"%@|%@", communicator.ul.gcLoginUsername, communicator.ul.authToken];
		NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
									@"gaycities.com", NSHTTPCookieDomain,
									@"\\", NSHTTPCookiePath,  // IMPORTANT!
									@"appsignedin", NSHTTPCookieName,
									string, NSHTTPCookieValue,
									nil];
		
		
		NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
		NSArray *cookies = [NSArray arrayWithObjects:cookie, nil];
		
		NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
		
		[request setAllHTTPHeaderFields:headers];
	}
	webViewController.profileRequest = request;
	[[self navigationController] pushViewController:webViewController animated:YES];
	[webViewController release];
	[request release];
}


#pragma mark tableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (regulars) {
		return [regulars count];
	}
	return 0;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	return @"";
 
 }


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	int row = [indexPath row];
		

	GCListingPeopleCell *cell  = (GCListingPeopleCell *)[tableView dequeueReusableCellWithIdentifier:@"listingPeopleCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingPeopleCell" owner:self options:nil];
		cell = [[[nib objectAtIndex:0] retain] autorelease];
		
	}
	GCPerson *person = [regulars objectAtIndex:row];
	cell.person = person;
	cell.profileImage.image = nil;//person.profileImage;
	[cell loadImage];
	
	cell.userName.text = [person.user  objectForKey:@"username"];
	//cell.profileImage.image = person.profileImage;
	cell.userDetails.text = [NSString stringWithFormat:@"%@/%@", [person.user objectForKey:@"u_age"], [person.user objectForKey:@"u_gender"]];
	cell.shout.text = @"";
	cell.checkinDate.text = @"";
	

	
	
	return cell;					

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	
	[self openProfilePageForUser:[[(GCPerson *)[regulars objectAtIndex:[indexPath row]] user] objectForKey:@"username"]];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
