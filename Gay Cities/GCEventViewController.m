//
//  EventViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 6/1/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import "GCEventViewController.h"
#import "GayCitiesAppDelegate.h"
#import "GCEventDetailCell.h"
#import "GCDetailExtrasCell.h"
#import "OCWebViewController.h"
#import "OCMapViewController.h"
#import "GCPerson.h"
#import "GCListingDetailCell.h"
#import "GCSingleButtonCell.h"
#import "GCListingPeopleCell.h"
#import "GCUILabelExtras.h"
#import "GCProfileWebViewController.h"
#import "GCEventDetailCell.h"
#import "GCImageFlipper.h"
#import "GCListingCheckinViewController.h"

@implementation GCEventViewController

@synthesize event;
@synthesize tableView;
@synthesize isAttending;
@synthesize eventPhoto;
@synthesize communicator;
@synthesize detailButton, attendingButton, attendingButtonSmall;
@synthesize eventTitleLabel, eventDetailsLabel;
@synthesize allEventsImages, eventsImages, imageRequests;
@synthesize eventImageView, eventImageMagGlass;
@synthesize eventPhotoActivity;
@synthesize eventAttendingLabel, eventAttendingBadge;

- (id)init
{
	if (self = [super init]) {
		communicator = [GCCommunicator sharedCommunicator];
		communicator.eventDelegate = self;
		communicator.ul.delegate = self;
		event = [[NSMutableDictionary alloc] init];
		isAttending = NO;
	}
	return self;
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
	}
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
		//NSLog(@"event : %@", event );
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	//communicator.eventDelegate = self;
	//communicator.ul.delegate = self;
	
	imageRequests = [[NSMutableArray alloc] init];  //for image flipper - ch
	eventsImages = [[NSMutableArray alloc] init];
	allEventsImages = [[NSMutableArray alloc] init];
	downloadQueue = [[NSOperationQueue alloc] init];
	finishedAddingToListingImageDownLoadQueue = NO;
	currentImage = 0;
	requestCount = 0;
	completeCount = 0;
	if (!eventPhoto) {
		self.eventPhoto = nil; // [UIImage imageNamed:@"defaultEventImage.png"];
		if ([[event objectForKey:@"photo_url"] length] > 0 && !communicator.noInternet) {
      eventImageMagGlass.hidden = YES;
      [eventPhotoActivity startAnimating];
			[NSThread detachNewThreadSelector:@selector(getPhoto) toTarget:self withObject:nil];
		}
	} else {
		eventImageView.image = eventPhoto;
    [eventPhotoActivity stopAnimating];


	}

	tableView.backgroundColor = [UIColor clearColor];
	tabSelected = detailTabSelected;
	showingUserProfile = NO;
	
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"EVENT_DETAILS-Viewed" withParameters:nil];
	
	if (event) {
		eventTitleLabel.text = [event objectForKey:@"name"];
		NSDateFormatter *dateFormatterIn = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatterOut = [[NSDateFormatter alloc] init];
    
    [dateFormatterIn setDateFormat:@"MM/dd/yyyy"];
    [dateFormatterOut setDateFormat:@"EEE, MMM d"];
    if ([[dateFormatterIn dateFromString:[event objectForKey:@"end_date"]] timeIntervalSinceReferenceDate] > [[dateFormatterIn dateFromString:[event objectForKey:@"start_date"]] timeIntervalSinceReferenceDate]) {
      eventDetailsLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatterOut stringFromDate:[dateFormatterIn dateFromString:[event objectForKey:@"start_date"]]], [dateFormatterOut stringFromDate:[dateFormatterIn dateFromString:[event objectForKey:@"end_date"]]]];

    } else if ([event objectForKey:@"hours"]) {
      eventDetailsLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatterOut stringFromDate:[dateFormatterIn dateFromString:[event objectForKey:@"start_date"]]], [event objectForKey:@"hours"]];
    } else {
      eventDetailsLabel.text = [NSString stringWithFormat:@"%@", [dateFormatterOut stringFromDate:[dateFormatterIn dateFromString:[event objectForKey:@"start_date"]]]];
    }
    
    [dateFormatterIn release];
    [dateFormatterOut release];
		
	}
  
  if (isAttending) {
    [attendingButtonSmall setImage:[UIImage imageNamed:@"countMeOutSmall.png"] forState:UIControlStateNormal];
  } else {
    [attendingButtonSmall setImage:[UIImage imageNamed:@"countMeInSmall.png"] forState:UIControlStateNormal];
  }
  int count = [[event objectForKey:@"attendees"] count];
  if (count == 0) {
    eventAttendingBadge.hidden = YES;
    eventAttendingLabel.text = @"0";
    eventAttendingLabel.hidden = YES;
  } else {
    eventAttendingBadge.hidden = NO;
    eventAttendingLabel.text = [NSString stringWithFormat:@"%i", count];
    eventAttendingLabel.hidden = NO;
  }
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	[tableView reloadData];
	communicator.eventDelegate = self;
  communicator.ul.delegate = self;
	showingUserProfile = NO;

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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (!showingUserProfile) {
		communicator.eventDelegate = nil;
	}
	/*if (communicator.listingDelegate == self) {
	 communicator.listingDelegate = nil;
	 }*/
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[imageRequests removeAllObjects];
	self.imageRequests = nil;
	[downloadQueue release];
	self.eventsImages = nil;
  self.eventImageView = nil;
	self.attendingButtonSmall = nil;
  self.eventDetailsLabel = nil;
	self.detailButton = nil;
	self.attendingButton = nil;
	communicator.ul.delegate = communicator;
	self.tableView = nil;
	self.eventPhoto = nil;
	self.event = nil;
	self.eventTitleLabel = nil;
  self.eventPhotoActivity = nil;
  self.eventAttendingLabel = nil;
  self.eventAttendingBadge = nil;
  self.eventImageMagGlass = nil;
    [super dealloc];
}

