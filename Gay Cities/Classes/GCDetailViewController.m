//
//  OCDetailViewController.m
//  Gay Cities
//
//  Created by Brian Harmann on 12/14/08.
//  Copyright 2008 Obsessive Code. All rights reserved.
//

#import "GCDetailViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "GCListingReviewCell.h"
#import "GCDetailExtrasCell.h"
#import "OCWebViewController.h"
#import "OCMapViewController.h"
#import "GCReviewFanCell.h"
#import "GCSingleButtonCell.h"
#import "GayCitiesAppDelegate.h"
#import "GCListingReview.h"
#import "OCConstants.h"
#import "GCListingPeopleCell.h"
#import "GCListingDetailCell.h"
#import "GCListingCheckinViewController.h"
#import "GCDetailsRegularsViewController.h"
#import "GCPerson.h"
#import "GCUILabelExtras.h"
#import "GCImageFlipper.h"
#import "GCProfileWebViewController.h"


@implementation GCDetailViewController

@synthesize noInternetView, detailTable;
@synthesize userStatus;
@synthesize communicator;
@synthesize listing;
@synthesize extraDetails;
@synthesize detailButton, reviewsButton, peopleButton, noImageButton;
@synthesize nameLabel, oneLinerLabel;
@synthesize listingImage, starsImage;
@synthesize peopleDictionary;
@synthesize tableHeaderView;
@synthesize activityView;
@synthesize listingImages, allListingImages, imageRequests;

- (id)init
{
	if (self = [super init]) {
		self.communicator = [GCCommunicator sharedCommunicator];
		communicator.listingDelegate = self;
		communicator.ul.delegate = self;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	reviewsLoadedWithZero = NO;
	noReviewAlertShown = NO;
	requestSubmitDone = NO;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	savePath = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
	//communicator.listingDelegate = self;
	//communicator.ul.delegate = self;
	tabSelected = detailTabSelected;
	userStatus = [[NSDictionary alloc]init];
	extraDetails = [[NSMutableString alloc] init];
	if (listing.desc_editorial && ![listing.desc_editorial isEqualToString:@""]) {
		[extraDetails appendString:[NSString filterString:listing.desc_editorial]];
	}
	if (listing.hours && ![listing.hours isEqualToString:@""]) {
		if ([extraDetails length] > 0) {
			[extraDetails appendString:[NSString stringWithFormat:@"\n\nHours: %@",[NSString filterString:listing.hours]]];
		} else {
			[extraDetails appendString:[NSString stringWithFormat:@"Hours: %@",[NSString filterString:listing.hours]]];
		}
	}
	if (listing.tags && ![listing.tags isEqualToString:@""]) {
		if ([extraDetails length] > 0 && !(listing.hours && ![listing.hours isEqualToString:@""])) {
			[extraDetails appendString:[NSString stringWithFormat:@"\n\nTags: %@",[NSString filterString:listing.tags]]];
		} else if ([extraDetails length] > 0) {
			[extraDetails appendString:[NSString stringWithFormat:@"\nTags: %@",[NSString filterString:listing.tags]]];
		} else {
			[extraDetails appendString:[NSString stringWithFormat:@"Tags: %@",[NSString filterString:listing.tags]]];
		}
	}
	isReviewed = NO;
	isFan = NO;
	if (!communicator.noInternet) {
		[activityView startAnimating];
	} else {
		[activityView stopAnimating];
		listingImage.image = [UIImage imageNamed:@"nobuilding-add.png"];
	}
	
	UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gaycities_logo_white.png"]];
	titleView.contentMode = UIViewContentModeScaleAspectFit;
	titleView.frame = CGRectMake(90, 0, 140, 30);
	self.navigationItem.titleView = titleView;
	[titleView release];
	
	[communicator.listings loadBookmarks];
	
	isBookmarked = [communicator.listings.myList addRecentAndCheckBookmark:listing];
	
	nameLabel.text = [NSString filterString:listing.name];
	oneLinerLabel.text = [NSString filterString:listing.one_liner];
	CGSize constraint = CGSizeMake(247, 32);
	CGSize oneLinerSize = [oneLinerLabel.text  sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraint lineBreakMode: UILineBreakModeTailTruncation];
	oneLinerLabel.frame = CGRectMake(71, 37, 247, oneLinerSize.height);
	starsImage.image = listing.stars;
	imageRequests = [[NSMutableArray alloc] init];
	
	
	
	UIBarButtonItem *submitPicture = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(submitPictureAction)];
	self.navigationItem.rightBarButtonItem = submitPicture;
	[submitPicture release];
	
	
	
	if (communicator.ul.authToken) {
		[NSThread detachNewThreadSelector:@selector(checkListingStatus)toTarget:self withObject:nil];
	}
	
	//detailTable.backgroundColor = [UIColor whiteColor];
	detailTable.tableHeaderView = tableHeaderView;

	listingDistance = [communicator distanceFromLocation:[listing.lat doubleValue] lng:[listing.lng doubleValue]];
	peopleDictionary = [[NSMutableDictionary alloc] init];
	[communicator loadReviewsAndPeopleForListing:listing];
	//[communicator updateListingPeople:listing];

	detailTable.backgroundColor = [UIColor clearColor];
	listingImages = [[NSMutableArray alloc] init];
	allListingImages = [[NSMutableArray alloc] init];
	downloadQueue = [[NSOperationQueue alloc] init];
	finishedAddingToListingImageDownLoadQueue = NO;
	currentImage = 0;
	requestCount = 0;
	completeCount = 0;
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Viewed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:listing.listing_id, @"listing_id", listing.type, @"listing_type", listing.name, @"listing_name", nil]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	
	[detailTable reloadData];

}

-(void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	self.view.frame = CGRectMake(0, 0, 320, gcad.viewHeight);
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	/*if (communicator.listingDelegate == self) {
		communicator.listingDelegate = nil;
	}*/
	
}




