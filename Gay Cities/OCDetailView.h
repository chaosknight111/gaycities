//
//  OCDetailView.h
//  DetailView
//
//  Created by Brian Harmann on 7/31/09.
//  Copyright 2009 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCListing.h"

@interface OCDetailView : UIView {
	UILabel *textLabel, *captionLabel;
	CGPoint anchorPoint;
	UIColor *detailColor, *textColor;
	UIButton *detailButton;
	BOOL buttonShown;
	float ex;
	//GCListing *listing;
}

@property (nonatomic, retain) UILabel *textLabel, *captionLabel;
@property (readwrite) CGPoint anchorPoint;
@property (nonatomic, retain) UIColor *detailColor, *textColor;
@property (nonatomic, retain) UIButton *detailButton;
//@property (nonatomic, assign) GCListing *listing;

- (id)initWithText:(NSString *)newText andAnchorPoint:(CGPoint)point andCaption:(NSString *)captionText;
- (void)setButtonAction:(SEL)action toObject:(id)target forEvent:(UIControlEvents)event;
- (void)setAnchorX:(float)x;

@end