-(IBAction)switchViews:(id)sender
{
	
	if ((UIButton *)sender == detailButton) {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"EVENT_DETAILS-Info_tab_selected" withParameters:nil];

		tabSelected = detailTabSelected;
		detailButton.selected = YES;
		attendingButton.selected = NO;
		
		
	}  else {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"EVENT_DETAILS-Attending_tab_selected" withParameters:nil];

		tabSelected = attendingTabSelected;
		detailButton.selected = NO;
		attendingButton.selected = YES;
	}
	[tableView reloadData];
	
}

- (IBAction)attendThisEvent:(id)sender;
{
  
	if (isAttending) {
		[communicator.ul attendEvent:[event objectForKey:@"event_id"] status:@"X" shout:@""];
	}
	else {
//		[communicator.ul attendEvent:[event objectForKey:@"event_id"] status:@"A"];
    if ([communicator.ul shouldCheckInToListing]) {
      GCListingCheckinViewController *lcivc = [[GCListingCheckinViewController alloc] init];
      lcivc.event = event;
      UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:lcivc];
      [self presentModalViewController:controller animated:YES];
      [controller release];
      [lcivc release];
    }
	}
}

#pragma mark userlogin delegate

- (void)attendEventResult:(BOOL)result
{
	if (result) {
		isAttending = !isAttending;	
		[tableView reloadData];
    if (isAttending) {
      [attendingButtonSmall setImage:[UIImage imageNamed:@"countMeOutSmall.png"] forState:UIControlStateNormal];
    } else {
      [attendingButtonSmall setImage:[UIImage imageNamed:@"countMeInSmall.png"] forState:UIControlStateNormal];
    }
    
		[communicator loadEventDetails:[event objectForKey:@"event_id"] processing:NO];
	}
}

- (void)loginResult:(BOOL)result
{
	if (result) {
		[communicator loadEventDetails:[event objectForKey:@"event_id"] processing:YES];
	}
}


