//
//  GCReviewVC.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/4/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BAUIStarSlider;
#import "GCReviewVCDelegate.h"

@interface GCReviewVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate> {
	UITextField *reviewTitle;
	UITextView *reviewText;
	UIPickerView *reviewVisited;
	BAUIStarSlider *reviewRating;
	NSDictionary *previousReview;
	int month, year;
	NSObject<GCReviewVCDelegate> *reviewDelegate;
	NSDateFormatter *dateFormatterY;
}

@property (nonatomic, retain) IBOutlet UITextField *reviewTitle;
@property (nonatomic, retain) IBOutlet UITextView *reviewText;
@property (nonatomic, retain) IBOutlet UIPickerView *reviewVisited;
@property (nonatomic, retain) BAUIStarSlider *reviewRating;
@property (nonatomic, retain) NSDictionary *previousReview;
@property (readwrite) int month, year;
@property (nonatomic, assign) NSObject<GCReviewVCDelegate> *reviewDelegate;

- (id)initWithReview:(NSDictionary *)review;
- (IBAction)resignReviewTitle;

@end
