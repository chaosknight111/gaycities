//
//  GCImageFlipper.m
//  Gay Cities
//
//  Created by Brian Harmann on 1/31/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import "GCImageFlipper.h"
#import "GayCitiesAppDelegate.h"
#import "GCLabel.h"

static CGFloat kBorderGray[4] = {0.3, 0.3, 0.3, 0.8};
//static CGFloat kBorderBlack[4] = {0.3, 0.3, 0.3, 1};
//static CGFloat kBorderBlue[4] = {0.23, 0.35, 0.6, 1.0};

static CGFloat kTransitionDuration = 0.3;

//static CGFloat kTitleMarginX = 8;
//static CGFloat kTitleMarginY = 4;
static CGFloat kPadding = 10;
//static CGFloat kBorderWidth = 10;

@implementation GCImageFlipper

@synthesize scrollView, images, pageControl, largeImages, delegate;

- (id)initWithImages:(NSArray *)newImages;
{
	if (self = [super initWithFrame:CGRectMake(0, 20, 320, 460)]) {
        // Initialization code
		pageControlUsed = NO;
		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.contentMode = UIViewContentModeRedraw;
		CGFloat innerWidth = self.frame.size.width - (kPadding * 2);  
		
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kPadding,kPadding,innerWidth,self.frame.size.height - (kPadding * 3))];
		scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		scrollView.backgroundColor = [UIColor blackColor];
		self.images = newImages;
		scrollView.pagingEnabled = YES;
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [images count], scrollView.frame.size.height);
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.scrollsToTop = NO;
		scrollView.delegate = self;
		[self addSubview:scrollView];
		float width = scrollView.frame.size.width;
		float height = scrollView.frame.size.height;
		int count = 0;
		for (NSMutableDictionary *image in images) {
			UIImageView *imageView;
			if ([image objectForKey:@"fullImage"]) {
				imageView = [[UIImageView alloc] initWithImage:[image objectForKey:@"fullImage"]];
			} else {
				imageView = [[UIImageView alloc] initWithImage:[image objectForKey:@"thumbnailImage"]];

			}
			imageView.frame = CGRectMake((count * width) + (kPadding/2), kPadding/2, width - kPadding, height - (kPadding * 6));
			NSUInteger index = [images indexOfObject:image] + 1000;
			imageView.tag = index;
			if (![image objectForKey:@"fullImage"]) {
				UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(imageView.frame.size.width/2 - 18, imageView.frame.size.height/2 - 18, 37, 37)];
				activityView.tag = index + 1000;
				[imageView addSubview:activityView];
				[activityView startAnimating];
				[activityView release];
			}
			imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			imageView.backgroundColor = [UIColor clearColor];
			[scrollView addSubview:imageView];
			[imageView release];
			GCLabel *label = [[GCLabel alloc] initWithFrame:CGRectMake((count * width) + (kPadding/2), height - (kPadding * 4.5), width - kPadding, (kPadding * 3.5))];
			label.numberOfLines = 2;
			label.minimumFontSize = 10;
			label.adjustsFontSizeToFitWidth = YES;
			label.backgroundColor = [UIColor clearColor];
			label.textColor = [UIColor whiteColor];
			label.font = [UIFont systemFontOfSize:14];
			label.textAlignment = UITextAlignmentCenter;
			label.verticalAlignment = VerticalAlignmentTop;
			NSMutableString *text = [[NSMutableString alloc] initWithString:[image objectForKey:@"caption"]];
			if ([text length] > 0) {
				[text appendString:@"\n"];
			}
			if ([[image objectForKey:@"photog_name"] length] > 0) {
				[text appendFormat:@"'%@' ", [image objectForKey:@"photog_name"]];
			}
			if ([[image objectForKey:@"username"] length] > 0) {
				[text appendFormat:@"Submitted by %@", [image objectForKey:@"username"]];
			}
			label.text = text;
			[scrollView addSubview:label];
			[text release];
			[label release];
			count++;
			
		}
		pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(kPadding, self.frame.size.height - (kPadding * 3), innerWidth, 36)];
		pageControl.hidesForSinglePage = NO;
		pageControl.numberOfPages = [images count];
		pageControl.currentPage = 0;
		[pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:pageControl];
		[pageControl release];
		[scrollView release];

		
    }
    return self;
}

- (void)addlargeImage:(UIImage *)image atIndex:(int)index
{
	UIImageView *iv = (UIImageView *)[scrollView viewWithTag:(index + 1000)];
	[iv setImage:image];
	[(UIActivityIndicatorView *)[iv viewWithTag:(index + 2000)] removeFromSuperview];
}


- (void)drawRect:(CGRect)rect {
	CGRect grayRect = CGRectInset(rect, 2, 2);
	[self drawRect:grayRect fill:kBorderGray radius:10];
	
	//CGRect imageRect = CGRectMake(ceil(rect.origin.x + kBorderWidth), ceil(rect.origin.y + kBorderWidth),rect.size.width - kBorderWidth*2, scrollView.frame.size.height+1);
	//[self strokeLines:webRect stroke:kBorderBlack];
}


- (void)dealloc {
	//self.pageControl = nil;
	//self.scrollView = nil;
	self.images = nil;
	self.largeImages = nil;
	self.delegate = nil;
    [super dealloc];
}

- (void)show
{
	//CGFloat innerWidth = self.frame.size.width - 22;  
	//scrollView.frame = CGRectMake(11,11,innerWidth,self.frame.size.height - 32);
	
	[[[GayCitiesAppDelegate sharedAppDelegate] window] addSubview:self];
	[[GayCitiesAppDelegate sharedAppDelegate] adBackgroundView].hidden = YES;
	[GayCitiesAppDelegate sharedAppDelegate].shouldShowAdView = NO;
	
	self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
	self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
	[UIView commitAnimations];
}

- (void)postDismissCleanup {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(imageFlipperWillClose:)]) {
			[delegate imageFlipperWillClose:self];
		}
	}
	GayCitiesAppDelegate *gcad = [GayCitiesAppDelegate sharedAppDelegate];
	[self removeFromSuperview];
	[gcad adBackgroundView].hidden = NO;
	gcad.shouldShowAdView = YES;
}

- (void)dismiss {
	
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kTransitionDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
		self.alpha = 0;
		[UIView commitAnimations];
}


- (void)bounce1AnimationStopped {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce3AnimationStopped)];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];

}

- (void)bounce3AnimationStopped 
{
	//scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [images count], scrollView.frame.size.height);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(self.frame.size.width - 35, 0, 35, 35);
	[button setImage:[UIImage imageNamed:@"listingImageCloseButton.png"] forState:UIControlStateNormal];
	button.showsTouchWhenHighlighted = YES;
	[button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
}

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
	CGContextBeginPath(context);
	CGContextSaveGState(context);
	
	if (radius == 0) {
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextAddRect(context, rect);
	} else {
		//rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
		CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
		CGContextScaleCTM(context, radius, radius);
		float fw = CGRectGetWidth(rect) / radius;
		float fh = CGRectGetHeight(rect) / radius;
		
		CGContextMoveToPoint(context, fw, fh/2);
		CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
		CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
		CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
		CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	}
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	if (fillColors) {
		CGContextSaveGState(context);
		CGContextSetFillColor(context, fillColors);
		if (radius) {
			[self addRoundedRectToPath:context rect:rect radius:radius];
			CGContextFillPath(context);
		} else {
			CGContextFillRect(context, rect);
		}
		CGContextRestoreGState(context);
	}
	
	CGColorSpaceRelease(space);
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}


@end