#pragma mark communicator delegate

- (void)didUpdateAttendees
{
	if (tabSelected == attendingTabSelected) {
		[tableView reloadData];
	}
  int count = [[event objectForKey:@"attendees"] count];
  if (count == 0) {
    eventAttendingBadge.hidden = YES;
    eventAttendingLabel.text = @"0";
    eventAttendingLabel.hidden = YES;
  } else {
    eventAttendingBadge.hidden = NO;
    eventAttendingLabel.text = [NSString stringWithFormat:@"%i", count];
    eventAttendingLabel.hidden = NO;
  }
}

		 
- (void)didLoadEventDetails:(NSMutableDictionary *)aEvent
{

	if (event) {
		NSMutableDictionary *userStatus = [aEvent objectForKey:@"userevent"];
		if (userStatus) {
			isAttending = [[userStatus objectForKey:@"isattending"] boolValue];
		}
		self.event = aEvent;
		[tableView reloadData];
		eventTitleLabel.text = [event objectForKey:@"name"];
    NSDateFormatter *dateFormatterIn = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatterOut = [[NSDateFormatter alloc] init];

    [dateFormatterIn setDateFormat:@"MM/dd/yyyy"];
    [dateFormatterOut setDateFormat:@"EEE, MMM d"];

		eventDetailsLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatterOut stringFromDate:[dateFormatterIn dateFromString:[event objectForKey:@"start_date"]]], [event objectForKey:@"hours"]];
    [dateFormatterIn release];
    [dateFormatterOut release];
    
    if (isAttending) {
      [attendingButtonSmall setImage:[UIImage imageNamed:@"countMeOutSmall.png"] forState:UIControlStateNormal];
    } else {
      [attendingButtonSmall setImage:[UIImage imageNamed:@"countMeInSmall.png"] forState:UIControlStateNormal];
    }
		int count = [[event objectForKey:@"attendees"] count];
    if (count == 0) {
      eventAttendingBadge.hidden = YES;
      eventAttendingLabel.text = @"0";
      eventAttendingLabel.hidden = YES;
    } else {
      eventAttendingBadge.hidden = NO;
      eventAttendingLabel.text = [NSString stringWithFormat:@"%i", count];
      eventAttendingLabel.hidden = NO;
    }
	} else {
		//show error?
	}

}

- (void)didFailLoadEventDetails
{
	NSLog(@"load new events did fail");

}
		 


-(void)getPhoto
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
  NSString *photoString = [event objectForKey:@"photo_url"];
  
  if (photoString && [photoString length] > 0) {
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoString]]];
    
    if (image) {
      [self performSelectorOnMainThread:@selector(replaceImage:) withObject:image waitUntilDone:NO];
      [image autorelease];
    } else {
      [self performSelectorOnMainThread:@selector(replaceImage:) withObject:nil waitUntilDone:NO];
      
    }
  } else {
    [self performSelectorOnMainThread:@selector(replaceImage:) withObject:nil waitUntilDone:NO];
  }
	[aPool release];
}


-(void)replaceImage:(UIImage *)image
{

  [eventPhotoActivity stopAnimating];

	if (image) {
		self.eventPhoto = image;
		eventImageView.image = eventPhoto;
	} else {
    self.eventPhoto = nil;
    eventImageMagGlass.hidden = YES;
    eventImageView.image = [UIImage imageNamed:@"defaultEventImage.png"];
  }
	
}