-(IBAction)switchViews:(id)sender
{
	/*int selectedSegmentIndex = [segmentedControl selectedSegmentIndex];
	NSString *sortTitle = [segmentedControl titleForSegmentAtIndex:selectedSegmentIndex];
	NSLog(@"%@",sortTitle);
	
	//[mainView setNeedsDisplay];
	
	if ([sortTitle isEqualToString:@"Overview"]) {
		[self.view bringSubviewToFront:mainTable];

		[mainTable reloadData];

	}
	else if ([sortTitle isEqualToString:@"Reviews"]) {
		
		[self.view bringSubviewToFront:reviewView];

		[reviewsTable reloadData];

	}
	[self.view bringSubviewToFront:segmentedControl];*/
	
	if ((UIButton *)sender == detailButton) {
		tabSelected = detailTabSelected;
		detailButton.selected = YES;
		reviewsButton.selected = NO;
		peopleButton.selected = NO;
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Info tab selected" withParameters:nil];
		//detailTable.backgroundColor = [UIColor whiteColor];
		
	} else if ((UIButton *)sender == reviewsButton) {
		tabSelected = reviewsTabSelected;
		detailButton.selected = NO;
		reviewsButton.selected = YES;
		peopleButton.selected = NO;
		if (reviewsLoadedWithZero && !noReviewAlertShown) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No reviews yet" message:@"Be the first to write a review" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"OK", nil];
			alert.tag = 11;
			[alert show];
			[alert release];
			noReviewAlertShown = YES;
		}
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Reviews tab selected" withParameters:nil];

		//detailTable.backgroundColor = [UIColor whiteColor];

	} else {
		tabSelected = checkinTabSelected;
		detailButton.selected = NO;
		reviewsButton.selected = NO;
		peopleButton.selected = YES;
		//detailTable.backgroundColor = [UIColor clearColor];
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Checkin tab selected" withParameters:nil];

	}
	[detailTable reloadData];

}

-(void)scrollTables
{
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
	[detailTable setContentOffset:CGPointMake(0, 0) animated:NO];
	[apool release];
}

-(void)checkListingStatus
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	NSDictionary *returnedStatus = [communicator.ul checkListingStatus:listing.listing_id type:listing.type];
	if (returnedStatus) {
		if ([returnedStatus objectForKey:@"review"]) {
			[self performSelectorOnMainThread:@selector(setUserStatus:) withObject:[returnedStatus objectForKey:@"review"] waitUntilDone:YES];
		}
		//NSLog(@"userstatus:%@", returnedStatus);
		if ([returnedStatus objectForKey:@"isfan"]) {
			isFan = [[returnedStatus objectForKey:@"isfan"] boolValue];
		}
		if ([returnedStatus objectForKey:@"hasreview"]) {
			isReviewed = [[returnedStatus objectForKey:@"hasreview"] boolValue];
		}
		if (tabSelected == detailTabSelected) {
			[detailTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
		}
	}
	
	
	[aPool release];
}



#pragma mark communicator delegates

/*
- (void)noInternetErrorListing
{
	
}

- (void)didUpdateListing:(GCListing *)aListing
{
	[extraDetails removeAllObjects];
	if (listing.desc_editorial && ![listing.desc_editorial isEqualToString:@""]) {
		[extraDetails addObject:[NSString stringWithFormat:@"Description: %@",listing.desc_editorial]];
	}
	if (listing.hours && ![listing.hours isEqualToString:@""]) {
		[extraDetails addObject:[NSString stringWithFormat:@"Hours: %@",listing.hours]];
	}
	if (listing.tags && ![listing.tags isEqualToString:@""]) {
		[extraDetails addObject:[NSString stringWithFormat:@"Tags: %@",listing.tags]];
	}
	
	if (tabSelected == detailTabSelected) {
		[mainTable reloadData];
	}
	
}*/

- (void)errorListingPeopleReviewsUpdate
{
	NSLog(@"listing Delegate recieved error for reviews and people");
	if ([listing.reviews count] == 0) {
		reviewsLoadedWithZero = YES;
	}
}

- (void)didUpdateReviews:(NSMutableArray *)listingReviews
{
	if (listingReviews) {
		listing.reviews = listingReviews;
	}
	if ([listing.reviews count] == 0) {
		reviewsLoadedWithZero = YES;
	}
	
	
	if (tabSelected == reviewsTabSelected) {
		[detailTable reloadData];
	}
}



- (void)listingPeopleUpdated:(NSMutableDictionary *)listingPeople
{
	if (!listingPeople) {
		[detailTable reloadData];
	} else {
		self.peopleDictionary = listingPeople;
		//NSLog(@"Did Update people");
		
		
		if (tabSelected == checkinTabSelected) {
			[detailTable reloadData];
		}
		if ([self.navigationController.topViewController isKindOfClass:[GCDetailsRegularsViewController class]]) {
			[[(GCDetailsRegularsViewController *)self.navigationController.topViewController mainTableView] reloadData];
		}
	}

	
	
}

- (void)errorListingPeopleUpdate
{
	
	
}

#pragma mark Listing Images




- (void)didRecieveListingPhoto:(NSArray *)listingPhotos
{
	if (listingPhotos) {
		if ([listingPhotos count] > 0) {
			[allListingImages setArray:listingPhotos];
			for (NSMutableDictionary *photo in allListingImages) {
				if ([photo objectForKey:@"thumbnail_src_url"]) {
					requestCount++;
					NSURL *URL = [NSURL URLWithString:[photo objectForKey:@"thumbnail_src_url"]];
					[photo setObject:URL forKey:@"thumbnail_src_url"];
					ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:URL];
					[request setDelegate:self];
					[request setDidFinishSelector:@selector(requestDone:)];
					[request setDidFailSelector:@selector(requestWentWrong:)];
					[downloadQueue addOperation:request];
					[imageRequests addObject:request];
					[request release]; 
				}
			}
		} else {
			listingImage.image = [UIImage imageNamed:@"nobuilding-add.png"];
			[activityView stopAnimating];
		}
	} else {
		listingImage.image = [UIImage imageNamed:@"nobuilding-add.png"];
		[activityView stopAnimating];
	}
	requestSubmitDone = YES;
}

