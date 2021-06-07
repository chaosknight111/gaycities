//
//  GCDataReportVC.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/4/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDataReportVCDelegate.h";

@interface GCDataReportVC : UIViewController <UITextViewDelegate, UIPickerViewDelegate> {

	UITextView *reportTextView;
	NSObject<GCDataReportVCDelegate> *delegate;
	UIPickerView *datePicker;
	int month, year;
	NSDateFormatter *dateFormatterY, *dateFormatterM;
	UILabel *reportDate;
	UIView *dateView;
}

@property (nonatomic, retain) IBOutlet UITextView *reportTextView;
@property (nonatomic, assign) NSObject<GCDataReportVCDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UIPickerView *datePicker;
@property (readwrite) int month, year;
@property (nonatomic, retain) IBOutlet UILabel *reportDate;
@property (nonatomic, retain) IBOutlet UIView *dateView;

- (id)initWithDelegate:(NSObject<GCDataReportVCDelegate> *)reportDelegate;
- (IBAction)submitReportAndClose:(id)sender;
- (IBAction)cancelAndClose:(id)sender;

- (IBAction)showDatePicker:(id)sender;
- (IBAction)closeDatePicker:(id)sender;

@end
