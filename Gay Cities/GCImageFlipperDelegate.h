//
//  ImageFlipperDelegate.h
//  Gay Cities
//
//  Created by Brian Harmann on 2/9/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GCImageFlipper;

@protocol GCImageFlipperDelegate

@optional 
- (void)imageFlipperWillClose:(GCImageFlipper *)flipper;


@end