- (void)flipListingImage:(NSTimer *)timer
{
	if (currentImage >= [listingImages count]) {
		currentImage = 0;
	}
	if (currentImage >= 0 && currentImage < [listingImages count]) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:listingImage cache:YES];
		//[UIView setAnimationDelegate:self];
		// [UIView setAnimationDidStopSelector:@selector(animationFinished)];
		listingImage.image = [[listingImages objectAtIndex:currentImage] objectForKey:@"thumbnailImage"];
		[UIView commitAnimations];
		
		currentImage ++;
	}
	
}

- (void)showImageFlipperView
{
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Show Listing Images popup" withParameters:nil];
	imageFlipper = [[GCImageFlipper alloc] initWithImages:listingImages];
	imageFlipper.delegate = self;
	[imageFlipper show];
	[imageFlipper release];
}

- (void)imageFlipperWillClose:(GCImageFlipper *)flipper
{
	imageFlipper = nil;
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestDone:(ASIHTTPRequest *)request
{
	completeCount++;

    NSData *data = [request responseData];
    int statusCode = [request responseStatusCode];
	UIImage *remoteImage = nil;
	if (statusCode < 400 && data) {
		remoteImage = [[UIImage alloc] initWithData:data];

	}
	if (remoteImage) {
		for (NSMutableDictionary *photo in allListingImages) {
			if ([[request url] isEqual: [photo objectForKey:@"thumbnail_src_url"]]) {
				[photo setObject:remoteImage forKey:@"thumbnailImage"];
				[listingImages addObject:photo];
				break;
			}
		}
		if (completeCount == requestCount && [listingImages count] > 0 && requestSubmitDone) {
			[activityView stopAnimating];
			[noImageButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
			[noImageButton addTarget:self action:@selector(showImageFlipperView) forControlEvents:UIControlEventTouchUpInside];
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:listingImage cache:YES];
			
			listingImage.image = [[listingImages objectAtIndex:0] objectForKey:@"thumbnailImage"];
			[UIView commitAnimations];
			
			
			[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(flipListingImage:) userInfo:nil repeats:YES];
			for (NSMutableDictionary *photo in listingImages) {
				if ([photo objectForKey:@"image_src_url"]) {
					NSURL *URL = [NSURL URLWithString:[photo objectForKey:@"image_src_url"]];
					[photo setObject:URL forKey:@"image_src_url"];
					ASIHTTPRequest *aRequest = [[ASIHTTPRequest alloc] initWithURL:URL];
					[aRequest setDelegate:self];
					[aRequest setDidFinishSelector:@selector(requestDoneFull:)];
					[aRequest setDidFailSelector:@selector(requestWentWrongFull:)];
					[downloadQueue addOperation:aRequest];
					[imageRequests addObject:aRequest];
					[aRequest release]; 
				}
			}
			
		}
		[remoteImage release];
		
	} else {
		if (completeCount == requestCount && [activityView isAnimating] && requestSubmitDone) {
			[activityView stopAnimating];
			listingImage.image = [UIImage imageNamed:@"nobuilding-add.png"];
			[noImageButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
			[noImageButton addTarget:self action:@selector(submitPictureAction) forControlEvents:UIControlEventTouchUpInside];
		}
	}
	[imageRequests removeObject:request];
    
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
	completeCount++;
	if (completeCount == requestCount && [activityView isAnimating] && requestSubmitDone) {
		[activityView stopAnimating];
		listingImage.image = [UIImage imageNamed:@"nobuilding-add.png"];
		[noImageButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
		[noImageButton addTarget:self action:@selector(submitPictureAction) forControlEvents:UIControlEventTouchUpInside];
	}
	NSLog(@"Listing Image Request Error");
	[imageRequests removeObject:request];
	
}

- (void)requestDoneFull:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
	int statusCode = [request responseStatusCode];
	UIImage *remoteImage = nil;
	if (statusCode < 400 && data) {
		remoteImage = [[UIImage alloc] initWithData:data];
		
	}
	if (remoteImage) {
		int index = -1;
		for (NSMutableDictionary *photo in listingImages) {
			if ([[request url] isEqual: [photo objectForKey:@"image_src_url"]]) {
				[photo setObject:remoteImage forKey:@"fullImage"];
				index = [listingImages indexOfObject:photo];
				break;
			}
		}
		if (imageFlipper && index != -1) {
			[imageFlipper addlargeImage:remoteImage atIndex:index];
		}
		[remoteImage release];
		
	}
    [imageRequests removeObject:request];
}

- (void)requestWentWrongFull:(ASIHTTPRequest *)request
{
	NSLog(@"Listing Image Full Request Error");
	[imageRequests removeObject:request];
}

#pragma mark UserLogin Delegates

- (void)makeFanResult:(NSString *)result;
{
	BOOL status = [result boolValue];
	if (isFan) {
		if (status) {
			isFan = !isFan;
		}
		
	}
	else {
		if (status) {
			isFan = !isFan;
		}
	}
	if (tabSelected == detailTabSelected) {
		[detailTable reloadData];
	}
}

- (void)loginResult:(BOOL)result
{
	NSLog(@"Details recieved UL Delegate call loginResult");
	if (result) {
		[NSThread detachNewThreadSelector:@selector(checkListingStatus)toTarget:self withObject:nil];
	}
}



#pragma mark tableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tabSelected == detailTabSelected) {
		return 8;
	}
	else if (tabSelected == reviewsTabSelected) {
		return 2;
	} else if (tabSelected == checkinTabSelected) {
		int count = 2;
		if ([[peopleDictionary objectForKey:@"recentCheckins"] count] > 0) {
			count ++;
		}
		if ([[peopleDictionary objectForKey:@"olderCheckins"] count] > 0) {
			count ++;
		}
		return count;
		
	}
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tabSelected == detailTabSelected) {
		
		switch (section) {
			case phoneSection:
				if (!listing.phone || [listing.phone length]==0) {
					return 0;
				}
				else {
					return 1;
				}
			case verifiedSection:
				if (!listing.last_verified || [listing.last_verified length]==0) {
					return 0;
				}
				else {
					return 1;
				}
			case detailsSection:
				return 1;
			case descMgmtSection:
				if (!listing.desc_mgmt || [listing.desc_mgmt length]==0) {
					return 0;
				}
				else {
					return 1;
				}
			case webSection:
				if (!listing.website  || [listing.website length]==0) {
					return 0;
				}
				else {
					return 1;
				}
			default:
				return 1;
		}
		
		return 1;
	}
	else if (tabSelected == reviewsTabSelected) {
		if (section == 0) {
			return 1;
		} 
		return [listing.reviews count];
		
	} else if (tabSelected == checkinTabSelected) {
		if (section == 0) {
			return 1;
		} else if (section == 1) {
			int count = 1;
			if ([[peopleDictionary objectForKey:@"regulars"] count] > 0) {
				count ++;
			}
			return count;
		}else if (section == 2) {
			if ([[peopleDictionary objectForKey:@"recentCheckins"] count] > 0) {
				return [[peopleDictionary objectForKey:@"recentCheckins"] count];
			} else {
				return [[peopleDictionary objectForKey:@"olderCheckins"] count];
			}
		} else if (section == 3) {
			return [[peopleDictionary objectForKey:@"olderCheckins"] count];
		}
		
	}
	return 0;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (tabSelected == detailTabSelected) {
		return @"";
	}
	else if (tabSelected == reviewsTabSelected) {
		return @"";
	} else if (tabSelected == checkinTabSelected) {
		if (section == 0) {
			return @"";
		} else if (section == 1) {
			return @"";
		} else if (section == 2) {
			if ([[peopleDictionary objectForKey:@"recentCheckins"] count] > 0) {
				return @"Who's Here";
			} else {
				return @"Recent Activity";
			}
		} else if (section == 3) {
			return @"Recent Activity";
		}
		
	}
	return @"";
	
}*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (tabSelected == detailTabSelected) {
		return 0;
	}
	else if (tabSelected == reviewsTabSelected) {
		return 0;
	} else if (tabSelected == checkinTabSelected) {
		if (section == 0) {
			return 0;
		} else if (section == 1) {
			return 0;
		} else if (section == 2) {
			return 40;
		} else if (section == 3) {
			return 40;
		}
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (tabSelected == detailTabSelected) {
		return nil;
	}
	else if (tabSelected == reviewsTabSelected) {
		return nil;
	} else if (tabSelected == checkinTabSelected) {
		if (section == 0) {
			return nil;
		} else if (section == 1) {
			return nil;
		} else if (section == 2) {
			
			UILabel *label = [UILabel gcLabelForTableHeaderView];

			if ([[peopleDictionary objectForKey:@"recentCheckins"] count] > 0) {
				label.text = @"Who's Here";
				return label;
			} else {
				label.text = @"Recent Activity";
				return label;
			}
		} else if (section == 3) {
			
			UILabel *label = [UILabel gcLabelForTableHeaderView];

			
			label.text = @"Recent Activity";
			return label;
		}
		
	}
	return nil;
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if (tabSelected == detailTabSelected) {
		return nil;
	}
	else if (tabSelected == reviewsTabSelected) {
		return nil;
	} else if (tabSelected == checkinTabSelected) {
		if (section == 0) {
			return nil;
		} else if (section == 1) {
			UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)] autorelease];
			UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomCellFooter.png"]];
			iv.frame = CGRectMake(0, -9, 320, 14);
			[headerView addSubview:iv];
			[iv release];
			return headerView;
		} else if (section == 2) {
			UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)] autorelease];
			UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomCellFooterLarge.png"]];
			iv.frame = CGRectMake(0, 0, 320, 35);
			[headerView addSubview:iv];
			[iv release];
			return headerView;
		} else if (section == 3) {
			UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)] autorelease];
			UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottomCellFooterLarge.png"]];
			iv.frame = CGRectMake(0, 0, 320, 35);
			[headerView addSubview:iv];
			[iv release];
			return headerView;
		}
		
	}
	return nil;
}
 */


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	int section = [indexPath section];
	int row = [indexPath row];
	if (tabSelected == detailTabSelected) {

			if (section == phoneSection) {
				GCListingDetailCell *cell  = (GCListingDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"listingDetailCell-Phone"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingDetailCell-Phone" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
					cell.cellLabel.text = listing.phone;
					
					if ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]) {
						//cell.accessoryType = UITableViewCellAccessoryNone;
						cell.disclosureImage.hidden = YES;
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
					}
					else {
						//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						cell.disclosureImage.hidden = NO;
						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					}
				}
				return cell;
			}
			else if (section == addressSection) {
				
				
				GCListingDetailCell *cell  = (GCListingDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"listingDetailCell-Address"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingDetailCell-Address" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
					NSMutableString *address = [[NSMutableString alloc] init];
					if (listing.street && [listing.street length] > 0) {
						[address appendString:listing.street];
					}
					if (listing.city && [listing.city length] > 0) {
						if ([address length] > 0) {
							[address appendString:@"\n"];
						}
						[address appendString:listing.city];
						if (listing.state && [listing.state length] > 0) {
							[address appendFormat:@", %@", listing.state];
						}
						
					}
					if (listing.cross_street && [listing.cross_street length]>0) {
						if ([address length] > 0) {
							[address appendString:@"\n"];
						}
						[address appendFormat:@"(%@)", listing.cross_street];
					}
					if (listing.hood && [listing.hood length]>0) {
						if (![listing.hood isEqualToString:@"zzzOther"]) {
							if ([address length] > 0) {
								[address appendString:@"\n"];
							}
							[address appendFormat:@"In %@", listing.hood];
						}
						
					}
					
					
					cell.cellLabel.text = address;
					[address release];
					
					if ([listing.lat floatValue] == 0 && [listing.lng floatValue] == 0) {
						cell.disclosureImage.hidden = YES;
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
					} else {
						cell.disclosureImage.hidden = NO;
						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					}
				}
				
				return cell;
			}
			else if (section == detailsSection) {
				GCListingDetailCell *cell  = (GCListingDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"listingDetailCell-Notes"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingDetailCell-Notes" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
					cell.cellLabel.text= extraDetails;
				}

				return cell;
			}else if (section == descMgmtSection) {
				GCDetailExtrasCell *cell  = (GCDetailExtrasCell *)[tableView dequeueReusableCellWithIdentifier:@"detailExtrasCell"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCDetailExtrasCell" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
					cell.informationText.font = [UIFont systemFontOfSize:13];
				}
				cell.informationText.text= [NSString filterString:[NSString stringWithFormat:@"Management Adds: %@", listing.desc_mgmt]];

				
				return cell;
			} else if (section == verifiedSection) {
				GCDetailExtrasCell *cell  = (GCDetailExtrasCell *)[tableView dequeueReusableCellWithIdentifier:@"detailExtrasCell"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCDetailExtrasCell" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
					
					cell.informationText.font = [UIFont systemFontOfSize:13];
				}
				if (listing.username && ![listing.username isEqualToString:@""]) {
					cell.informationText.text= [NSString stringWithFormat:@"Last Verified on %@\nSubmitted by %@", listing.last_verified, listing.username];
				} else {
					cell.informationText.text= [NSString stringWithFormat:@"Last Verified on %@", listing.last_verified];
				}
				return cell;
			}
			else if (section== webSection) {
				
				GCListingDetailCell *cell  = (GCListingDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"listingDetailCell-URL"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingDetailCell-URL" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
					cell.cellLabel.text = listing.website;
					cell.cellLabel.font = [UIFont boldSystemFontOfSize:13];
					cell.cellLabel.numberOfLines = 1;
					cell.cellLabel.adjustsFontSizeToFitWidth = YES;
					
				}
				
				return cell;
				
			}
			else if (section== buttonSection) {
				GCReviewFanCell *cell  = (GCReviewFanCell *)[tableView dequeueReusableCellWithIdentifier:@"reviewFanCell"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCReviewFanCell" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
					[cell.fanButton addTarget:self action:@selector(setFan) forControlEvents:UIControlEventTouchUpInside];
					[cell.myListButton addTarget:self action:@selector(setBookmarks) forControlEvents:UIControlEventTouchUpInside];
					[cell.reviewButton addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
					[cell.checkInButton addTarget:self action:@selector(checkInHere) forControlEvents:UIControlEventTouchUpInside];
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.backgroundColor = [UIColor clearColor];

				}
				if (isFan) {
					[cell.fanButton setImage:[UIImage imageNamed:@"removeFanNew.png"] forState:UIControlStateNormal];
				}
				else {
					[cell.fanButton setImage:[UIImage imageNamed:@"addFanNew.png"] forState:UIControlStateNormal];
				}
				
				if (isBookmarked) {
					[cell.myListButton setImage:[UIImage imageNamed:@"removeMyListNew.png"] forState:UIControlStateNormal];
				}
				else {
					[cell.myListButton setImage:[UIImage imageNamed:@"addMyListNew.png"] forState:UIControlStateNormal];
				}
				

				return cell;
			}
			else if (section== errorSection) {
				GCSingleButtonCell *cell  = (GCSingleButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"singleButtonCell"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSingleButtonCell" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
					[cell.button setImage:[UIImage imageNamed:@"reportErrorLongOrange.png"] forState:UIControlStateNormal];
					cell.backgroundColor = [UIColor clearColor];
					[cell.button addTarget:self action:@selector(submitReport) forControlEvents:UIControlEventTouchUpInside];
				}
				

				return cell;
		
			}
		
		
		
	}
	else if (tabSelected == reviewsTabSelected) {
		
		if (section == 0) {
			GCSingleButtonCell *cell  = (GCSingleButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"singleButtonCell-Review"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSingleButtonCell-Review" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				[cell.button setImage:[UIImage imageNamed:@"writeAReviewLongOrange.png"] forState:UIControlStateNormal];
				cell.backgroundColor = [UIColor clearColor];
				[cell.button addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
			}
			
			
			return cell;
		}
		
		GCListingReviewCell *cell  = (GCListingReviewCell *)[tableView dequeueReusableCellWithIdentifier:@"listingReviewCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingReviewCell" owner:self options:nil];
			cell = [[[nib objectAtIndex:0] retain] autorelease];
			cell.userDetails.textColor = [UIColor darkGrayColor];
		}
		GCListingReview *review = [listing.reviews objectAtIndex:[indexPath row]];
		
		//[cell.userImage setImage:review.profileImage];
		cell.person = review;
		cell.userImage.image = nil;//person.profileImage;
		[cell loadImage];
		
		[cell.starsImage setImage:review.stars];
		
		cell.reviewTitle.text = review.r_title;
		cell.reviewText.text = review.r_text;
		cell.postDate.text = review.r_date;
		int numReviews = [review.u_num_reviews intValue];
		NSString *reviewText;
		if (numReviews == 1) {
			reviewText = [[NSString alloc] initWithString:@"1 Review"];
		}
		else {
			reviewText = [[NSString alloc] initWithFormat:@"%i Reviews", numReviews];
		}
		
		cell.userDetails.text = [NSString stringWithFormat:@"On %@ by %@ - %@/%@ - %@",review.r_date, review.username, review.u_age, review.u_gender, reviewText];
		[reviewText release];
			

		return cell;
	} else if (tabSelected == checkinTabSelected) {
		
		if (section == 0) {
			GCSingleButtonCell *cell  = (GCSingleButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"singleButtonCell-CheckIn"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCSingleButtonCell-CheckIn" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				[cell.button setImage:[UIImage imageNamed:@"checkInHereLongOrange.png"] forState:UIControlStateNormal];
				cell.backgroundColor = [UIColor clearColor];
				[cell.button addTarget:self action:@selector(checkInHere) forControlEvents:UIControlEventTouchUpInside];
			}
			return cell;
		}
		GCListingPeopleCell *cell;
		if (section == 1) {
			if (row == 0) {
				cell  = (GCListingPeopleCell *)[tableView dequeueReusableCellWithIdentifier:@"listingPeopleCell-Mayor"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingPeopleCell-Mayor" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
				}
				NSDictionary *checkinDetails = [peopleDictionary objectForKey:@"mayor"];
				if (!checkinDetails) {
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.disclosureImage.hidden = YES;
					cell.noKingMessage.hidden = NO;
					cell.noKingMessage.text = @"Loading...";
					cell.userName.text = @"";
					cell.profileImage.hidden = YES;
					cell.userDetails.text = @"";
					cell.shout.text = @"";
					cell.checkinDate.text = @"";
				} else if (![[peopleDictionary objectForKey:@"mayor"] objectForKey:@"user"]) {
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					cell.disclosureImage.hidden = YES;
					cell.noKingMessage.hidden = NO;
					cell.noKingMessage.text = [checkinDetails objectForKey:@"message"];
					cell.userName.text = @"";
					cell.profileImage.hidden = YES;
					cell.userDetails.text = @"";
					cell.shout.text = @"";
					cell.checkinDate.text = @"";
				} else {
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.disclosureImage.hidden = NO;
					cell.noKingMessage.hidden = YES;
					cell.noKingMessage.text = @"";
					cell.userName.text = [checkinDetails objectForKey:@"message"];
					cell.profileImage.hidden = NO;
					cell.profileImage.image = [checkinDetails objectForKey:@"profileImage"];
					cell.userDetails.text = [NSString stringWithFormat:@"%@/%@",[[checkinDetails objectForKey:@"user"] objectForKey:@"u_age"], [[checkinDetails objectForKey:@"user"] objectForKey:@"u_gender"]];
					cell.shout.text = @"";
					cell.checkinDate.text = @"";
				}
				
				
			} else {
				cell  = (GCListingPeopleCell *)[tableView dequeueReusableCellWithIdentifier:@"listingPeopleCell-Regulars"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingPeopleCell-Regulars" owner:self options:nil];
					cell = [[[nib objectAtIndex:0] retain] autorelease];
					cell.disclosureImage.hidden = NO;
					cell.noKingMessage.hidden = YES;
				}
				if ([[peopleDictionary objectForKey:@"regulars"] count] == 1) {
					GCPerson *person = [[peopleDictionary objectForKey:@"regulars"] objectAtIndex:0];
					cell.person = person;
					cell.profileImage.image = nil;//person.profileImage;
					[cell loadImage];
					cell.userName.text = @"Regulars";
					//cell.profileImage.image = person.profileImage;
					cell.userDetails.text = [person.user objectForKey:@"username"];
					cell.shout.text = @"";
					cell.checkinDate.text = @"";
				} else if ([[peopleDictionary objectForKey:@"regulars"] count] > 1) {
					GCPerson *person = [[peopleDictionary objectForKey:@"regulars"] objectAtIndex:0];
					GCPerson *person2 = [[peopleDictionary objectForKey:@"regulars"] objectAtIndex:1];
					cell.userName.text = @"Regulars";
					cell.person = person;
					cell.profileImage.image = nil;//person.profileImage;
					[cell loadImage];
					//cell.profileImage.image = person.profileImage;
					cell.userDetails.text = [NSString stringWithFormat:@"%@, %@",[person.user objectForKey:@"username"], [person2.user objectForKey:@"username"]];
					cell.shout.text = @"";
					cell.checkinDate.text = @"";
					
				} else {
					cell.userName.text = @"Regulars";
					cell.profileImage.image = nil;
					cell.userDetails.text = @"";
					cell.shout.text = @"";
					cell.checkinDate.text = @"";
					cell.person = nil;
				}

				

			}
			return cell;					
		} else {
			cell = (GCListingPeopleCell *)[tableView dequeueReusableCellWithIdentifier:@"listingPeopleCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GCListingPeopleCell" owner:self options:nil];
				cell = [[[nib objectAtIndex:0] retain] autorelease];
				cell.disclosureImage.hidden = NO;
				cell.noKingMessage.hidden = YES;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;			
			}
			GCPerson *person;
			if (section == 2) {
				if ([[peopleDictionary objectForKey:@"recentCheckins"] count] > 0) {
					person = (GCPerson *)[[peopleDictionary objectForKey:@"recentCheckins"] objectAtIndex:row];
				} else {
					person = (GCPerson *)[[peopleDictionary objectForKey:@"olderCheckins"] objectAtIndex:row];
				}
			} else {
				person = (GCPerson *)[[peopleDictionary objectForKey:@"olderCheckins"] objectAtIndex:row];
			}
			cell.person = person;
			cell.profileImage.image = nil;//person.profileImage;
			[cell loadImage];
			
			cell.userName.text = [person.user objectForKey:@"username"];
			//cell.profileImage.image = person.profileImage;
			cell.shout.text = person.shout;
			cell.userDetails.text = [NSString stringWithFormat:@"%@/%@", [person.user objectForKey:@"u_age"], [person.user objectForKey:@"u_gender"]];
			cell.checkinDate.text = [NSString stringForCreatedTimeWithDate:person.createdTime];
								
			return cell;					
			//checkinDate - checkinTime
		
		}

	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tabSelected == detailTabSelected) {
		if ([indexPath section] == phoneSection) {
			return 50;
		}
		
		else if ([indexPath section] == errorSection) {
			return 60;
		}
		
		else if ([indexPath section] == addressSection) {
			NSMutableString *address = [[NSMutableString alloc] init];
			if (listing.street && [listing.street length] > 0) {
				[address appendString:listing.street];
			}
			if (listing.city && [listing.city length] > 0) {
				if ([address length] > 0) {
					[address appendString:@"\n"];
				}
				[address appendString:listing.city];
				if (listing.state && [listing.state length] > 0) {
					[address appendFormat:@", %@", listing.state];
				}
				
			}
			if (listing.cross_street && [listing.cross_street length]>0) {
				if ([address length] > 0) {
					[address appendString:@"\n"];
				}
				[address appendFormat:@"(%@)", listing.cross_street];
			}
			if (listing.hood && [listing.hood length]>0) {
				if ([address length] > 0) {
					[address appendString:@"\n"];
				}
				[address appendFormat:@"In %@", listing.hood];
			}
			
			
			CGSize reviewSize;
			CGSize constraint = CGSizeMake(223,2000);
			reviewSize = [address sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
			[address release];
			return 20 + reviewSize.height;
		}

		else if ([indexPath section]== detailsSection) {
			CGSize reviewSize;
			CGSize constraint = CGSizeMake(223,2000);
			reviewSize = [extraDetails sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
			if ((20 + reviewSize.height) < 50) {
				return 50;
			}
			return 20 + reviewSize.height;
		} 
		else if ([indexPath section]== descMgmtSection) {
			CGSize reviewSize;
			CGSize constraint = CGSizeMake(272,2000);
			reviewSize = [[NSString stringWithFormat:@"Management Adds: %@", listing.desc_mgmt] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
			return 23 + reviewSize.height;
		} 
		else if ([indexPath section] == buttonSection) {
			return 70;
		} 
		else if ([indexPath section] == webSection) {
			return 50;
		} 
		else if ([indexPath section] == verifiedSection) {
			if (listing.username && ![listing.username isEqualToString:@""]) {
				return 70;
			}
			return 45;
		} 
		else {
			return 44;
		}
	}
	else if (tabSelected == reviewsTabSelected) {
		if ([indexPath section] == 0) {
			return 60;
		}
		
		CGSize reviewSize;
		CGSize constraint = CGSizeMake(290,2000);
		reviewSize = [[[listing.reviews objectAtIndex:[indexPath row]] r_text] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
		if ((67 + reviewSize.height) < 75) {
			return 75;
		}
		return 67 + reviewSize.height;
	} 
	else if (tabSelected == checkinTabSelected) {
		if ([indexPath section] == 0) {
			return 60;
		} else if ([indexPath section] == 1) {
				return 48;

		} else {
			int row = [indexPath row];
			GCPerson *person;
			if ([indexPath section] == 2) {
				int recentRows = [[peopleDictionary objectForKey:@"recentCheckins"] count];
				if (recentRows > 0) {
					person = (GCPerson *)[[peopleDictionary objectForKey:@"recentCheckins"] objectAtIndex:row];
					
				} else {
					person = (GCPerson *)[[peopleDictionary objectForKey:@"olderCheckins"] objectAtIndex:row];
				}

			} else {
				person = (GCPerson *)[[peopleDictionary objectForKey:@"olderCheckins"] objectAtIndex:row];
			}
			if ([person.shout length] > 0) {
				CGSize size;
				CGSize constraint = CGSizeMake(155,2000);
				size = [person.shout  sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraint lineBreakMode: UILineBreakModeWordWrap];
				return 48 + size.height;
			}
							
		}
		return 48;	

	}	
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[GCSingleButtonCell class]]) {
		return;
	}
	int section = [indexPath section];
	int row = [indexPath row];
	if (tabSelected == detailTabSelected) {
		
		if (section == phoneSection){
			if ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]) {
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				return;
			}
			

			UIAlertView *callingAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Call %@?",listing.phone] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
			callingAlert.tag = 10;
			[callingAlert show];
			[callingAlert release];
		} 
		else if (section == addressSection){
			if (communicator.noInternet) {
				UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Connect" message:@"Since there appears to be no internet, the map cannot be displayed at this time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[noInternetAlert show];
				[noInternetAlert release];
				[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
				return;
			} else if ([listing.lat floatValue] == 0 && [listing.lng floatValue] == 0) {
			} else {
				[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Show map" withParameters:nil];
				OCMapViewController	*mapViewController = [[OCMapViewController alloc] init];
				mapViewController.listing = listing;
				[[self navigationController] pushViewController:mapViewController animated:YES];
				[mapViewController release];
			}

			
		}
		else if (section == webSection){
			

			if (communicator.noInternet) {
				UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Connect" message:@"Since there appears to be no internet, the web page cannot be displayed at this time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[noInternetAlert show];
				[noInternetAlert release];
				[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
				return;
			} 
			[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Show website" withParameters:nil];
			NSURL *url = [NSURL URLWithString:listing.website];
			OCWebViewController	*webViewController = [[OCWebViewController alloc] init];
			
			[webViewController setURL:url andName:listing.name];
			[[self navigationController] pushViewController:webViewController animated:YES];
			[webViewController release];
			
			


		}
		

	} else if (tabSelected == checkinTabSelected) {
		

		if (section == 0) {
			[self checkInHere];
		}
		
		else if (section == 1) {
			if (row == 0) {
				if (![[peopleDictionary objectForKey:@"mayor"] objectForKey:@"user"]) {
					[tableView deselectRowAtIndexPath:indexPath animated:NO];
				} else {
					[self openProfilePageForUser:[[[peopleDictionary objectForKey:@"mayor"] objectForKey:@"user"] objectForKey:@"username"]];
				}

			} else if (row == 1) {
				GCDetailsRegularsViewController *rvc = [[GCDetailsRegularsViewController alloc] init];
				rvc.regulars = [peopleDictionary objectForKey:@"regulars"];
				[self.navigationController pushViewController:rvc animated:YES];
				[rvc release];
			}
			
			
		} else if (section == 2) {
			if ([[peopleDictionary objectForKey:@"recentCheckins"] count] > 0) {
				GCPerson *person = [[peopleDictionary objectForKey:@"recentCheckins"] objectAtIndex:[indexPath row]];
				[self openProfilePageForUser:[person.user objectForKey:@"username"]];

			} else {
				GCPerson *person = [[peopleDictionary objectForKey:@"olderCheckins"] objectAtIndex:[indexPath row]];
				[self openProfilePageForUser:[person.user objectForKey:@"username"]];
			}
		} else {
			GCPerson *person = [[peopleDictionary objectForKey:@"olderCheckins"] objectAtIndex:[indexPath row]];
			[self openProfilePageForUser:[person.user objectForKey:@"username"]];
		}
		
		
		
	} else if (tabSelected == reviewsTabSelected) {
		GCListingReview *review = [listing.reviews objectAtIndex:[indexPath row]];
		[self openProfilePageForUser:review.username];

	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 10) {
		if (buttonIndex == 1) {
			[self call];
		}
	} else if (alertView.tag == 11) {
		if (buttonIndex == 1) {
			[self submitReview];
		}
	}
	
}


#pragma mark Misc Methods

- (void)openProfilePageForUser:(NSString *)username
{
	if (communicator.noInternet) {
		UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Can't Connect" message:@"Since there appears to be no internet, the web page cannot be displayed at this time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noInternetAlert show];
		[noInternetAlert release];
	} else {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-View user profile" withParameters:nil];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gaycities.com/reviewer/%@?iphone=1",username]];
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
		
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
		webViewController.profileRequest = request;
		[[self navigationController] pushViewController:webViewController animated:YES];
		[webViewController release];
		[request release];
	}
	
}

- (void)checkInHere
{
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	[gcad logEventForFlurry:@"DETAILS_LISTING-Check-in button Pressed" withParameters:nil];
	if (listingDistance <= kDefaultCheckinDistance) {
		if ([communicator.ul shouldCheckInToListing]) {
			GCListingCheckinViewController *lcivc = [[GCListingCheckinViewController alloc] init];
			lcivc.listing = listing;

			UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:lcivc];
			//lcivc.communicator = communicator;
			[self.navigationController presentModalViewController:controller animated:YES];
			[controller release];
			[lcivc release];
		} else {
			[gcad logEventForFlurry:@"DETAILS_LISTING-Checkin result-user not logged in" withParameters:nil];
		}
		

	} else {
		[gcad logEventForFlurry:@"DETAILS_LISTING-Checkin result-user not close enough" withParameters:nil];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You must be closer nearby to checkin here" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	} // should we show an alert for no location?
}

-(void)call
{
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Phone call" withParameters:nil];
	NSMutableString *phoneNumber = [NSMutableString stringWithString:listing.phone];
	[phoneNumber replaceOccurrencesOfString:@"(" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [phoneNumber length])];
	[phoneNumber replaceOccurrencesOfString:@")" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [phoneNumber length])];
	[phoneNumber replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [phoneNumber length])];
	[phoneNumber replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [phoneNumber length])];
	[phoneNumber replaceOccurrencesOfString:@"." withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [phoneNumber length])];
	[phoneNumber replaceOccurrencesOfString:@"+" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [phoneNumber length])];
	[phoneNumber replaceOccurrencesOfString:@"/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [phoneNumber length])];


	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];
}

