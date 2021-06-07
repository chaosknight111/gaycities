//
//  EventsViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/1/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCEventsViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "DDXML.h"
#import "GCEventViewController.h"
#import "GayCitiesAppDelegate.h"
#import "GCUserLogin.h"
#import "GCEventsCell.h"
#import "GCEventSummary.h"
#import "GCCityChangeViewController.h"
#import "GCUILabelExtras.h"
#import "UIImage+Resize.h"
#import "GCEventGroup.h"
#import "UIImage+RoundedCorner.h"
#import "GCPopularEventsView.h"
#import "GCAddEventsFacebookViewController.h"

@implementation GCEventsViewController

@synthesize eventsTable;
@synthesize communicator;
@synthesize eventsController;
@synthesize gcad;
@synthesize processingView, activityView;


- (id)init
{
	if (self = [super init]) {
		self.communicator = [GCCommunicator sharedCommunicator];
		communicator.eventDelegate = self;
	}
	return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  self.gcad = [GayCitiesAppDelegate sharedAppDelegate];
  popularListShown = NO;
	self.title = @"Events";
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	//[FlurryAPI logEvent:@"EVENTS_VIEWED"];
	[gcad logEventForFlurry:@"EVENTS_LIST_VIEWED" withParameters:nil];
	self.navigationItem.hidesBackButton = YES;
  
  UIBarButtonItem *cityChangeButton = [[UIBarButtonItem alloc] initWithTitle:@"Pick City" style:UIBarButtonItemStylePlain target:self action:@selector(changeCityNow)];
  self.navigationItem.rightBarButtonItem = cityChangeButton;
  [cityChangeButton release];
  
  self.eventsController = communicator.listings.eventsController;
  //[self updateTableHeaderText];

}

- (void)updateTableHeaderText
{
  UILabel *headerText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
	headerText.backgroundColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
	headerText.textColor = [UIColor whiteColor];
	headerText.textAlignment = UITextAlignmentCenter;
	headerText.font = [UIFont boldSystemFontOfSize:18];
  headerText.shadowColor = [UIColor blackColor];
  headerText.shadowOffset = CGSizeMake(0, 1);
  headerText.text = [NSString stringWithFormat:@"%@ Events", communicator.metros.currentMetro.metro_name];
  if ([eventsController.popularEvents count] > 1) {
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 124)];
    aView.backgroundColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
    [aView addSubview:headerText];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 24, 320, 100)];
    scrollView.backgroundColor = [UIColor clearColor];
    float width = 10 + (155 * [eventsController.popularEvents count]);
    scrollView.contentSize = CGSizeMake(width, 100);
    int count = 0;
    for (GCEventSummary *event in eventsController.popularEvents) {
      int x = (count * 155) + 5;
      if (count == 0) {
        x = x + 5;
      }
      GCPopularEventsView *imageView = [[GCPopularEventsView alloc] initWithFrame:CGRectMake(x, 0, 145, 100)];
      imageView.event = event;
      [scrollView addSubview:imageView];
      [imageView release];
      count ++;
    }
    [aView addSubview:scrollView];
    [scrollView release];
    
    eventsTable.tableHeaderView = aView;
    [aView release];

  } else {
    eventsTable.tableHeaderView = headerText;
  }
	[headerText release];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	communicator.eventDelegate = self;

	
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
  [self updateTableHeaderText];
//  [eventsTable reloadData];
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
	communicator.eventDelegate = nil;

}


- (void)dealloc {
	[eventsTable release];
	self.eventsController = nil;
  self.processingView = nil;
  self.activityView = nil;
  [super dealloc];
}


#pragma mark ChangeCity delegates

- (void)changeCityNow {

	[communicator.locationMgr stopUpdatingLocation];
	if (communicator.noInternet) {
		UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:@"Since there appears to be no network connection, the current city cannot be changed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noInternetAlert show];
		[noInternetAlert release];
		return;
	}
	//NSLog(@"Change City");
	GCCityChangeViewController *cvc = [[GCCityChangeViewController alloc] init];
	cvc.viewType = optionalSelectionViewType;
	cvc.instructionText = @"";
	cvc.delegate = self;
	
	
	gcad.adBackgroundView.hidden = YES;
	gcad.shouldShowAdView = NO;
	gcad.mainTabBar.hidden = YES;
  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:cvc];
  [cvc release];
  
	[self.navigationController presentModalViewController:nc animated:YES];
	[nc release];
}


- (void)cityViewDidSelectMetro:(GCMetro *)newMetro;
{

	[communicator locateCity:newMetro];
	NSLog(@"EVENTS - cityViewDidSelectMetro - metro ID: %@", newMetro.metro_id);
	
	[self dismissModalViewControllerAnimated:YES];
	gcad.adBackgroundView.hidden = NO;
	gcad.shouldShowAdView = YES;
	gcad.mainTabBar.hidden = NO;
//	if (communicator.currentlyUpdatingListings) {
//    [self showProcessing];
//  } else {
//    [self hideProcessing];
//  }
}

