//
//  RootViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 11/21/08.
//  Copyright Obsessive Code 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RMMapView.h"
#import "RMMarkerManager.h"
#import "GCCommunicator.h"
#import "GCCityChangeViewController.h"
@class GCMainCheckinViewController;

@interface RootViewController : UIViewController <RMMapViewDelegate, UIActionSheetDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate, GCCommunicatorDelegate, GCCityViewControllerDelegate, RMMapContentsAnimationCallback>{

	RMMapView *mapView;
	UITableView	*listingTypeTable;
	RMMarker *previousMarker, *myMarker;
	NSString *bundlePath;
	BOOL stillStarting, zoomDone, filterDisplayed;
	int locationUpdateCount, tabBarSelected, currentAction, currentMetroID;
	GCCommunicator *communicator;
	UILabel *mapFilterLabel;
	GCMainCheckinViewController *mcivc;
	//UIButton *checkinNowButton;
}

@property (nonatomic, retain) IBOutlet UITableView *listingTypeTable;
@property (nonatomic, retain) RMMarker *myMarker;
@property (nonatomic, assign) RMMarker *previousMarker;
@property (nonatomic, retain) RMMapView *mapView;
@property (nonatomic, retain) GCCommunicator *communicator;
@property (nonatomic, retain) IBOutlet UILabel *mapFilterLabel;
//@property (nonatomic, retain) IBOutlet UIButton *checkinNowButton;
 
- (void)findMe;
- (void)centerMap:(CLLocationCoordinate2D)loc;
- (void)centerMapWithoutPoint:(CLLocationCoordinate2D)loc;
-(void)dropCurrentLocationPin:(CLLocationCoordinate2D)loc;
- (void)dropPins;
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;
- (void)zoomMap;
- (void)dropAndZoom;
- (void)startupRoutine;
- (void)selectTabBar;
- (void)createMapView;
- (void)changeCity:(NSString *)instructionText;
- (void)closeMoreActions;

- (IBAction)checkinPressedForlisting;

@end
