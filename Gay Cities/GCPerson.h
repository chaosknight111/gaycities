//
//  GCPerson.h
//  Gay Cities
//
//  Created by Brian Harmann on 1/17/10.
//  Copyright 2010 Obsessive Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCPersonDelegate.h"
#import "ASIHTTPRequest.h"

@interface GCPerson : NSObject {
	NSString *created, *display, *shout, *update_type, *checkin_id, *u_photo_url;
	NSDate *createdTime;
	NSMutableDictionary *user;
	UIImage *profileImage;
	NSObject<GCPersonDelegate> *delegate;
	ASIHTTPRequest *request;
	BOOL profileImageAlreadyRequested;
}

@property (nonatomic, copy) NSString *created, *display, *shout, *update_type, *checkin_id, *u_photo_url;
@property (nonatomic, retain) NSDate *createdTime;
@property (nonatomic, retain) NSMutableDictionary *user;
@property (nonatomic, retain) UIImage *profileImage;
@property (nonatomic, assign) NSObject<GCPersonDelegate> *delegate;

- (id)initWithImage:(UIImage *)image;
- (void)loadURL:(NSURL *)url;

@end