- (void)cityViewDidCancel
{
	[self dismissModalViewControllerAnimated:YES];
	gcad.adBackgroundView.hidden = NO;
	gcad.mainTabBar.hidden = NO;
	gcad.shouldShowAdView = YES;
  
	
	//NSLog(@"cancel");
}

- (void)cityViewDidSelectNearby
{

	[communicator findMe:GCLocationSearchGlobal];
	[self dismissModalViewControllerAnimated:YES];
	gcad.adBackgroundView.hidden = NO;
	gcad.mainTabBar.hidden = NO;
	gcad.shouldShowAdView = YES;
  
  if (communicator.currentlyUpdatingListings) {
    [self showProcessing];
  } else {
    [self hideProcessing];
  }
	//NSLog(@"nearby");
	
}


#pragma mark Misc

- (void)showProcessing
{
	processingView.hidden = NO;
	[activityView startAnimating];
}

- (void)hideProcessing
{
  if (!processingView.hidden) {
    [activityView stopAnimating];
    processingView.hidden = YES;
  }
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  int extraRow = 0;
  if (!gcad.connectController.hasSavedFacebook && !gcad.connectController.fbExtendedPermission) {
		extraRow = 1;
	}
  return  [eventsController.eventGroups count] > 0 ? [eventsController.eventGroups count] + extraRow : 1 + extraRow;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  int count = [eventsController.eventGroups count];
  
  if ((section == count && count > 0)  || (count == 0 && section == 1)) {
    return 1;
  }
  return count > 0 ? [[[eventsController.eventGroups objectAtIndex:section] events] count] : 0;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  int count = [eventsController.eventGroups count];
  if (count == 0 && section == 0 ) {
    UILabel *label = [UILabel gcLabelWhiteForTableHeaderView];
    label.text = self.communicator.currentlyUpdatingListings ? @"Updating..." : @"\nThere are currently no events\nin this area";
    return label;

  } else if ((section == count && count > 0)  || (count == 0 && section == 1)) {
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  } else {
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)] autorelease];
		headerView.backgroundColor = [UIColor colorWithHue:0.577 saturation:0.186 brightness:0.867 alpha:1.000];
    UILabel *label = [UILabel gcLabelClearForTableHeaderView];
    label.textColor = [UIColor blackColor];
    label.text = [[eventsController.eventGroups objectAtIndex:section] title];
    [headerView addSubview:label];
		return headerView;	
  }
  
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];  
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int count = [eventsController.eventGroups count];

  if (count == 0 && section == 0) {
    return 120;
  } else if ((section == count && count > 0)  || (count == 0 && section == 1)) {
	  return 0;
  }
  return 25;
}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return @"";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*int row = [indexPath row];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	CGSize reviewSize;
	CGSize constraint = CGSizeMake(304,2000);
	if ([[[events objectAtIndex:row] objectForKey:@"end"]timeIntervalSince1970] > [[[events objectAtIndex:row] objectForKey:@"start"]timeIntervalSince1970]) {
		reviewSize = [[NSString stringWithFormat:@"%@\nStart Date: %@\nEnd Date: %@", [[events objectAtIndex:row] objectForKey:@"name"], 
		 [dateFormatter stringFromDate:[[events objectAtIndex:row] objectForKey:@"start"]],
		 [dateFormatter stringFromDate:[[events objectAtIndex:row] objectForKey:@"end"]]] sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
	}
	else {
		reviewSize = [[NSString stringWithFormat:@"%@\nDate: %@", [[events objectAtIndex:row] objectForKey:@"name"], 
					   [dateFormatter stringFromDate:[[events objectAtIndex:row] objectForKey:@"start"]]] sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
	}
	
	[dateFormatter release];

	return 10 + reviewSize.height;*/
  int section = [indexPath section];
  int count = [eventsController.eventGroups count];
  
  if ((section == count && count > 0)  || (count == 0 && section == 1)) {
    return 44;
  }
	return 73;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	int row = [indexPath row];
  int section = [indexPath section];
  
  int count = [eventsController.eventGroups count];
  
  if ((section == count && count > 0)  || (count == 0 && section == 1)) {
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"addEventsFBCell"];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addEventsFBCell"] autorelease];
//      cell.textLabel.textAlignment = UITextAlignmentCenter;
//      cell.textLabel.font = [UIFont boldSystemFontOfSize:19];
//      cell.textLabel.textColor = [UIColor colorWithRed:.255 green:.302 blue:.396 alpha:1];
      UIImageView *iv = [[UIImageView alloc] initWithFrame:cell.bounds];
      iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      iv.contentMode = UIViewContentModeCenter;
      iv.backgroundColor = [UIColor clearColor];
      [cell addSubview:iv];
      iv.image = [UIImage imageNamed:@"addAnEventUnderlined.png"];
      [iv release];
    }
//    cell.textLabel.text = @"Add An Event";
    
    return cell;
  }
      
      
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE, MMM d"];
	[dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  unsigned unitFlags = NSYearCalendarUnit;

	
	GCEventsCell *cell  = (GCEventsCell *)[tableView dequeueReusableCellWithIdentifier:@"eventsCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCEventsCell" owner:self options:nil];
		cell = [[[nib objectAtIndex:0] retain] autorelease];
	}
	GCEventSummary *event = (GCEventSummary *)[[[eventsController.eventGroups objectAtIndex:section] events] objectAtIndex:row];
	cell.eventSummary = event;
	[cell loadImage];
	cell.eventTitle.text = [event eventName];
	
	NSMutableString *timeAndDate = [[NSMutableString alloc] init];

  [timeAndDate appendFormat:@"%@", [dateFormatter stringFromDate:[event startDate]]];
  
  NSDateComponents *comps = [calendar components:unitFlags fromDate: [event startDate]];
  int year = [comps year];
  if (year != communicator.year) {
    [timeAndDate appendFormat:@", %i", year];
  }
	
  if ([[event endDate] timeIntervalSinceReferenceDate] > [[event startDate] timeIntervalSinceReferenceDate]) {
    [timeAndDate appendFormat:@" - %@", [dateFormatter stringFromDate:[event endDate]]];
    
    NSDateComponents *comps2 = [calendar components:unitFlags fromDate: [event endDate]];
    int year2 = [comps2 year];
    if (year2 != communicator.year) {
      [timeAndDate appendFormat:@", %i", year2];
    }

  } else {
    NSString *hrs = [event eventHours];
    if (hrs && [hrs length] > 0) {
      [timeAndDate appendFormat:@", %@", hrs];
    }
  }
  
	
	cell.dates.text = timeAndDate;
	[timeAndDate release];
	int attending = [[event numAttending] intValue];
	if (attending < 1) {
		cell.numAttending.text = @"";
	} else if (attending == 1) {
		cell.numAttending.text = [NSString stringWithFormat:@"%i person is in", attending];
	} else {
		cell.numAttending.text = [NSString stringWithFormat:@"%i people are in", attending];
	}
		
	[dateFormatter release];
	
	//cell.eventTitle.font = [UIFont boldSystemFontOfSize:16];
	//cell.dates.font =  [UIFont systemFontOfSize:14];
	return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  int section = [indexPath section];
  int count = [eventsController.eventGroups count];
  
  if ((section == count && count > 0)  || (count == 0 && section == 1)) {
    GCAddEventsFacebookViewController *addEventsViewController = [[GCAddEventsFacebookViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:addEventsViewController];
    [addEventsViewController release];
    [self presentModalViewController:nc animated:YES];
    [nc release];

  } else {
    //NSLog(@"%@ %@", [[communicator.listings.events objectAtIndex:[indexPath row]] objectForKey:@"name"], [[communicator.listings.events objectAtIndex:[indexPath row]] objectForKey:@"event_id"]);
    
    [communicator loadEventDetails:[(GCEventSummary *)[[[eventsController.eventGroups objectAtIndex:[indexPath section]] events] objectAtIndex:[indexPath row]] event_id] processing:YES];
  }
 
 [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
 


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

#pragma mark Event Details




//Delegate methods for communicator

- (void)didLoadEventDetails:(NSMutableDictionary *)event
{
	
	if (event) {
		bool isAttending = NO;
		NSMutableDictionary *userStatus = [event objectForKey:@"userevent"];
		if (userStatus) {
			isAttending = [[userStatus objectForKey:@"isattending"] boolValue];
		}
//		NSLog(@"event dict: %@",event);

		GCEventViewController *evc = [[GCEventViewController alloc] init];
		//evc.communicator = communicator;
		evc.event = event;
		evc.isAttending = isAttending;
		if ([event objectForKey:@"photo_url"]) {
			UIImage *image = [[communicator peopleImages] objectForKey:[event objectForKey:@"photo_url"]];
			if (image) {
				[event setObject:image forKey:@"eventImage"];
				evc.eventPhoto = image;

			}
		}
		[self.navigationController pushViewController:evc animated:YES];
		[evc release];
	} else {
		//show error?
	}
	
}

- (void)didFailLoadEventDetails
{

	
}

#pragma mark Communicator delegates

- (void)didUpdateListings
{
  self.eventsController = communicator.listings.eventsController;
	[eventsTable reloadData];
  [self updateTableHeaderText];
  [self hideProcessing];
}

- (void)didUpdateMetros
{
	
}


- (void)didUpdateLocation
{
  self.eventsController = communicator.listings.eventsController;
  [self hideProcessing];
	[eventsTable reloadData];
  //[self updateTableHeaderText];

}

- (void)didChangeCurrentMetro
{
  self.eventsController = communicator.listings.eventsController;
  [self hideProcessing];
	[eventsTable reloadData];
  [self updateTableHeaderText];

}

- (void)noInternetErrorLocation
{
  [self hideProcessing];
//  [eventsTable reloadData];
//  [self updateTableHeaderText];
}

- (void)noInternetErrorListings
{
  self.eventsController = communicator.listings.eventsController;
  [self hideProcessing];
  [eventsTable reloadData];
  [self updateTableHeaderText];


}

- (void)locationError
{
  //[eventsTable reloadData];
  //[self updateTableHeaderText];


}



@end
