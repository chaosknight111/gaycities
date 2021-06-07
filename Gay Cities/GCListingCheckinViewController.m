//
//  GCListingCheckinViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/15/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCListingCheckinViewController.h"
#import "GayCitiesAppDelegate.h"
#import "OCConstants.h"
#import "GCLoginViewConroller.h"

@implementation GCListingCheckinViewController

@synthesize shoutTextView;
@synthesize communicator;
@synthesize listingNameLabel;
@synthesize listing;
@synthesize shoutText, urlToSend;
@synthesize tweetsToSend, fbToSend;
@synthesize mainCheckinViewController;
@synthesize gcad;
@synthesize event;
@synthesize checkinType;
@synthesize placeHolderText;
@synthesize facebookButton, twitterButton, foursquareButton, bgImageView;

- (id)init
{
	if (self = [super init]) {
		self.mainCheckinViewController = nil;
	}
	return self;
}

- (void)setBarButtons {
  UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAndClose)];
  self.navigationItem.leftBarButtonItem = closeButton;
  [closeButton release];
  
  if (checkinType == GCCheckinTypeEvent) {
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Count Me In" style:UIBarButtonItemStyleDone target:self action:@selector(checkinNow:)];
    self.navigationItem.rightBarButtonItem = submitButton;
    [submitButton release];
  } else {
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Checkin" style:UIBarButtonItemStyleDone target:self action:@selector(checkinNow:)];
    self.navigationItem.rightBarButtonItem = submitButton;
    [submitButton release];
  }
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.333 green:0.576 blue:0.847 alpha:1];
    
    self.bgImageView.image = [[UIImage imageNamed:@"fakeOneLargeRow.png"] stretchableImageWithLeftCapWidth:40.f topCapHeight:40.f];

  UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
  
	tweetsToSend = [[NSMutableArray alloc] init];
	fbToSend = [[NSMutableArray alloc] init];
	urlToSend = [[NSString alloc] init];

	shoutText = [[NSString alloc] init];
	communicator = [GCCommunicator sharedCommunicator];
	isClosing = NO;
	
	gcad = [GayCitiesAppDelegate sharedAppDelegate];
	gcad.connectController.connectionDelegate = self;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(facebookSigninSuccess:) name:gcFacebookLoginStatusSuccess object:nil];
	[nc addObserver:self selector:@selector(facebookSigninNone:) name:gcFacebookLoginStatusNone object:nil];
	[nc addObserver:self selector:@selector(twitterSigninSuccess:) name:gcTwitterLoginStatusSuccess object:nil];
	[nc addObserver:self selector:@selector(twitterSigninNone:) name:gcTwitterLoginStatusNone object:nil];
	[nc addObserver:self selector:@selector(foursquareSigninSuccess:) name:gcFoursquareLoginStatusSuccess object:nil];
	[nc addObserver:self selector:@selector(foursquareSigninNone:) name:gcFoursquareLoginStatusNone object:nil];
	
	//[nc addObserver:self selector:@selector(cellProfileImageUpdated) name:gcCellImageUpdatedForPersonNotification object:nil];

  if (checkinType == GCCheckinTypeEvent) {
    self.placeHolderText = @"Leave a comment about this event (optional)";
  } else {
    self.placeHolderText = @"What's it like there now? (optional)";
  }
  shoutTextView.textColor = [UIColor grayColor];
  shoutTextView.text = placeHolderText;
  [self setBarButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[gcad logEventForFlurry:@"Check_in_to_listing_view_displayed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:listing.listing_id, @"listing_id", listing.type, @"listing_type", listing.name, @"listing_name", nil]];
  if (checkinType == GCCheckinTypeListing && listing) {
    self.listingNameLabel.text = listing.name;
  } else if (checkinType == GCCheckinTypeEvent && event) {
    self.listingNameLabel.text = [event objectForKey:@"name"];
  } else {
    self.listingNameLabel.text = @"Error";
  }
	[gcad.mainTabBar setHidden:YES];
	[gcad.adBackgroundView setHidden:YES];
	gcad.shouldShowAdView = NO;

	if ([gcad.connectController twitterIsAuthorized]) {
		self.twitterButton.selected = YES;
	} else {
		self.twitterButton.selected = NO;
	}
	
	if ([gcad.connectController hasSavedFoursquare]) {
    self.foursquareButton.selected = YES;
  } else {
    self.foursquareButton.selected = NO;
  }

	if (gcad.connectController.hasSavedFacebook) {
		self.facebookButton.selected = YES;
		
	} else {
		self.facebookButton.selected = NO;
	}
	[shoutTextView becomeFirstResponder];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	
}


 - (void)viewWillDisappear:(BOOL)animated {
	 [super viewWillDisappear:animated];
	 communicator.ul.checkinDelegate = nil;
  if (checkinType == GCCheckinTypeListing && listing) {
    if (![[listing type] isEqualToString:@"foursquare"]) {
      [communicator updateListingPeople:listing];
    }
  }
	[shoutTextView resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if (mainCheckinViewController && isClosing) {
		if ([mainCheckinViewController respondsToSelector:@selector(showPeopleTab)]) {
			[mainCheckinViewController showPeopleTab];
		}
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
}



- (void)dealloc {
	gcad.connectController.connectionDelegate = nil;
	self.shoutTextView = nil;
  self.foursquareButton = nil;
  self.facebookButton = nil;
  self.twitterButton = nil;
    self.bgImageView = nil;
	self.listingNameLabel = nil;
	self.shoutText = nil;
	self.tweetsToSend = nil;
	self.fbToSend = nil;
	self.urlToSend = nil;
  self.placeHolderText = nil;
  [event release];
	event = nil;
  [listing release];
  listing = nil;
	
    [super dealloc];
}


- (void)setListing:(GCListing *)aListing {
  checkinType = GCCheckinTypeListing;
  [listing release];
  listing = [aListing retain];;
}

- (void)setEvent:(NSDictionary *)anEvent {
  if (!anEvent) return;
  
  checkinType = GCCheckinTypeEvent;
  [anEvent retain];
  [event release];
  event = anEvent;
}

#pragma mark Actions

- (void)removeObservers {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self name:gcFacebookLoginStatusSuccess object:nil];
  [nc removeObserver:self name:gcFacebookLoginStatusNone object:nil];
  [nc removeObserver:self name:gcTwitterLoginStatusSuccess object:nil];
  [nc removeObserver:self name:gcTwitterLoginStatusNone object:nil];
  [nc removeObserver:self name:gcFoursquareLoginStatusSuccess object:nil];
  [nc removeObserver:self name:gcFoursquareLoginStatusNone object:nil];
}

- (IBAction)closeMe
{

	[gcad logEventForFlurry:@"Check_in_to_listing Completed and Closed" withParameters:nil];
	
	communicator.ul.checkinDelegate = nil;
  if (checkinType == GCCheckinTypeEvent) {
    [communicator loadEventDetails:[event objectForKey:@"event_id"] processing:NO];
  }
	isClosing = YES;
  [self removeObservers];
	[self.navigationController dismissModalViewControllerAnimated:YES];
	[gcad.mainTabBar setHidden:NO];
	[gcad.adBackgroundView setHidden:NO];
	gcad.shouldShowAdView = YES;
}

- (IBAction)cancelAndClose
{

	[gcad logEventForFlurry:@"Check_in_to_listing Cancelled" withParameters:nil];

	communicator.ul.checkinDelegate = nil;
  [self removeObservers];
	[self dismissModalViewControllerAnimated:YES];
	[gcad.mainTabBar setHidden:NO];
	[gcad.adBackgroundView setHidden:NO];
	gcad.shouldShowAdView = YES;
}

- (void)performGCCheckinWithFoursquareResponse:(NSString *)response {
  NSLog(@"Checking into GC Now");
  if (checkinType == GCCheckinTypeListing && listing) {
    [communicator.ul checkInToListing:listing.listing_id name:listing.name type:listing.type shout:shoutText private:@"0" facebook:self.facebookButton.selected ? @"2" : @"0" twitter:self.twitterButton.selected ? @"2" : @"0" foursquare:response ? @"1" : @"0" lat:listing.lat lng:listing.lng foursquareResponse:response];

  } else if (checkinType == GCCheckinTypeEvent && event) {
    NSLog(@"Checkin to event");
    [communicator.ul attendEvent:[event objectForKey:@"event_id"] status:@"A" shout:shoutText];
    
  }
}

- (IBAction)checkinNow:(id)sender
{
	NSLog(@"ACTION - Check in now");
  communicator.ul.checkinDelegate = self;
  if (self.foursquareButton.selected) {
    NSLog(@"Checkin FS First");
    [self sendFoursquareUpdate];
  } else {
    [self performGCCheckinWithFoursquareResponse:nil];
  }
}

- (IBAction)changeFacebookStatus:(id)sender
{
  self.facebookButton.selected = !self.facebookButton.selected;
	if (self.facebookButton.selected) {
		if (gcad.connectController.hasSavedFacebook) {
//			NSLog(@"facebook on and facebook is saved");
			if (!gcad.connectController.fbExtendedPermission) {
//				self.facebookButton.selected = NO;
//
//				[gcad.connectController checkExtendedPermissions:NO];
				
			}
		} else {
//			NSLog(@"ask login facebook");
			self.facebookButton.selected = NO;
			[gcad.connectController signInOrLogoutFacebook];
		}
	}
}

- (IBAction)changeTwitterStatus:(id)sender
{
  self.twitterButton.selected = !self.twitterButton.selected;

	if (self.twitterButton.selected) {
		if ([gcad.connectController twitterIsAuthorized]) {
//			NSLog(@"twitter on and twitter is saved");
			if (!gcad.connectController.twitterLoginSucessful) {
//				NSLog(@"Twitter Off, checking login");
				[gcad.connectController checkTwitterCredentials];
			} else {
//				NSLog(@"Twitter ON, login already checked");
			}
		} else {
//			NSLog(@"ask login twitter");
			self.twitterButton.selected = NO;
			[gcad.connectController signInOrLogoutTwitter];


		}
	}
}

- (IBAction)changeFoursquareStatus:(id)sender {
  self.foursquareButton.selected = !self.foursquareButton.selected;

  if (self.foursquareButton.selected) {
    if ([gcad.connectController hasSavedFoursquare]) {
//      NSLog(@"Foursquare on and saved");
    } else {
//      NSLog(@"ask foursquare");
      self.foursquareButton.selected = NO;
      [gcad.connectController signInOrLogoutFoursquare:self];
    }
  }
}

- (void)facebookSigninSuccess:(NSNotification *)note
{
	self.facebookButton.selected = YES;
}


- (void)facebookSigninNone:(NSNotification *)note
{
	self.facebookButton.selected = NO;
}
										
- (void)twitterSigninSuccess:(NSNotification *)note
{
	self.twitterButton.selected = YES;

	
}
- (void)twitterSigninNone:(NSNotification *)note
{
	self.twitterButton.selected = NO;

}

- (void)foursquareSigninSuccess:(NSNotification *)note {
  self.foursquareButton.selected = YES;
}

- (void)foursquareSigninNone:(NSNotification *)note {
  self.foursquareButton.selected = NO;

}

#pragma mark communicator delegates

- (void)checkinResult:(NSMutableDictionary *)result
{
	NSLog(@"Checkin result: %@", [result objectForKey:@"result"]);
	if ([[result objectForKey:@"result"] boolValue]) {
		if ([[result objectForKey:@"response"] objectForKey:@"tweet_texts"] && [[result objectForKey:@"response"] objectForKey:@"url"]) {
			if ([[[result objectForKey:@"response"] objectForKey:@"tweet_texts"] isKindOfClass:[NSArray class]]) {
				if ([[[result objectForKey:@"response"] objectForKey:@"tweet_texts"] count] > 0) {
					if (self.twitterButton.selected) {
						[tweetsToSend setArray:[[result objectForKey:@"response"] objectForKey:@"tweet_texts"]];
					}
					
					if (self.facebookButton.selected) {
						[fbToSend setArray:[[result objectForKey:@"response"] objectForKey:@"tweet_texts"]];
					}
          
					self.urlToSend = [[result objectForKey:@"response"] objectForKey:@"url"];
					
					if (self.twitterButton.selected && [tweetsToSend count] > 0) {
						[self retain];
//						NSLog(@"retained to send Tweets (and fb) updates");
						[[GayCitiesAppDelegate sharedAppDelegate] showProcessing:@"Sending Twitter Update..."];
						NSString *tweet = nil;
						if ([urlToSend length] > 0) {
							tweet = [NSString stringWithFormat:@"%@ %@", [tweetsToSend objectAtIndex:0], urlToSend];
						} else {
							tweet = [tweetsToSend objectAtIndex:0];
						}
						[tweetsToSend removeObjectAtIndex:0];
						[gcad.connectController sendTwitterUpdate:tweet];
							
						
					} else if (self.facebookButton.selected && [fbToSend count] > 0) {
						[self retain];
//						NSLog(@"retained to send fb updates");
						[[GayCitiesAppDelegate sharedAppDelegate] showProcessing:@"Sending Facebook Update..."];
						
						[self sendFBUpdate];
					}
				}
			}
			
		}
	} //else {
	[self closeMe];
//	NSLog(@"closing checkincontroller");
}

- (void)sendFBUpdate
{
  FBSBJSON *jsonWriter = [[[FBSBJSON alloc] init] autorelease];

	if (checkinType == GCCheckinTypeListing && listing) {
    NSDictionary *properties = [[NSDictionary alloc] initWithObjectsAndKeys:[listing.type capitalizedString], @"What",[NSString stringWithFormat:@"%@, %@", listing.city, listing.state], @"Where", nil];
    NSString *propertiesString = [jsonWriter stringWithObject:properties];
    [properties release];

    NSArray *actionLinks = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"{*actor*} on GayCities", @"name", [NSString stringWithFormat:@"http://www.gaycities.com/reviewer/%@", communicator.ul.gcLoginUsername], @"link", nil]];
    NSString *actionString = [jsonWriter stringWithObject:actionLinks];

    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:[fbToSend objectAtIndex:0], @"message",  [NSString stringWithFormat:@"{*actor*} checked in at %@ on GayCities", listing.name], @"caption", [shoutText length] > 0 ? shoutText : @"-", @"description",listing.name, @"name", urlToSend, @"link", [NSString stringWithFormat:@"http://www.gaycities.com/li/%@-%@.jpg", listing.type, listing.listing_id], @"picture", actionString, @"actions",propertiesString, @"properties", nil] autorelease];

    [fbToSend removeObjectAtIndex:0];
    
    NSLog(@"Facebook params:%@", params);
    [gcad.connectController sendFBMessage:params];

  } else if (checkinType == GCCheckinTypeEvent && event) {
    NSDictionary *properties = [[NSDictionary alloc] initWithObjectsAndKeys:@"Event", @"What",[NSString stringWithFormat:@"%@ %@", [event objectForKey:@"city"] ? [event objectForKey:@"city"] : @"", [event objectForKey:@"state"] ? [event objectForKey:@"state"] : @""], @"Where", nil];
    NSString *propertiesString = [jsonWriter stringWithObject:properties];
    [properties release];
    
    NSArray *actionLinks = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"{*actor*} on GayCities", @"name", [NSString stringWithFormat:@"http://www.gaycities.com/reviewer/%@", communicator.ul.gcLoginUsername], @"link", nil]];
    NSString *actionString = [jsonWriter stringWithObject:actionLinks];
    
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:[fbToSend objectAtIndex:0], @"message",  [NSString stringWithFormat:@"{*actor*} is attending %@ on GayCities", [event objectForKey:@"name"]], @"caption", [shoutText length] > 0 ? shoutText : @"-", @"description", [event objectForKey:@"name"], @"name", urlToSend, @"link", [NSString stringWithFormat:@"http://www.gaycities.com/ev/events-%@.jpg", [event objectForKey:@"event_id"]], @"picture", actionString, @"actions",propertiesString, @"properties", nil] autorelease];
    
    [fbToSend removeObjectAtIndex:0];
    NSLog(@"Facebook Event params:%@", params);
    [gcad.connectController sendFBMessage:params];
    

  } else {
    [self facebookUpdateFinished:NO];
  }
		
	
}



