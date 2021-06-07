//
//  AskLoginCreateViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 4/26/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCAskLoginCreateViewControllerDelegate.h"

@interface GCAskLoginCreateViewController : UIViewController {
	UILabel *greetingTextLabel;
	NSString *greetingText;
	NSObject<GCAskLoginCreateViewControllerDelegate> *gcDelegate;
	UIButton *cancelButton;
	UITextField *usernameText, *passwordText;
	UIView *signinContentView;
	BOOL initialLaunch;
}

@property (nonatomic, retain) IBOutlet UILabel *greetingTextLabel;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property(nonatomic, copy) NSString *greetingText;
@property (nonatomic, assign) NSObject<GCAskLoginCreateViewControllerDelegate> *gcDelegate;
@property (nonatomic, retain) IBOutlet UITextField *usernameText, *passwordText;
@property (nonatomic, retain) IBOutlet UIView *signinContentView;

- (id)initWithGreeting:(NSString *)newGreeting;
- (id)initWithGreetingInitialLaunch:(NSString *)newGreeting;
- (IBAction)signInNow;
- (IBAction)signUpNewNow;
- (IBAction)cancelNow;

- (IBAction)setUsername:(id)sender;
- (IBAction)setPassword:(id)sender;
//- (IBAction)moveViewUp:(id)sender;
//- (IBAction)moveViewDown:(id)sender;
- (IBAction)textFieldEditingStarted:(id)sender;

@end
