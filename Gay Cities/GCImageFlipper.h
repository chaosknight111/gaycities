//
//  GCImageFlipper.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/31/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCImageFlipperDelegate.h"

@interface GCImageFlipper : UIView <UIScrollViewDelegate> {
	UIScrollView *scrollView;
	NSArray *images, *largeImages;
	UIPageControl *pageControl;
	BOOL pageControlUsed;
	NSObject<GCImageFlipperDelegate> *delegate;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, copy) NSArray *images, *largeImages;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, assign) NSObject *delegate;

- (id)initWithImages:(NSArray *)newImages;
- (void)show;
- (void)dismiss;
- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius;
- (void)addlargeImage:(UIImage *)image atIndex:(int)index;

@end
