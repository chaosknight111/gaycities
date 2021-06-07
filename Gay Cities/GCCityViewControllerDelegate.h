//
//  OCCityViewControllerDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/30/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GCCityViewControllerDelegate

@required
- (void)cityViewDidSelectMetro:(GCMetro *)newMetro;
- (void)cityViewDidCancel;
- (void)cityViewDidSelectNearby;

@end


