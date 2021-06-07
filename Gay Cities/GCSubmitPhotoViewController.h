//
//  GCSumbitPhotoViewController.h
//  Gay Cities
//
//  Created by Brian Harmann on 7/4/10.
//  Copyright 2010 [obsessivecode]. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCSubmitPhotoViewControllerDelegate.h"

@interface GCSubmitPhotoViewController : UIViewController {
	UITextField *captionTextField;
	UILabel *captionLabel;
	UIImageView *imageView;
	UIImage *image;
	BOOL showCaption;
	NSObject<GCSubmitPhotoViewControllerDelegate> *delegate;

}

@property (nonatomic, retain) IBOutlet UITextField *captionTextField;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *captionLabel;
@property (nonatomic, retain) UIImage *image;
@property (readwrite) BOOL showCaption;
@property (nonatomic, assign) NSObject<GCSubmitPhotoViewControllerDelegate> *delegate;

- (id)initWithImage:(UIImage *)anImage showingCaption:(BOOL)show withDelegate:(NSObject<GCSubmitPhotoViewControllerDelegate> *)photoDelegate;
- (IBAction)submitImageAndClose:(id)sender;
- (IBAction)cancelAndClose:(id)sender;


@end