- (void)twitterUpdateFinished:(BOOL)status
{
	if (status && [tweetsToSend count] > 0) {
		NSString *tweet = nil;
		if ([urlToSend length] > 0) {
			tweet = [NSString stringWithFormat:@"%@ %@", [tweetsToSend objectAtIndex:0], urlToSend];
		} else {
			tweet = [tweetsToSend objectAtIndex:0];
		}
		[tweetsToSend removeObjectAtIndex:0];
		[gcad.connectController sendTwitterUpdate:tweet];
	} else if (self.facebookButton.selected && [fbToSend count] > 0) {
		[[GayCitiesAppDelegate sharedAppDelegate] showProcessing:@"Sending Facebook Update..."];
		[self sendFBUpdate];	
	} else {
		[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
		[self release];
	}
	
	
}



- (void)facebookUpdateFinished:(BOOL)status
{
	if (status && [fbToSend count] > 0) {
		[self sendFBUpdate];		
	} else {
		[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
		[self release];
	}
	
	
}

- (void)sendFoursquareUpdate {
  NSLog(@"Send FS Update...");
  if (checkinType == GCCheckinTypeListing && self.listing) {
    [gcad.connectController sendFoursquareUpdate:listing shout:self.shoutText];
  } else if (checkinType == GCCheckinTypeEvent && event) {
    [gcad.connectController sendFoursquareUpdate:event shout:self.shoutText];
  } else {
    [self foursquareUpdateFinished:NO response:nil];
  }
}

- (void)foursquareUpdateFinished:(BOOL)status response:(NSString *)response {
  if (!status) {
    [self performGCCheckinWithFoursquareResponse:nil];
    return;
  }
  NSDictionary *dict = [response JSONValueWithStrings];
  NSString *responseID = nil;

  if (dict) {
    NSDictionary *responseDict = [dict objectForKey:@"response"];
    if (responseDict) {
      responseID = [[responseDict objectForKey:@"checkin"] objectForKey:@"id"];
    }
  }

  [self performGCCheckinWithFoursquareResponse:responseID];
}

#pragma mark Alert/Action View Delegates

/*- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		if (hasSavedTwitter || hasSavedFacebook) {
			UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logoutServices)];
			self.navigationController.navigationBar.topItem.rightBarButtonItem = logoutButton;
			[logoutButton release];
		}
	}
}*/

/*
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 105) {
		if (self.twitterButton.selected) {
			if ([tweetsToSend count] > 0) {
				[[GayCitiesAppDelegate sharedAppDelegate] showProcessing:@"Sending Twitter Update..."];
				NSString *tweet = [NSString stringWithFormat:@"%@ %@",[tweetsToSend objectAtIndex:0], urlToSend];
				[tweetsToSend removeObjectAtIndex:0];
				self.twitterConnectionID = [twitterEngine sendUpdate:tweet];
				
			}
		} else if (self.facebookButton.selected) {
			[[GayCitiesAppDelegate sharedAppDelegate] showProcessing:@"Sending Facebook Update..."];
			[self sendFBMessage];			
		} else {
			[[GayCitiesAppDelegate sharedAppDelegate] hideProcessing];
			[self closeMe];
		}
	}
}
 */



#pragma mark TextViewDelegates

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//		
//        return FALSE;
//    }
    return TRUE;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//	UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear Text" style:UIBarButtonItemStylePlain target:self action:@selector(clearTextInShout)];
//	self.navigationController.navigationBar.topItem.rightBarButtonItem = clearButton;
//	[clearButton release];
//	self.navigationController.navigationBar.topItem.leftBarButtonItem = nil;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
  textView.text = @"";
  textView.textColor = [UIColor blackColor];
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
  self.shoutText = textView.text;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	if ([textView.text isEqualToString:placeHolderText]) {
		self.shoutText = @"";
	} else {
		self.shoutText = textView.text;
	}
	
	if ([textView.text isEqualToString:@""]) {
		textView.text = placeHolderText;
		textView.textColor = [UIColor grayColor];
	}
	[self setBarButtons];

	return YES;
}

- (void)clearTextInShout
{
	shoutTextView.text = @"";
}



@end
