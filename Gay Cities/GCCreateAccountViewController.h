//
//  GCCreateAccountViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 3/19/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCCreateAccountViewControllerDelegate.h"

@interface GCCreateAccountViewController : UIViewController {
	UITextField *usernameField, *passwordField1, *passwordField2, *emailField, *zipField;
	UILabel *birthdayLabel, *passwordsVerifyLabel, *headerReportLabel;
	UISegmentedControl *genderControl, *newsletterControl;
	UIDatePicker *birthdayPicker;
	UIView *birthdaySlideUpView;
	NSString *createUsername, *createPassword, *createEmail, *createZip, *createBirthMonth, *createBirthDay, *createBirthYear, *createGender, *createNewsletterOption;
	NSObject<GCCreateAccountViewControllerDelegate> *gcDelegate;
	BOOL birthdayPickerShown;
  NSDate *birthDate;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField, *passwordField1, *passwordField2, *emailField, *zipField;
@property (nonatomic, retain) IBOutlet UILabel *birthdayLabel, *passwordsVerifyLabel, *headerReportLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *genderControl, *newsletterControl;
@property (nonatomic, retain) IBOutlet UIDatePicker *birthdayPicker;
@property (nonatomic, retain) IBOutlet UIView *birthdaySlideUpView;
@property (nonatomic, copy) NSString *createUsername, *createPassword, *createEmail, *createZip, *createBirthMonth, *createBirthDay, *createBirthYear, *createGender, *createNewsletterOption;
@property (nonatomic, retain) NSDate *birthDate;
@property (nonatomic, assign) NSObject<GCCreateAccountViewControllerDelegate> *gcDelegate;

- (IBAction)saveUsernameText;
- (IBAction)savePasswordOneText;
- (IBAction)savePasswordTwoText;
- (IBAction)saveEmailText;
- (IBAction)saveZipText;
- (IBAction)showBirthdayPicker;
- (IBAction)closeBirthdayPicker;
- (IBAction)saveGenderSelection;
- (IBAction)saveNewsletterSelection;
- (void)cancelNewAccount;
- (void)submitNewAccount;
- (IBAction)editingBeginning:(id)sender;
- (IBAction)resignNow:(id)sender;
- (void)selectNextField:(id)sender;

@end