-(IBAction)submitPictureAction
{
	if (imageFlipper) {
		return;
	}
	[communicator.ul uploadPhoto:listing.listing_id type:listing.type];
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Upload listing photo" withParameters:nil];
}

-(void)setBookmarks
{
	
	if (isBookmarked) {
		if ([communicator.listings.myList deleteBookmark:listing.listing_id withType:listing.type]) {
			isBookmarked = NO;
		}
	}
	else {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Add My List" withParameters:nil];
		if ([communicator.listings.myList addBookmark:listing]) {
			isBookmarked = YES;
		}
	}
	
	if (tabSelected == detailTabSelected) {
		[detailTable reloadData];
	}
}

-(void)setFan
{
	if (isFan) {
		[communicator.ul makeFan:listing.listing_id type:listing.type status:@"X"];
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Fan status-Remove listing" withParameters:nil];

	}
	else {
		[communicator.ul makeFan:listing.listing_id type:listing.type status:@"A"];
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Fan status-Add Listing" withParameters:nil];

	}
	
	
}

-(void)submitReview
{
	
	NSLog(@"need something reviewed to make sure dict values havent changed.");
	if (isReviewed) {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Write Review-Update" withParameters:nil];
		NSLog(@"is reviewed");
		[communicator.ul submitReview:listing.listing_id type:listing.type update:@"1" previousReview:userStatus];
	}
	else {
		[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Write Review-NEW" withParameters:nil];
		NSLog(@"not reviewed");
		[communicator.ul submitReview:listing.listing_id type:listing.type update:@"0" previousReview:[NSDictionary dictionary]];
		isReviewed = YES;
	}

}

-(void)submitReport
{
	[[GayCitiesAppDelegate sharedAppDelegate] logEventForFlurry:@"DETAILS_LISTING-Submit data report" withParameters:nil];
	[communicator.ul submitDataReport:listing.listing_id type:listing.type];
}





// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	//[super didReceiveMemoryWarning]; 
	NSLog(@"Detail View Memory warning");
	if ([[self navigationController] visibleViewController]==self) {
		return;
	}
	
	
}


- (void)dealloc {
	[NSThread detachNewThreadSelector:@selector(saveReviewsToDatabase:) toTarget:communicator.listings withObject:listing];
	for (ASIHTTPRequest *request in imageRequests) {
		[request setDelegate:nil];
	}
	[imageRequests removeAllObjects];
	self.imageRequests = nil;
	[communicator cancelOtherRequests];
	communicator.listingDelegate = nil;
	communicator.ul.delegate = communicator;
	self.detailTable = nil;
	[savePath release];
	self.extraDetails = nil;
	self.userStatus = nil;
	self.detailButton = nil;
	self.reviewsButton = nil;
	self.peopleButton = nil;
	self.nameLabel = nil;
	self.oneLinerLabel = nil;;
	self.listingImage = nil;
	self.starsImage = nil;
	self.noImageButton = nil;
	self.listing = nil;
	self.tableHeaderView = nil;
	self.activityView = nil;
	[downloadQueue release];
	self.listingImage = nil;
  [super dealloc];

}



@end