#pragma mark tableView methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tabSelected == detailTabSelected) {
		return 4;

	} else if (tabSelected == attendingTabSelected) {
		return 1;

	}
	return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tabSelected == detailTabSelected) {
		switch (section) {
			case 2:;
        NSString *oneLiner = [event objectForKey:@"one_liner"];
				if (oneLiner && ![oneLiner isEqual:[NSNull null]] && [oneLiner length] > 0) {
          return 1;
        }
        NSString *eventDescrition = [event objectForKey:@"description"];
				if (eventDescrition && ![eventDescrition isEqual:[NSNull null]] && [eventDescrition length] > 0) {
					return 1;
				}
        return 0;
			case 1:;
        NSString *phone = [event objectForKey:@"phone"];
				if (phone && ![phone isEqual:[NSNull null]] && [phone length] > 0) {
					return 1;
				}
        return 0;
			case 0:;
        NSString *street = [event objectForKey:@"street"];
				if (street && ![street isEqual:[NSNull null]] && [street length] > 0) {
					return 1;
				}
        return 0;
			case 3:;
        NSString *url = [event objectForKey:@"url"];
				if (url && ![url isEqual:[NSNull null]] && [url length] > 0) {
					return 1;
				}
        return 0;
			case 4:
				return 1;
			default:
				return 0;
				break;
		}
		
	} else if (tabSelected == attendingTabSelected) {
		
      if (event) {
        return [[event objectForKey:@"attendees"] count];
      }
      else {
        return 0;
      }
	
		
	}
	
	return 0;
	
	
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (tabSelected == detailTabSelected) {
		switch (section) {
			case 0:
				return @"";
				break;
			case 1:
				return @"";
				break;
			default:
				return @"";
				break;
		}
	} else if (tabSelected == attendingTabSelected) {

		return @"";
	}
	return @"";
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	
	if (tabSelected == detailTabSelected) {
		switch (section) {
			case 0:
				return 10;
				break;
			case 1:
				return 5;
				break;
			case 2:
		 {
			
			
		 }
				break;
			default:
				return 5;
				break;
		}
	} else if (tabSelected == attendingTabSelected) {
		
		return 10;
	}
	return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

	if (tabSelected == detailTabSelected) {
		switch (section) {
			case 0: {
				UILabel *label = [UILabel gcLabelForTableHeaderView];
				label.text = @"";
				return label;
				break;
			}
			case 1:{
				UILabel *label = [UILabel gcLabelForTableHeaderView];
				label.text = @"";
				return label;
				break;
			}
			default:
				return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
				break;
		}
	} else if (tabSelected == attendingTabSelected) {
		UILabel *label = [UILabel gcLabelForTableHeaderView];
    label.text = @"";
    return label;
	}
	return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tabSelected == detailTabSelected) {
		int section = [indexPath section];
		if (section == 2  && event) {
			CGSize reviewSize;
			CGSize constraint = CGSizeMake(280,3000);
			if ([[event objectForKey:@"one_liner"] length] >0 && [[event objectForKey:@"description"] length] >0) {
				reviewSize = [[NSString stringWithFormat:@"%@\n%@", [event objectForKey:@"one_liner"], [event objectForKey:@"description"]] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
			}
			else if ([[event objectForKey:@"one_liner"] length] >0) {
				reviewSize = [[NSString stringWithFormat:@"%@", [event objectForKey:@"one_liner"]] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
			} else if ([[event objectForKey:@"description"] length] >0) {
				reviewSize = [[NSString stringWithFormat:@"%@", [event objectForKey:@"description"]] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
			} else {
				return 0;
				
			}
			
			if ((30 + reviewSize.height) < 50) {
				return 50;
			}
			return 30 + reviewSize.height;
		}else if (section == 1 && event) {
			return 50;
		} else if (section == 0 && event) {
			NSMutableString *addressText = [[NSMutableString alloc] init];
			BOOL addNewLine = NO;
			BOOL addComma = NO;
      
      if ([[event objectForKey:@"location_name"] length] > 0) {
				[addressText appendString:[event objectForKey:@"location_name"]];
				addNewLine = YES;
			}
      
			if ([[event objectForKey:@"street"] length] > 0) {
				addNewLine ? [addressText appendFormat:@"\n%@", [event objectForKey:@"street"]] : [addressText appendString:[event objectForKey:@"street"]];
				addNewLine = YES;
			}

			if ([[event objectForKey:@"city"] length] > 0) {
				addNewLine ? [addressText appendFormat:@"\n%@", [event objectForKey:@"city"]] : [addressText appendString:[event objectForKey:@"city"]];
				addNewLine = NO;
				addComma = YES;
			}
			
			if ([[event objectForKey:@"state"] length] > 0) {
				if (addNewLine) {
					[addressText appendString:@"\n"];
//					addNewLine = NO;
				}
				if (addComma) {
					[addressText appendString:@", "];
//					addComma = NO;
				}
				[addressText appendFormat:@"%@", [event objectForKey:@"state"]];
				
			}
			CGSize reviewSize;
			CGSize constraint = CGSizeMake(223,3000);
			
			reviewSize = [addressText sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
				
			[addressText release];
			
			if ((30 + reviewSize.height) < 50) {
				return 50;
			}
			return 30 + reviewSize.height;
			
		}
		else {
			return 50;
		}
		
	} else if (tabSelected == attendingTabSelected) {
		
			return 48;
	}
	
	return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	int section = [indexPath section];
	int row = [indexPath row];
	if (tabSelected == detailTabSelected) {
		if (section == 2) {
			GCEventDetailCell *cell  = (GCEventDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"eventDetailCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCEventDetailCell" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];

			}
			
			if ([[event objectForKey:@"one_liner"] length] > 0 && [[event objectForKey:@"description"] length] > 0) {
					cell.eventDescriptionLabel.text = [NSString stringWithFormat:@"%@\n%@", [event objectForKey:@"one_liner"], [event objectForKey:@"description"]];
				
			} else if ([[event objectForKey:@"one_liner"] length] > 0) {
			
					cell.eventDescriptionLabel.text = [NSString stringWithFormat:@"%@", [event objectForKey:@"one_liner"]];
				
			} else if ([[event objectForKey:@"description"] length] > 0) {
				cell.eventDescriptionLabel.text = [NSString stringWithFormat:@"%@", [event objectForKey:@"description"]];
				
			}
			else {
				cell.eventDescriptionLabel.text = @"";
			}
			
			
			return cell;
			
			
		}
		else if (section == 1) {
			GCListingDetailCell *cell  = (GCListingDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"listingDetailCell-Phone"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingDetailCell-Phone" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				cell.cellLabel.text = [event objectForKey:@"phone"];
			}
			
			
			return cell;
		}
		else if (section == 0) {
			
			GCListingDetailCell *cell  = (GCListingDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"listingDetailCell-Address"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingDetailCell-Address" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
			}
			NSMutableString *addressText = [[NSMutableString alloc] init];
			BOOL addNewLine = NO;
			BOOL addComma = NO;
      
      if ([[event objectForKey:@"location_name"] length] > 0) {
				[addressText appendString:[event objectForKey:@"location_name"]];
				addNewLine = YES;
			}
      
			if ([[event objectForKey:@"street"] length] > 0) {
				addNewLine ? [addressText appendFormat:@"\n%@", [event objectForKey:@"street"]] : [addressText appendString:[event objectForKey:@"street"]];
				addNewLine = YES;
			}
			
			if ([[event objectForKey:@"city"] length] > 0) {
				addNewLine ? [addressText appendFormat:@"\n%@", [event objectForKey:@"city"]] : [addressText appendString:[event objectForKey:@"city"]];
				addNewLine = NO;
				addComma = YES;
			}
			
			if ([[event objectForKey:@"state"] length] > 0) {
				if (addNewLine) {
					[addressText appendString:@"\n"];
//					addNewLine = NO;
				}
				if (addComma) {
					[addressText appendString:@", "];
//					addComma = NO;
				}
				[addressText appendFormat:@"%@", [event objectForKey:@"state"]];

			}
			
			cell.cellLabel.text = addressText;
			[addressText release];
			
			if ([[event objectForKey:@"lat"] length] > 0 && [[event objectForKey:@"lng"] length] > 0) {
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.disclosureImage.hidden = NO;
			} else {
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.disclosureImage.hidden = YES;
			}

			return cell;
		}else if (section == 3) {
			
			GCListingDetailCell *cell  = (GCListingDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"listingDetailCell-URL"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingDetailCell-URL" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				cell.cellLabel.text = [event objectForKey:@"url"];
			}
			
			return cell;
		}
		
		
		
	} else if (tabSelected == attendingTabSelected) {
		
			GCListingPeopleCell *cell = (GCListingPeopleCell *)[tableView dequeueReusableCellWithIdentifier:@"listingPeopleCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingPeopleCell" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				cell.disclosureImage.hidden = NO;
				cell.noKingMessage.hidden = YES;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;			
			}
			GCPerson *person = (GCPerson *)[[event objectForKey:@"attendees"] objectAtIndex:row];
			
			cell.person = person;
			cell.profileImage.image = nil;//person.profileImage;
			[cell loadImage];
			
			cell.userName.text = [person.user objectForKey:@"username"];
			//cell.profileImage.image = person.profileImage;
			cell.shout.text = @"";
			cell.userDetails.text = [NSString stringWithFormat:@"%@/%@", [person.user objectForKey:@"u_age"], [person.user objectForKey:@"u_gender"]];
			cell.checkinDate.text = @"";
			
			return cell;
			
		
			

	}
	
	return nil;
}



- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[GCSingleButtonCell class]]) {
		return;
	}
	
	if (tabSelected == detailTabSelected) {
		if ([indexPath section] == 3 ) {
			NSURL *url = [NSURL URLWithString:[event objectForKey:@"url"]];
			OCWebViewController	*webViewController = [[OCWebViewController alloc] init];
			showingUserProfile = YES;
			[webViewController setURL:url andName:[event objectForKey:@"name"]];
			[[self navigationController] pushViewController:webViewController animated:YES];
			[webViewController release];
		} else if ([indexPath section] == 0 ) {
			if ([[event objectForKey:@"lat"] length] > 0 && [[event objectForKey:@"lng"] length] > 0) {
				double lat = [[event objectForKey:@"lat"] doubleValue];
				double lng = [[event objectForKey:@"lng"] doubleValue];
				NSString *locString = [event objectForKey:@"location"];
				if (!(locString && [locString length] > 0)) {
					locString = nil;
				}

				OCMapViewController	*mapViewController = [[OCMapViewController alloc] initWithLatitude:lat andLong:lng andName:[event objectForKey:@"name"] andLocationName:locString];
				[[self navigationController] pushViewController:mapViewController animated:YES];
				[mapViewController release];
			}
			
		}
		
	} else if (tabSelected == attendingTabSelected) {
		
			[self openProfilePageForUser:[[(GCPerson *)[[event objectForKey:@"attendees"] objectAtIndex:[indexPath row]] user] objectForKey:@"username"]];
		
	}
		
	
	
	
	
	[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:NO];
	
}



- (void)openProfilePageForUser:(NSString *)username
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gaycities.com/reviewer/%@?iphone=1",username]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	
	GCProfileWebViewController	*webViewController = [[GCProfileWebViewController alloc] init];
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
	showingUserProfile = YES;
	webViewController.profileRequest = request;
	[[self navigationController] pushViewController:webViewController animated:YES];
	[webViewController release];
	[request release];
}

- (IBAction)showLargeEventImage:(id)sender
{
  if (!eventPhoto) return;
  
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:eventPhoto, @"fullImage", eventPhoto, @"thumbnailImage", @" ", @"caption", @"", @"photog_name", @"", @"username", nil];
	imageFlipper = [[GCImageFlipper alloc] initWithImages:[NSArray arrayWithObject:dict]];
	imageFlipper.delegate = self;
	[imageFlipper show];
	[imageFlipper release];
	[dict release];
}

- (void)imageFlipperWillClose:(GCImageFlipper *)flipper
{
	imageFlipper = nil;
}

@end
